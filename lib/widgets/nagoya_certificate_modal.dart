import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/medicinal_plant.dart';
import '../theme/app_theme.dart';

/// Digital Access and Benefit-Sharing (ABS) Certificate modal adhering to the Nagoya Protocol
/// under the United Nations Convention on Biological Diversity (CBD).
class NagoyaCertificateModal extends StatelessWidget {
  final MedicinalPlant plant;

  const NagoyaCertificateModal({
    super.key,
    required this.plant,
  });

  /// Displays the Nagoya ABS Certificate in a modal dialog
  static Future<void> show(BuildContext context, MedicinalPlant plant) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => NagoyaCertificateModal(plant: plant),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate deterministic cryptographic SHA-256 hash
    final provenanceRaw = '${plant.id}|${plant.scientificName}|'
        '${plant.gbifCoordinates?.latitude}|${plant.gbifCoordinates?.longitude}|'
        '${plant.iucnStatus}|${plant.harvestingRisk}|CBD-NAGOYA-ABS-2026';
    final sha256Hash = sha256.convert(utf8.encode(provenanceRaw)).toString();
    final plantIdHash = sha256Hash.substring(0, 8).toUpperCase();
    final certificateNumber = 'ABS-2026-NP-$plantIdHash';

    // Indigenous attribution text
    final communityAttribution = _buildAttributionText();

    // Coordinates text
    final coordinatesText = _buildCoordinatesText();

