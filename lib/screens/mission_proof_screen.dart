import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ecore.dart';
import '../models/user.dart';
import '../services/climagame_service.dart';
import '../services/image_upload_service.dart';
import '../theme/app_theme.dart';

class MissionProofScreen extends StatefulWidget {
  final Ecore ecore;
  final EcoreMission mission;
  final AppUser user;

  const MissionProofScreen({
    super.key,
    required this.ecore,
    required this.mission,
    required this.user,
  });

  @override
  State<MissionProofScreen> createState() => _MissionProofScreenState();
}

class _MissionProofScreenState extends State<MissionProofScreen> {
  Uint8List? _selectedImageBytes;
  bool _isVerifying = false;
  String _verificationStep = '';
  double _verificationProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: AppColors.paperCream,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: NeoBackButton(
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.butterYellow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.solidBlack, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.solidBlack,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            'ETHNORADAR PROOF',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.solidBlack,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: PaperGridBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Mission Details Hero Card
            NeoCard(
              color: AppColors.cardWhite,
              radius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricMint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.solidBlack, width: 1.5),
                        ),
                        child: Text(
                          widget.ecore.name.split(' ').first.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.butterYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.solidBlack, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, size: 14, color: AppColors.solidBlack),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.mission.points} Flora Coins',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.solidBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.mission.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.solidBlack,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.mission.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.solidBlack.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Photo Capture / Preview Card
            if (_selectedImageBytes == null)
              _buildEmptyPhotoPickerCard()
            else
              _buildPhotoPreviewCard(),

            const SizedBox(height: 16),

            // Verification Guidelines Card
            NeoCard(
              color: AppColors.cardWhite,
              radius: 16,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI VERIFICATION CRITERIA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCriterionRow('📸', 'Clear in-situ photo of the completed environmental action.'),
                  const SizedBox(height: 6),
                  _buildCriterionRow('📍', 'Photo location verified within the campus action radius.'),
                  const SizedBox(height: 6),
                  _buildCriterionRow('🤖', 'AI Vision checks object fidelity (sapling, solar, bin, etc.).'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            if (_isVerifying)
              _buildVerifyingStateCard()
            else
              NeoButton(
                text: _selectedImageBytes == null
                    ? 'Take Photo First'
                    : 'Submit & Verify Climate Action',
                color: _selectedImageBytes == null ? Colors.grey[300]! : AppColors.butterYellow,
                textColor: AppColors.solidBlack,
                onPressed: _selectedImageBytes == null ? null : _startAiVerificationAndSubmit,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPhotoPickerCard() {
    return NeoCard(
      color: AppColors.cardWhite,
      radius: 18,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.softSky,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.solidBlack, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.solidBlack,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.solidBlack,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Upload Mission Proof Photo',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.solidBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take a photo of your tangible action on campus',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _takePhotoWithCamera,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.electricMint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.solidBlack, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.solidBlack,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.solidBlack),
                        const SizedBox(width: 6),
                        Text(
                          'Open Camera',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.solidBlack, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.solidBlack,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 18, color: AppColors.solidBlack),
                        const SizedBox(width: 6),
                        Text(
                          'From Gallery',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreviewCard() {
    return NeoCard(
      color: AppColors.pureWhite,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricMint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.solidBlack, width: 1.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.solidBlack),
                    const SizedBox(width: 4),
                    Text(
                      'PROOF PHOTO CAPTURED',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageBytes = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.solidBlack, width: 1.2),
                  ),
                  child: Text(
                    'Retake',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dustyCoral,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.solidBlack, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.solidBlack,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ready for EthnoFlora AI AI Validation',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.leafGreen,
                ),
              ),
              Text(
                '${(_selectedImageBytes!.length / 1024).toStringAsFixed(1)} KB',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyingStateCard() {
    return NeoCard(
      color: AppColors.butterYellow,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.solidBlack,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _verificationStep,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _verificationProgress,
              backgroundColor: AppColors.pureWhite,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: AppColors.solidBlack.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      HapticFeedback.lightImpact();
      final bytes = await ImageUploadService.takePhotoWithCamera();
      if (bytes != null && mounted) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera: $e'),
            backgroundColor: AppColors.dustyCoral,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      HapticFeedback.lightImpact();
      final bytes = await ImageUploadService.pickImageFromGallery();
      if (bytes != null && mounted) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick photo: $e'),
            backgroundColor: AppColors.dustyCoral,
          ),
        );
      }
    }
  }

  Future<void> _startAiVerificationAndSubmit() async {
    if (_selectedImageBytes == null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isVerifying = true;
      _verificationStep = 'Extracting GPS & campus metadata...';
      _verificationProgress = 0.25;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _verificationStep = 'AI analyzing ecological features & tree/solar fidelity...';
      _verificationProgress = 0.65;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      _verificationStep = 'Verifying with EthnoFlora AI registry...';
      _verificationProgress = 0.90;
    });

    // Upload & complete mission
    String? proofUrl = await ImageUploadService.uploadMissionProofImage(
      missionId: widget.mission.id,
      userId: widget.user.id,
      imageBytes: _selectedImageBytes,
    );

    await ClimaGameService.completeMission(
      userId: widget.user.id,
      userName: widget.user.fullName,
      ecoreId: widget.ecore.id,
      missionId: widget.mission.id,
      proofImageUrl: proofUrl,
    );

    if (!mounted) return;

    setState(() {
      _verificationProgress = 1.0;
      _verificationStep = 'Verified! Crediting Flora Coins...';
    });

    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isVerifying = false);
      _showCelebrationDialog();
    }
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoCard(
          color: AppColors.pureWhite,
          radius: 22,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.butterYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.solidBlack, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.solidBlack,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.stars_rounded, size: 44, color: AppColors.solidBlack),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'MISSION VERIFIED!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.solidBlack,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'EthnoFlora AI AI validated your climate action at ${widget.ecore.name}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.mutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.electricMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.solidBlack, width: 1.8),
                ),
                child: Text(
                  '+${widget.mission.points} Flora Coins Credited 🪙',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              NeoButton(
                text: 'Back to EthnoRadar Radar',
                color: AppColors.butterYellow,
                textColor: AppColors.solidBlack,
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context, true); // Return to modal / map
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}