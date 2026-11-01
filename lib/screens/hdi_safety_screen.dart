import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/herb_drug_interaction.dart';
import '../models/user.dart';
import '../services/ethno_data_service.dart';
import '../theme/app_theme.dart';
import 'ai_chat_screen.dart';

class HdiSafetyScreen extends StatefulWidget {
  final AppUser? user;

  const HdiSafetyScreen({super.key, this.user});

  @override
  State<HdiSafetyScreen> createState() => _HdiSafetyScreenState();
}

class _HdiSafetyScreenState extends State<HdiSafetyScreen> {
  final TextEditingController _herbController = TextEditingController();
  final TextEditingController _drugController = TextEditingController();

  List<HerbDrugInteraction> _filteredInteractions = [];
  HerbDrugInteraction? _selectedInteraction;
  String _selectedSeverityFilter = 'All';

  final List<String> _popularDrugs = [
    'Warfarin',
    'Sertraline',
    'Aspirin',
    'Metformin',
    'Lisinopril',
    'Oral Contraceptives',
    'Digoxin',
  ];

  final List<String> _popularHerbs = [
    "St. John's Wort",
    'Curcumin',
    'Ginkgo',
    'Garlic',
    'Licorice',
    'Ashwagandha',
    'Ginseng',
  ];

  @override
  void initState() {
    super.initState();
    _loadInteractions();
  }