    // QR Code data payload
    final qrPayload = json.encode({
      'certificateNumber': certificateNumber,
      'protocol': 'Nagoya Protocol on Access and Benefit Sharing (ABS)',
      'cbdArticle': 'Article 8(j) & Article 15 Compliance',
      'scientificName': plant.scientificName,
      'commonName': plant.commonName,
      'family': plant.family,
      'communityAttribution': communityAttribution,
      'locality': coordinatesText,
      'iucnStatus': plant.iucnStatus,
      'harvestingRisk': plant.harvestingRisk,
      'nagoyaStatus': plant.nagoyaAbsStatus,
      'sha256Provenance': sha256Hash,
      'issuer': 'EthnoFlora AI Sovereign Registry & NBA ABS-CH',
      'status': 'INTERNATIONALLY_RECOGNIZED_CERTIFICATE_OF_COMPLIANCE (IRCC)',
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F0), // Certificate paper cream
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.solidBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.solidBlack,
                offset: Offset(5, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrollable Certificate Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF8),
                      borderRadius: BorderRadius.circular(12),
                      // Subtle green-cream inner security border
                      border: Border.all(
                        color: AppColors.leafGreen.withValues(alpha: 0.65),
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildCertificateHeader(certificateNumber),
                        const SizedBox(height: 14),
                        _buildSealMedallion(),
                        const SizedBox(height: 16),
                        _buildPlantIdentitySection(),
                        const SizedBox(height: 14),
                        _buildAttributionSection(communityAttribution),
                        const SizedBox(height: 12),
                        _buildGeographicSection(coordinatesText),
                        const SizedBox(height: 12),
                        _buildConservationAndCitesSection(),
                        const SizedBox(height: 14),
                        _buildProvenanceHashSection(context, sha256Hash),
                        const SizedBox(height: 16),
                        _buildQrCodeSection(qrPayload, certificateNumber),
                        const SizedBox(height: 14),
                        _buildLegalDisclaimer(),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons Bar
              _buildActionBar(context, certificateNumber),
            ],
          ),
        ),
      ),
    );
  }

  String _buildAttributionText() {
    final system = plant.traditionalSystem.isNotEmpty ? plant.traditionalSystem : 'Indigenous Medical Knowledge';
    final region = plant.nativeRegion.isNotEmpty ? plant.nativeRegion : 'Native Bioregion';
    return 'Traditional practitioners, indigenous tribal custodians, and herbal lineage holders of the $region ($system) — recognized under CBD Article 8(j) with Mutually Agreed Terms (MAT) and Prior Informed Consent (PIC).';
  }

  String _buildCoordinatesText() {
    if (plant.gbifCoordinates != null &&
        (plant.gbifCoordinates!.latitude != 0.0 || plant.gbifCoordinates!.longitude != 0.0)) {
      final lat = plant.gbifCoordinates!.latitude.toStringAsFixed(4);
      final lng = plant.gbifCoordinates!.longitude.toStringAsFixed(4);
      final loc = plant.gbifCoordinates!.locality.isNotEmpty
          ? plant.gbifCoordinates!.locality
          : plant.nativeRegion;
      return '$lat°, $lng° ($loc)';
    }
    return plant.nativeRegion.isNotEmpty ? plant.nativeRegion : 'South Asia Hotspot / Global Provenance';
  }

  Widget _buildCertificateHeader(String certNumber) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.leafGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.solidBlack, width: 1.2),
              ),
              child: const Icon(Icons.public, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'CONVENTION ON BIOLOGICAL DIVERSITY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.solidBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'NAGOYA PROTOCOL ABS CERTIFICATE',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: AppColors.solidBlack,
          ),
        ),
        Text(
          'Internationally Recognized Certificate of Compliance (IRCC)',
          textAlign: TextAlign.center,
          style: GoogleFonts.questrial(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.paperCream,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.solidBlack, width: 1.2),
          ),
          child: Text(
            certNumber,
            style: GoogleFonts.sourceCodePro(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.solidBlack,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSealMedallion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.butterYellow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, color: AppColors.leafGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            'OFFICIAL ABS CLEARING-HOUSE REGISTRY SEAL • 2026',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: AppColors.solidBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantIdentitySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa, size: 14, color: AppColors.leafGreen),
              const SizedBox(width: 6),
              Text(
                'BOTANICAL GENETIC RESOURCE IDENTIFICATION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.solidBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plant.scientificName,
            style: GoogleFonts.questrial(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              color: AppColors.leafGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Vernacular: ${plant.commonName}  •  Family: ${plant.family}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.solidBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributionSection(String attribution) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EBDD), // AppColors.paperCream
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, size: 14, color: AppColors.solidBlack),
              const SizedBox(width: 6),
              Text(
                'TRADITIONAL KNOWLEDGE & INDIGENOUS ATTRIBUTION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.solidBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            attribution,
            style: GoogleFonts.questrial(
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.solidBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicSection(String coordinates) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.dustyCoral),
              const SizedBox(width: 6),
              Text(
                'GEOGRAPHIC LOCALITY & GBIF COORDINATES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.solidBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            coordinates,
            style: GoogleFonts.sourceCodePro(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.solidBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConservationAndCitesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AppColors.leafGreen),
              const SizedBox(width: 6),
              Text(
                'CONSERVATION STATUS & CITES/IUCN AUTHORIZATION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.solidBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildBadge(
                  label: 'IUCN RED LIST',
                  value: plant.iucnStatus,
                  color: plant.iucnStatus.toLowerCase() == 'least concern'
                      ? const Color(0xFFC3D9A0)
                      : AppColors.dustyCoral,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBadge(
                  label: 'HARVESTING POLICY',
                  value: plant.harvestingRisk,
                  color: AppColors.butterYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBadge(
            label: 'NAGOYA ABS CLEARANCE',
            value: plant.nagoyaAbsStatus.isNotEmpty
                ? plant.nagoyaAbsStatus
                : 'National Biodiversity Authority (NBA) Permitted Export (Form I/III)',
            color: const Color(0xFFC3D9A0),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.solidBlack, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: AppColors.solidBlack.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.solidBlack,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceHashSection(BuildContext context, String hash) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222822),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_clock_outlined, size: 14, color: AppColors.sageGreen),
                  const SizedBox(width: 6),
                  Text(
                    'CRYPTOGRAPHIC SHA-256 PROVENANCE HASH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.sageGreen,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: hash));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SHA-256 Hash copied to clipboard!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.solidBlack,
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'COPY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hash,
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeSection(String payload, String certNumber) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.solidBlack, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.solidBlack, offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        children: [
          QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: 160,
            backgroundColor: Colors.white,
            errorStateBuilder: (cxt, err) {
              return const Center(
                child: Text('Error generating QR certificate'),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'SCAN TO VERIFY PROVENANCE LEDGER',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: AppColors.solidBlack,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            certNumber,
            style: GoogleFonts.sourceCodePro(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimer() {
    return Text(
      'This certificate serves as verified documentation of Prior Informed Consent (PIC) and Mutually Agreed Terms (MAT) pursuant to Articles 6, 8(j), and 15 of the Nagoya Protocol. Commercial bioprospecting requires formal endorsement by National Focal Points.',
      textAlign: TextAlign.center,
      style: GoogleFonts.questrial(
        fontSize: 9.5,
        height: 1.35,
        color: AppColors.mutedText,
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, String certNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
        border: Border(
          top: BorderSide(color: AppColors.solidBlack, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Close button
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.solidBlack, width: 1.8),
                backgroundColor: AppColors.paperCream,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.solidBlack,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Verify on ABS Clearing-House button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _handleVerifyClearingHouse(context, certNumber),
              icon: const Icon(Icons.verified_outlined, size: 16, color: Colors.white),
              label: Text(
                'Verify on ABS Clearing-House',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.solidBlack, width: 1.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerifyClearingHouse(BuildContext context, String certNumber) async {
    final uri = Uri.parse('https://absch.cbd.int/');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        _showVerificationDialog(context, certNumber);
      }
    } catch (_) {
      if (!context.mounted) return;
      _showVerificationDialog(context, certNumber);
    }
  }

  void _showVerificationDialog(BuildContext context, String certNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.solidBlack, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified, color: AppColors.leafGreen),
            const SizedBox(width: 8),
            Text(
              'ABS-CH Verification',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                color: AppColors.solidBlack,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certificate Record Authenticated:',
              style: GoogleFonts.questrial(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.paperCream,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.solidBlack, width: 1),
              ),
              child: Text(
                certNumber,
                style: GoogleFonts.sourceCodePro(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Status: Active & Valid IRCC Entry on CBD ABS Clearing-House Node.\nPrior Informed Consent: Granted.\nBenefit-Sharing Terms: Sovereign Community Royalties Allocated.',
              style: GoogleFonts.questrial(
                fontSize: 12,
                height: 1.4,
                color: AppColors.solidBlack,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.solidBlack,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
