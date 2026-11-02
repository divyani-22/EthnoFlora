import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/medicinal_plant.dart';
import '../models/user.dart';
import '../services/ethno_data_service.dart';
import '../theme/app_theme.dart';
import 'hdi_safety_screen.dart';
import 'phytochem_screen.dart';
import '../widgets/knowledge_graph_view.dart';
import '../widgets/nagoya_certificate_modal.dart';

class EthnoRadarScreen extends StatefulWidget {
  final AppUser? user;

  const EthnoRadarScreen({super.key, this.user});

  @override
  State<EthnoRadarScreen> createState() => _EthnoRadarScreenState();
}

class _EthnoRadarScreenState extends State<EthnoRadarScreen> {
  final MapController _mapController = MapController();
  List<MedicinalPlant> _plants = [];
  MedicinalPlant? _selectedPlant;
  String _selectedIucnFilter = 'All';
  bool _isSatellite = false;

  final ll.LatLng _initialCenter = const ll.LatLng(20.5937, 78.9629); // Central coordinate
  double _currentZoom = 3.5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await EthnoDataService.instance.initialize();
    if (mounted) {
      setState(() {
        _plants = EthnoDataService.instance.plants;
        if (_plants.isNotEmpty) {
          _selectedPlant = _plants.first;
        }
      });
    }
  }

  List<MedicinalPlant> get _filteredPlants {
    if (_selectedIucnFilter == 'All') return _plants;
    return _plants
        .where((p) => p.iucnStatus.toLowerCase() == _selectedIucnFilter.toLowerCase())
        .toList();
  }

  Color _getIucnColor(String status) {
    switch (status.toLowerCase()) {
      case 'critically endangered':
        return const Color(0xFFD32F2F);
      case 'endangered':
        return const Color(0xFFE53935);
      case 'vulnerable':
        return const Color(0xFFF57C00);
      case 'near threatened':
        return const Color(0xFFFBC02D);
      case 'least concern':
      default:
        return AppColors.leafGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: AppColors.paperCream,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.leafGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.solidBlack, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2)),
                ],
              ),
              child: const Icon(Icons.explore_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EthnoRadar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'GBIF Medicinal Flora & IUCN Conservation Sentinel',
                  style: GoogleFonts.questrial(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSatellite ? Icons.layers_rounded : Icons.satellite_alt_rounded,
              color: AppColors.solidBlack,
            ),
            tooltip: _isSatellite ? 'Switch to Street' : 'Switch to Satellite',
            onPressed: () => setState(() => _isSatellite = !_isSatellite),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. The Interactive Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _currentZoom,
              minZoom: 2.0,
              maxZoom: 17.0,
              onPositionChanged: (pos, hasGesture) {
                _currentZoom = pos.zoom;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ethnoflora.ai',
              ),
              MarkerLayer(
                markers: _filteredPlants.where((p) => p.gbifCoordinates != null).map((plant) {
                  final isSelected = _selectedPlant?.id == plant.id;
                  final pinColor = _getIucnColor(plant.iucnStatus);

                  return Marker(
                    point: ll.LatLng(
                      plant.gbifCoordinates!.latitude,
                      plant.gbifCoordinates!.longitude,
                    ),
                    width: isSelected ? 48 : 36,
                    height: isSelected ? 48 : 36,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlant = plant;
                        });
                        _mapController.move(
                          ll.LatLng(plant.gbifCoordinates!.latitude, plant.gbifCoordinates!.longitude),
                          (_currentZoom < 6.0 ? 6.0 : _currentZoom),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: pinColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.solidBlack,
                            width: isSelected ? 3.0 : 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.solidBlack,
                              offset: isSelected ? const Offset(3, 3) : const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_florist_rounded,
                            size: isSelected ? 24 : 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Top Filter Controls Pill
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill('All', '${_plants.length} Species'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Least Concern', 'Sustainable', const Color(0xFFE8F5E9)),
                  const SizedBox(width: 8),
                  _buildFilterPill('Vulnerable', 'Regulated', const Color(0xFFFFF3E0)),
                  const SizedBox(width: 8),
                  _buildFilterPill('Endangered', 'Protected', const Color(0xFFFFEBEE)),
                  const SizedBox(width: 8),
                  _buildFilterPill('Critically Endangered', 'CITES Ban', const Color(0xFFFFCDD2)),
                ],
              ),
            ),
          ),

          // 3. Bottom Selected Plant Detail Card
          if (_selectedPlant != null)
            Positioned(
              bottom: 110,
              left: 16,
              right: 16,
              child: _buildPlantDetailOverlay(_selectedPlant!),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String filter, String subtitle, [Color? color]) {
    final isSelected = _selectedIucnFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIucnFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.butterYellow : (color ?? AppColors.pureWhite),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.solidBlack, width: 2.0),
          boxShadow: const [
            BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.solidBlack,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($subtitle)',
              style: GoogleFonts.questrial(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.solidBlack.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantDetailOverlay(MedicinalPlant plant) {
    final iucnColor = _getIucnColor(plant.iucnStatus);

    return NeoCard(
      color: AppColors.cardWhite,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.commonName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.solidBlack,
                      ),
                    ),
                    Text(
                      '${plant.scientificName}  •  ${plant.family}',
                      style: GoogleFonts.questrial(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: AppColors.leafGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iucnColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: iucnColor, width: 1.5),
                ),
                child: Text(
                  plant.iucnStatus.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: iucnColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '📍 ${plant.gbifCoordinates?.locality ?? "India"} (${plant.gbifCoordinates?.latitude.toStringAsFixed(2) ?? "0.00"}°, ${plant.gbifCoordinates?.longitude.toStringAsFixed(2) ?? "0.00"}°)',
            style: GoogleFonts.questrial(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.solidBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Harvesting Policy: ${plant.harvestingRisk} • ${plant.nagoyaAbsStatus}',
            style: GoogleFonts.questrial(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.dustyCoral,
            ),
          ),
          const SizedBox(height: 10),
          // Action Buttons: Nagoya Certificate, Knowledge Graph, PhytoChem, HDI
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => NagoyaCertificateModal.show(context, plant),
                icon: const Icon(Icons.verified_outlined, size: 14, color: AppColors.leafGreen),
                label: Text(
                  'Nagoya ABS Certificate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  backgroundColor: const Color(0xFFC3D9A0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => KnowledgeGraphView.showModal(context, plant),
                icon: const Icon(Icons.hub_outlined, size: 14, color: AppColors.solidBlack),
                label: Text(
                  'Knowledge Graph',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  backgroundColor: AppColors.butterYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhytochemScreen(user: widget.user),
                    ),
                  );
                },
                icon: const Icon(Icons.science_outlined, size: 14, color: AppColors.solidBlack),
                label: Text(
                  'PhytoChem',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.solidBlack),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  backgroundColor: AppColors.paperCream,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HdiSafetyScreen(user: widget.user),
                    ),
                  );
                },
                icon: const Icon(Icons.shield_outlined, size: 14, color: Colors.white),
                label: Text(
                  'Interactions',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leafGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
