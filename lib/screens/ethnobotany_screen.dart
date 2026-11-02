import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/medicinal_plant.dart';
import '../models/user.dart';
import '../services/ethno_data_service.dart';
import '../theme/app_theme.dart';
import 'hdi_safety_screen.dart';
import 'phytochem_screen.dart';
import '../widgets/knowledge_graph_view.dart';
import '../widgets/nagoya_certificate_modal.dart';

class EthnobotanyScreen extends StatefulWidget {
  final AppUser? user;

  const EthnobotanyScreen({super.key, this.user});

  @override
  State<EthnobotanyScreen> createState() => _EthnobotanyScreenState();
}

class _EthnobotanyScreenState extends State<EthnobotanyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MedicinalPlant> _filteredPlants = [];
  String _selectedSystem = 'All';
  String _selectedIucn = 'All';

  final List<String> _traditionalSystems = [
    'All',
    'Ayurveda',
    'TCM',
    'Greco-Roman',
    'African',
    'Amazonian',
  ];

  final List<String> _iucnStatuses = [
    'All',
    'Least Concern',
    'Vulnerable',
    'Endangered',
    'Critically Endangered',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    await EthnoDataService.instance.initialize();
    if (mounted) {
      setState(() {
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim();
    var list = EthnoDataService.instance.searchPlants(query);

    if (_selectedSystem != 'All') {
      list = list.where((p) => p.traditionalSystem.toLowerCase().contains(_selectedSystem.toLowerCase())).toList();
    }

    if (_selectedIucn != 'All') {
      list = list.where((p) => p.iucnStatus.toLowerCase() == _selectedIucn.toLowerCase()).toList();
    }

    setState(() {
      _filteredPlants = list;
    });
  }

  Color _getIucnColor(String status) {
    switch (status.toLowerCase()) {
      case 'critically endangered':
        return const Color(0xFFB71C1C);
      case 'endangered':
        return const Color(0xFFD32F2F);
      case 'vulnerable':
        return const Color(0xFFF57C00);
      case 'near threatened':
        return const Color(0xFFFBC02D);
      case 'least concern':
      default:
        return AppColors.leafGreen;
    }
  }

  Color _getIucnBg(String status) {
    switch (status.toLowerCase()) {
      case 'critically endangered':
      case 'endangered':
        return const Color(0xFFFFEBEE);
      case 'vulnerable':
      case 'near threatened':
        return const Color(0xFFFFF8E1);
      case 'least concern':
      default:
        return const Color(0xFFE8F5E9);
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
              child: const Icon(Icons.local_florist_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EthnoBotanical Explorer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'Traditional Knowledge Mining & POWO Taxonomy',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBanner(),
                const SizedBox(height: 16),
                _buildSearchAndFilters(),
                const SizedBox(height: 16),
                if (_filteredPlants.isEmpty)
                  _buildNoResultsCard()
                else
                  ..._filteredPlants.map(_buildPlantCard),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final all = EthnoDataService.instance.plants;
    final threatened = all.where((p) => p.iucnStatus.toLowerCase() != 'least concern').length;

    return Row(
      children: [
        Expanded(
          child: NeoCard(
            color: AppColors.sageGreen,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Column(
              children: [
                Text(
                  '${all.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'Curated Species',
                  style: GoogleFonts.questrial(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NeoCard(
            color: AppColors.dustyCoral,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Column(
              children: [
                Text(
                  '$threatened',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Threatened / Protected',
                  style: GoogleFonts.questrial(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NeoCard(
            color: AppColors.butterYellow,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Column(
              children: [
                Text(
                  '100%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'Nagoya ABS Verified',
                  style: GoogleFonts.questrial(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return NeoCard(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            style: GoogleFonts.questrial(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search by common name, binomial, traditional system, or metabolite...',
              hintStyle: GoogleFonts.questrial(color: AppColors.mutedText),
              prefixIcon: const Icon(Icons.search, color: AppColors.solidBlack),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.paperCream.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.solidBlack, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.solidBlack, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.leafGreen, width: 2.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // System Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _traditionalSystems.map((sys) {
                final isSelected = _selectedSystem == sys;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      sys,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.solidBlack,
                      ),
                    ),
                    backgroundColor: AppColors.paperCream,
                    selectedColor: AppColors.butterYellow,
                    side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                    onSelected: (val) {
                      setState(() {
                        _selectedSystem = sys;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // IUCN Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _iucnStatuses.map((iucn) {
                final isSelected = _selectedIucn == iucn;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(
                      iucn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.solidBlack,
                      ),
                    ),
                    backgroundColor: AppColors.paperCream,
                    selectedColor: AppColors.leafGreen,
                    side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                    onSelected: (val) {
                      setState(() {
                        _selectedIucn = iucn;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(MedicinalPlant plant) {
    final iucnColor = _getIucnColor(plant.iucnStatus);
    final iucnBg = _getIucnBg(plant.iucnStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeoCard(
        color: AppColors.cardWhite,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Common Name, Scientific Binomial, and IUCN Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 2),
                      Text(
                        plant.scientificName,
                        style: GoogleFonts.questrial(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: AppColors.leafGreen,
                        ),
                      ),
                      Text(
                        'Family: ${plant.family}  •  ${plant.nativeRegion}',
                        style: GoogleFonts.questrial(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: iucnBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: iucnColor, width: 1.5),
                  ),
                  child: Text(
                    plant.iucnStatus.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: iucnColor,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 18, thickness: 1.2, color: AppColors.paperCream),

            // Traditional Medicine System & Uses
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.butterYellow.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.solidBlack, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_edu_outlined, size: 14, color: AppColors.solidBlack),
                      const SizedBox(width: 6),
                      Text(
                        'TRADITIONAL KNOWLEDGE (${plant.traditionalSystem})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.traditionalUses,
                    style: GoogleFonts.questrial(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.solidBlack,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Active Secondary Metabolites & Molecular Targets
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: plant.activeMetabolites.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.paperCream,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.solidBlack, width: 1),
                  ),
                  child: Text(
                    m,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.solidBlack,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Summary
            Text(
              plant.summary,
              style: GoogleFonts.questrial(
                fontSize: 12,
                color: AppColors.mutedText,
              ),
            ),

            const SizedBox(height: 12),

            // Primary scientific actions: Knowledge Graph & Nagoya Certificate
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => KnowledgeGraphView.showModal(context, plant),
                    icon: const Icon(Icons.hub_outlined, size: 14, color: AppColors.solidBlack),
                    label: Text(
                      'Explore Knowledge Graph',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                      backgroundColor: AppColors.butterYellow,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => NagoyaCertificateModal.show(context, plant),
                    icon: const Icon(Icons.verified_outlined, size: 14, color: AppColors.leafGreen),
                    label: Text(
                      'Nagoya ABS Certificate',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                      backgroundColor: const Color(0xFFC3D9A0),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Footer Badges & Cross-Link Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nagoya Protocol & Evidence Badge
                GestureDetector(
                  onTap: () => NagoyaCertificateModal.show(context, plant),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.leafGreen, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 12, color: AppColors.leafGreen),
                        const SizedBox(width: 4),
                        Text(
                          'Nagoya ABS Compliant',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.leafGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.science_outlined, size: 18, color: AppColors.solidBlack),
                      tooltip: 'Screen in PhytoChem',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhytochemScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shield_outlined, size: 18, color: AppColors.dustyCoral),
                      tooltip: 'Check Herb-Drug Interactions',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HdiSafetyScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsCard() {
    return NeoCard(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 40, color: AppColors.mutedText),
            const SizedBox(height: 8),
            Text(
              'No Medicinal Plants Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try clearing filters or search by common names like "Turmeric", "Ashwagandha", or "Artemisia".',
              textAlign: TextAlign.center,
              style: GoogleFonts.questrial(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