  Future<void> _loadInteractions() async {
    await EthnoDataService.instance.initialize();
    if (mounted) {
      setState(() {
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final herbQ = _herbController.text.trim();
    final drugQ = _drugController.text.trim();

    var results = EthnoDataService.instance.checkDrugInteractions(
      herbQuery: herbQ.isEmpty ? null : herbQ,
      drugQuery: drugQ.isEmpty ? null : drugQ,
    );

    if (_selectedSeverityFilter != 'All') {
      results = results
          .where((i) => i.severity.toLowerCase() == _selectedSeverityFilter.toLowerCase())
          .toList();
    }

    setState(() {
      _filteredInteractions = results;
      if (_selectedInteraction != null && !_filteredInteractions.contains(_selectedInteraction)) {
        _selectedInteraction = _filteredInteractions.isNotEmpty ? _filteredInteractions.first : null;
      }
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFE53935);
      case 'moderate':
        return const Color(0xFFF57C00);
      case 'mild':
        return const Color(0xFF43A047);
      default:
        return AppColors.solidBlack;
    }
  }

  Color _getSeverityBg(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFFFEBEE);
      case 'moderate':
        return const Color(0xFFFFF3E0);
      case 'mild':
        return const Color(0xFFE8F5E9);
      default:
        return AppColors.cardWhite;
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
                color: AppColors.dustyCoral,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.solidBlack, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2)),
                ],
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HDI Safety Engine',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'Clinical Herb-Drug Interaction & CYP450 Checker',
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
                _buildSearchCard(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 16),
                if (_filteredInteractions.isEmpty)
                  _buildNoResultsCard()
                else
                  ..._filteredInteractions.map(_buildInteractionCard),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return NeoCard(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.butterYellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.solidBlack, width: 1.5),
                ),
                child: Text(
                  'PHARMACOKINETIC SAFETY',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${EthnoDataService.instance.interactions.length} Interactions Curated',
                style: GoogleFonts.questrial(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Check Prescription Drugs Against Botanical Remedies',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.solidBlack,
            ),
          ),
          const SizedBox(height: 14),

          // Prescription Drug Field
          TextField(
            controller: _drugController,
            onChanged: (_) => _applyFilters(),
            style: GoogleFonts.questrial(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Prescription Drug / Active Pharmaceutical (e.g. Warfarin)',
              labelStyle: GoogleFonts.questrial(color: AppColors.mutedText),
              prefixIcon: const Icon(Icons.medication_liquid_outlined, color: AppColors.dustyCoral),
              suffixIcon: _drugController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _drugController.clear();
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
                borderSide: const BorderSide(color: AppColors.dustyCoral, width: 2.5),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Quick Drug Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _popularDrugs.map((drug) {
                final isSelected = _drugController.text.toLowerCase() == drug.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      drug,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.solidBlack,
                      ),
                    ),
                    backgroundColor: isSelected ? AppColors.dustyCoral : AppColors.paperCream,
                    side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                    onPressed: () {
                      _drugController.text = isSelected ? '' : drug;
                      _applyFilters();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Botanical Herb Field
          TextField(
            controller: _herbController,
            onChanged: (_) => _applyFilters(),
            style: GoogleFonts.questrial(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Botanical / Herbal Remedy (e.g. St. John\'s Wort, Curcumin)',
              labelStyle: GoogleFonts.questrial(color: AppColors.mutedText),
              prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.leafGreen),
              suffixIcon: _herbController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _herbController.clear();
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
          const SizedBox(height: 8),

          // Quick Herb Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _popularHerbs.map((herb) {
                final isSelected = _herbController.text.toLowerCase() == herb.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      herb,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.solidBlack,
                      ),
                    ),
                    backgroundColor: isSelected ? AppColors.leafGreen : AppColors.sageGreen.withValues(alpha: 0.4),
                    side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                    onPressed: () {
                      _herbController.text = isSelected ? '' : herb;
                      _applyFilters();
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

  Widget _buildFilterChips() {
    final severities = ['All', 'High', 'Moderate', 'Mild'];

    return Row(
      children: [
        Text(
          'Filter Risk: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.solidBlack,
          ),
        ),
        const SizedBox(width: 6),
        ...severities.map((sev) {
          final isSelected = _selectedSeverityFilter == sev;
          Color chipColor;
          if (sev == 'High') {
            chipColor = const Color(0xFFEF9A9A);
          } else if (sev == 'Moderate') {
            chipColor = const Color(0xFFFFCC80);
          } else if (sev == 'Mild') {
            chipColor = const Color(0xFFA5D6A7);
          } else {
            chipColor = AppColors.cardWhite;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                sev,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.solidBlack,
                ),
              ),
              backgroundColor: chipColor.withValues(alpha: 0.7),
              selectedColor: chipColor,
              side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
              onSelected: (val) {
                setState(() {
                  _selectedSeverityFilter = sev;
                  _applyFilters();
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInteractionCard(HerbDrugInteraction interaction) {
    final severityColor = _getSeverityColor(interaction.severity);
    final severityBg = _getSeverityBg(interaction.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeoCard(
        color: AppColors.cardWhite,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Botanical & Drug Titles + Severity Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded, size: 16, color: AppColors.leafGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${interaction.herbName} (${interaction.botanicalName})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.solidBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.add, size: 14, color: AppColors.dustyCoral),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${interaction.prescriptionDrug} [${interaction.drugClass}]',
                              style: GoogleFonts.questrial(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dustyCoral,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: severityBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: severityColor, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: severityColor),
                      const SizedBox(width: 4),
                      Text(
                        '${interaction.severity.toUpperCase()} RISK',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 1.5, color: AppColors.paperCream),

            // CYP450 Mechanism
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.butterYellow.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.solidBlack, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.biotech_outlined, size: 18, color: AppColors.solidBlack),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CYP450 / PHARMACOKINETIC MECHANISM',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          interaction.cypMechanism,
                          style: GoogleFonts.questrial(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Clinical Effect
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.report_problem_outlined, size: 18, color: Color(0xFFC62828)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLINICAL MANIFESTATION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      Text(
                        interaction.clinicalEffect,
                        style: GoogleFonts.questrial(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Management Recommendation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 18, color: AppColors.leafGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLINICAL MANAGEMENT GUIDELINE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.leafGreen,
                        ),
                      ),
                      Text(
                        interaction.managementRecommendation,
                        style: GoogleFonts.questrial(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Footer: Evidence Level + Consult AI button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.paperCream,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.solidBlack, width: 1.2),
                  ),
                  child: Text(
                    interaction.evidenceLevel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.solidBlack,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final query =
                        'Please explain the clinical mechanism and safety management of combining ${interaction.herbName} with ${interaction.prescriptionDrug}. Cite relevant WHO Monographs or clinical studies.';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIChatScreen(
                          user: widget.user,
                          initialPrompt: query,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined, size: 16, color: AppColors.solidBlack),
                  label: Text(
                    'Ask PhytoDoc AI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.solidBlack,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                    ),
                  ),
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
      child: Column(
        children: [
          const Icon(Icons.verified_outlined, size: 48, color: AppColors.leafGreen),
          const SizedBox(height: 12),
          Text(
            'No Direct Conflict Found in Curated Database',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.solidBlack,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'While no documented high-risk interaction was detected for this query, always exercise clinical precaution. Consult PhytoDoc AI for in-depth pharmacological assessment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.questrial(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final herb = _herbController.text.trim();
              final drug = _drugController.text.trim();
              final prompt = 'Is there any known interaction between herb "$herb" and pharmaceutical "$drug"?';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIChatScreen(
                    user: widget.user,
                    initialPrompt: prompt,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.psychology_outlined, color: Colors.white),
            label: Text(
              'Deep Assessment with PhytoDoc AI',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.leafGreen,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.solidBlack, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
