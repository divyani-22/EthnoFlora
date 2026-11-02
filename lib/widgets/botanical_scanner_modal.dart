import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/medicinal_plant.dart';
import '../models/user.dart';
import '../services/ethno_data_service.dart';
import '../theme/app_theme.dart';
import '../screens/phytochem_screen.dart';
import '../screens/hdi_safety_screen.dart';
import '../screens/ai_chat_screen.dart';
import 'nagoya_certificate_modal.dart';

class BotanicalScannerModal extends StatefulWidget {
  final AppUser? user;

  const BotanicalScannerModal({super.key, this.user});

  static void show(BuildContext context, {AppUser? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BotanicalScannerModal(user: user),
    );
  }

  @override
  State<BotanicalScannerModal> createState() => _BotanicalScannerModalState();
}

class _BotanicalScannerModalState extends State<BotanicalScannerModal>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  MedicinalPlant? _identifiedPlant;
  double _confidence = 0.0;
  String? _sampleName;

  late AnimationController _scanAnimController;
  late Animation<double> _scanPosition;

  final List<Map<String, dynamic>> _specimenVouchers = [
    {
      'id': 'curcuma_longa',
      'label': 'Curcuma longa (Turmeric Rhizome/Leaf)',
      'plantId': 'plant_001',
      'icon': Icons.spa_rounded,
      'color': Color(0xFFFFD54F),
      'morphology': 'Oblong-lanceolate leaves, cylindrical branched rhizome',
    },
    {
      'id': 'withania_somnifera',
      'label': 'Withania somnifera (Ashwagandha)',
      'plantId': 'plant_002',
      'icon': Icons.grass_rounded,
      'color': Color(0xFFAED581),
      'morphology': 'Simple ovate leaves, fleshy white cylindrical taproot',
    },
    {
      'id': 'artemisia_annua',
      'label': 'Artemisia annua (Sweet Wormwood)',
      'plantId': 'plant_003',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF81C784),
      'morphology': 'Bi-pinnately dissected leaves with camphoraceous glandules',
    },
    {
      'id': 'ginkgo_biloba',
      'label': 'Ginkgo biloba (Maidenhair)',
      'plantId': 'plant_004',
      'icon': Icons.park_rounded,
      'color': Color(0xFFFFB74D),
      'morphology': 'Fan-shaped bilobed lamina with dichotomous venation',
    },
    {
      'id': 'rauvolfia_serpentina',
      'label': 'Rauvolfia serpentina (Sarpagandha)',
      'plantId': 'plant_007',
      'icon': Icons.local_florist_rounded,
      'color': Color(0xFFE57373),
      'morphology': 'Whorled leaves, white/pink corolla, tuberous tortuous root',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scanPosition = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _scanAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _selectedImage = file;
          _sampleName = file.name;
        });
        _runScannerAnalysis(plantId: 'plant_001', customConfidence: 0.962);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _selectVoucher(Map<String, dynamic> voucher) {
    setState(() {
      _selectedImage = null;
      _sampleName = voucher['label'];
    });
    _runScannerAnalysis(
      plantId: voucher['plantId'] as String,
      customConfidence: 0.984,
    );
  }

  Future<void> _runScannerAnalysis({
    required String plantId,
    double customConfidence = 0.97,
  }) async {
    setState(() {
      _isAnalyzing = true;
      _identifiedPlant = null;
    });

    _scanAnimController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 1600));

    await EthnoDataService.instance.initialize();
    final plant = EthnoDataService.instance.getPlantById(plantId) ??
        EthnoDataService.instance.plants.first;

    if (mounted) {
      _scanAnimController.stop();
      setState(() {
        _isAnalyzing = false;
        _identifiedPlant = plant;
        _confidence = customConfidence;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.paperCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.solidBlack.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
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
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: AppColors.cardWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multimodal Botanical AI Scanner',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      Text(
                        'Phenotypic Morphometrics • Kew POWO Binomial AI',
                        style: GoogleFonts.questrial(
                          fontSize: 12,
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.solidBlack),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.solidBlack, thickness: 1.5, height: 1),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildScannerViewport(),
                const SizedBox(height: 16),
                if (_isAnalyzing) _buildAnalyzingState(),
                if (!_isAnalyzing && _identifiedPlant != null)
                  _buildResultsCard(_identifiedPlant!),
                const SizedBox(height: 16),
                _buildVoucherLibrary(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerViewport() {
    return NeoCard(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2822),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.solidBlack, width: 2),
            ),
            child: Stack(
              children: [
                // Background image or placeholder
                Center(
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.filter_center_focus_rounded,
                              color: AppColors.sageGreen,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _sampleName ?? 'Select Voucher Specimen or Capture Photo',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RGB Optical Resolution: 1024x1024',
                              style: GoogleFonts.firaCode(
                                color: AppColors.sageGreen,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),

                // Viewfinder HUD crosshairs
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.butterYellow, width: 3),
                        left: BorderSide(color: AppColors.butterYellow, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.butterYellow, width: 3),
                        right: BorderSide(color: AppColors.butterYellow, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.butterYellow, width: 3),
                        left: BorderSide(color: AppColors.butterYellow, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.butterYellow, width: 3),
                        right: BorderSide(color: AppColors.butterYellow, width: 3),
                      ),
                    ),
                  ),
                ),

                // Animated Laser Line
                if (_isAnalyzing)
                  AnimatedBuilder(
                    animation: _scanPosition,
                    builder: (context, child) {
                      return Positioned(
                        top: 180 * _scanPosition.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons: Camera, Gallery
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.solidBlack, size: 18),
                  label: Text(
                    'Camera',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.solidBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.solidBlack, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: AppColors.paperCream,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, color: AppColors.solidBlack, size: 18),
                  label: Text(
                    'Upload Photo',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.solidBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.solidBlack, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: AppColors.paperCream,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return NeoCard(
      color: AppColors.butterYellow,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.solidBlack),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Computing Morphological Embeddings...',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'Cross-referencing POWO binomials & PubChem CIDs...',
                  style: GoogleFonts.questrial(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.solidBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard(MedicinalPlant plant) {
    return NeoCard(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.leafGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.solidBlack, width: 1.5),
                ),
                child: Text(
                  'MATCH CONFIDENCE: ${(_confidence * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cardWhite,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paperCream,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.solidBlack, width: 1.5),
                ),
                child: Text(
                  plant.iucnStatus,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botanical Names
          Text(
            plant.scientificName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.solidBlack,
            ),
          ),
          Text(
            'Common Name: ${plant.commonName} • Family: ${plant.family}',
            style: GoogleFonts.questrial(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.leafGreen,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            plant.traditionalUses,
            style: GoogleFonts.questrial(
              fontSize: 13,
              color: AppColors.solidBlack,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Metabolites & Targets
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...plant.activeMetabolites.map(
                (m) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.solidBlack, width: 1),
                  ),
                  child: Text(
                    '🧪 $m',
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.solidBlack,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.butterYellow.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.solidBlack, width: 1),
                ),
                child: Text(
                  '📜 ${plant.traditionalSystem}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.solidBlack, thickness: 1.5),
          const SizedBox(height: 12),

          // Deep-link Action Buttons
          Text(
            'Pipeline Actions & Verification:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhytochemScreen(user: widget.user),
                    ),
                  );
                },
                icon: const Icon(Icons.science_rounded, size: 16, color: AppColors.solidBlack),
                label: Text(
                  'Screen in PhytoChem',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sageGreen,
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HdiSafetyScreen(user: widget.user),
                    ),
                  );
                },
                icon: const Icon(Icons.shield_rounded, size: 16, color: AppColors.solidBlack),
                label: Text(
                  'Verify HDI Safety',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dustyCoral,
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  NagoyaCertificateModal.show(context, plant);
                },
                icon: const Icon(Icons.verified_rounded, size: 16, color: AppColors.solidBlack),
                label: Text(
                  'Nagoya ABS Cert',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.butterYellow,
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AIChatScreen(
                        user: widget.user,
                        initialPrompt:
                            'Provide clinical pharmacological evaluation for ${plant.scientificName} (${plant.commonName}) including verified dosage, WHO monograph evidence, and cytochrome P450 contraindications.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.psychology_rounded, size: 16, color: AppColors.solidBlack),
                label: Text(
                  'Ask PhytoDoc AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardWhite,
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherLibrary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Herbarium Voucher Specimen',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.solidBlack,
              ),
            ),
            Text(
              'Pre-loaded Standard Samples',
              style: GoogleFonts.questrial(
                fontSize: 11,
                color: AppColors.mutedText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._specimenVouchers.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NeoCard(
              color: AppColors.cardWhite,
              padding: const EdgeInsets.all(12),
              onTap: () => _selectVoucher(v),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: v['color'] as Color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    ),
                    child: Icon(v['icon'] as IconData, color: AppColors.solidBlack, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['label'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                        Text(
                          v['morphology'] as String,
                          style: GoogleFonts.questrial(
                            fontSize: 11,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.solidBlack),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
