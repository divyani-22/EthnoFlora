import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case.dart';
import '../services/case_service.dart';
import '../widgets/case_card.dart';
import '../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({Key? key}) : super(key: key);

  @override
  _CasesScreenState createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  List<Case> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cases = await CaseService.getCasesWithFallback();
      if (mounted) {
        setState(() {
          _cases = cases;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshCases() async {
    await _loadCases();
  }

  void _reviewCase(Case caseData) async {
    if (caseData.sourceUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(caseData.sourceUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error opening case profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading ? _buildLoadingState() : _buildCasesList(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.solidBlack),
    );
  }

  Widget _buildCasesList() {
    if (_cases.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.solidBlack, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.solidBlack,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_outlined, size: 48, color: AppColors.solidBlack),
              const SizedBox(height: 12),
              Text(
                'No Case Studies Available',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.solidBlack,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check your connection or pull to refresh',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.solidBlack.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCases,
      color: AppColors.solidBlack,
      backgroundColor: AppColors.cardWhite,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Banner introducing Indian Environmental Researchers
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softSky,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.solidBlack, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.solidBlack,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.solidBlack, width: 1.5),
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: AppColors.solidBlack, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🇮🇳 Indian Climate Action Case Studies',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Benchmark sustainability initiatives: Solar, Bio-CNG, Organic Policy & Mangroves',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.solidBlack.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ..._cases.map((c) => CaseCard(
            caseData: c,
            onReview: () => _reviewCase(c),
          )),
        ],
      ),
    );
  }
}
