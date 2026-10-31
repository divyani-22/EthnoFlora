import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/phytochemical.dart';
import '../models/user.dart';
import '../services/ethno_data_service.dart';
import '../theme/app_theme.dart';
import 'ai_chat_screen.dart';

class PhytochemScreen extends StatefulWidget {
  final AppUser? user;

  const PhytochemScreen({super.key, this.user});

  @override
  State<PhytochemScreen> createState() => _PhytochemScreenState();
}

class _PhytochemScreenState extends State<PhytochemScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Phytochemical> _filteredCompounds = [];
  String _selectedClass = 'All';
  String _selectedLipinskiFilter = 'All';
  final Set<String> _conformer3dActive = {};

  final List<String> _classes = [
    'All',
    'Alkaloid',
    'Flavonoid',
    'Terpenoid',
    'Polyphenol',
    'Glycoside',
  ];

  @override
  void initState() {
    super.initState();
    _loadCompounds();
  }

  Future<void> _loadCompounds() async {
    await EthnoDataService.instance.initialize();
    if (mounted) {
      setState(() {
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim();
    var list = EthnoDataService.instance.searchPhytochemicals(query);

    if (_selectedClass != 'All') {
      list = list.where((p) => p.chemicalClass.toLowerCase() == _selectedClass.toLowerCase()).toList();
    }

    if (_selectedLipinskiFilter == 'Drug-like Only') {
      list = list.where((p) => p.isDrugLike).toList();
    } else if (_selectedLipinskiFilter == 'With Violations') {
      list = list.where((p) => p.lipinskiViolations > 0).toList();
    }

    setState(() {
      _filteredCompounds = list;
    });
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
                color: AppColors.sageGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.solidBlack, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2)),
                ],
              ),
              child: const Icon(Icons.science_outlined, color: AppColors.solidBlack, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PhytoChem Screener',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  'Cheminformatics, SMILES & Lipinski Rule of 5',
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
                _buildHeaderMetrics(),
                const SizedBox(height: 16),
                _buildSearchAndFilters(),
                const SizedBox(height: 16),
                if (_filteredCompounds.isEmpty)
                  _buildNoResultsCard()
                else
                  ..._filteredCompounds.map(_buildCompoundCard),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMetrics() {
    final all = EthnoDataService.instance.phytochemicals;
    final drugLikeCount = all.where((c) => c.isDrugLike).length;
    final double pct = all.isNotEmpty ? (drugLikeCount / all.length * 100) : 0;

    return Row(
      children: [
        Expanded(
          child: NeoCard(
            color: AppColors.butterYellow,
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
                  'Metabolites Screened',
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
                  '${pct.toStringAsFixed(0)}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Lipinski Drug-Like',
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
            color: AppColors.sageGreen,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Column(
              children: [
                Text(
                  'PubChem',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.solidBlack,
                  ),
                ),
                Text(
                  '2D Structure Engine',
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
              hintText: 'Search by metabolite, SMILES, target, or plant source...',
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
                borderSide: const BorderSide(color: AppColors.sageGreen, width: 2.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chemical Class Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _classes.map((c) {
                final isSelected = _selectedClass == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      c,
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
                        _selectedClass = c;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Lipinski Filter Chips
          Row(
            children: [
              Text(
                'Drug-Likeness: ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.solidBlack,
                ),
              ),
              const SizedBox(width: 4),
              ...['All', 'Drug-like Only', 'With Violations'].map((filter) {
                final isSelected = _selectedLipinskiFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(
                      filter,
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
                        _selectedLipinskiFilter = filter;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundCard(Phytochemical compound) {
    final bool isDrugLike = compound.isDrugLike;
    final drugLikeBadgeColor = isDrugLike ? AppColors.leafGreen : const Color(0xFFE53935);
    final drugLikeBadgeBg = isDrugLike ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeoCard(
        color: AppColors.cardWhite,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Formula & 2D Image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Molecular Structure Thumbnail with 2D / 3D Conformer Toggle
                Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.solidBlack, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          _conformer3dActive.contains(compound.id)
                              ? 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.pubchemCid}/PNG?record_type=3d'
                              : 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.pubchemCid}/PNG',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.bubble_chart_outlined, size: 36, color: AppColors.sageGreen),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_conformer3dActive.contains(compound.id)) {
                            _conformer3dActive.remove(compound.id);
                          } else {
                            _conformer3dActive.add(compound.id);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _conformer3dActive.contains(compound.id)
                              ? AppColors.butterYellow
                              : AppColors.paperCream,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.solidBlack, width: 1),
                        ),
                        child: Text(
                          _conformer3dActive.contains(compound.id) ? '3D CONFORMER' : '2D STRUCTURE',
                          style: GoogleFonts.firaCode(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Name, Plant Source, Class & Formula
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              compound.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.solidBlack,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: drugLikeBadgeBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: drugLikeBadgeColor, width: 1.5),
                            ),
                            child: Text(
                              isDrugLike ? 'DRUG-LIKE' : '${compound.lipinskiViolations} VIOLATION',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: drugLikeBadgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Botanical Source: ${compound.plantSources.join(", ")}',
                        style: GoogleFonts.questrial(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.leafGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Class: ${compound.chemicalClass}',
                            style: GoogleFonts.questrial(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  Formula: ${compound.molecularFormula}',
                            style: GoogleFonts.questrial(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.solidBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PubChem CID: ${compound.pubchemCid}',
                        style: GoogleFonts.questrial(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Lipinski Rule of 5 Matrix Grid
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.paperCream.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.solidBlack, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rule_folder_outlined, size: 14, color: AppColors.solidBlack),
                      const SizedBox(width: 6),
                      Text(
                        'LIPINSKI RULE OF 5 DESCRIPTORS (IN-SILICO)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDescriptorItem('MW (Da)', '${compound.molecularWeight}', compound.molecularWeight <= 500),
                      _buildDescriptorItem('LogP', '${compound.logP}', compound.logP <= 5.0),
                      _buildDescriptorItem('HBD', '${compound.hBondDonors}', compound.hBondDonors <= 5),
                      _buildDescriptorItem('HBA', '${compound.hBondAcceptors}', compound.hBondAcceptors <= 10),
                      _buildDescriptorItem('TPSA (Å²)', '${compound.tpsa}', compound.tpsa <= 140),
                      _buildDescriptorItem('RotBonds', '${compound.rotatableBonds}', compound.rotatableBonds <= 10),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Biological Activity & Targets
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.track_changes_outlined, size: 16, color: AppColors.dustyCoral),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.questrial(fontSize: 12, color: AppColors.solidBlack),
                      children: [
                        TextSpan(
                          text: 'Target Protein: ',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${compound.primaryTarget}\n',
                          style: GoogleFonts.questrial(fontWeight: FontWeight.w600, color: AppColors.dustyCoral),
                        ),
                        TextSpan(
                          text: 'Bioactivity: ',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: compound.biologicalActivity,
                          style: GoogleFonts.questrial(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SMILES String & Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.solidBlack, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, size: 14, color: AppColors.solidBlack),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      compound.smiles,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 14, color: AppColors.solidBlack),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy SMILES',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: compound.smiles));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied SMILES for ${compound.name} to clipboard!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Ask PhytoDoc AI Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  final prompt =
                      'Please provide a comprehensive cheminformatics and pharmacological evaluation of "${compound.name}" (SMILES: ${compound.smiles}) isolated from ${compound.plantSources.join(", ")}. Detail its molecular target binding and in-silico drug likeness.';
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
                icon: const Icon(Icons.psychology_outlined, size: 16, color: AppColors.solidBlack),
                label: Text(
                  'Analyze with PhytoDoc AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.sageGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.solidBlack, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptorItem(String label, String value, bool pass) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: pass ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: pass ? AppColors.leafGreen : const Color(0xFFE53935),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.firaCode(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: pass ? AppColors.leafGreen : const Color(0xFFE53935),
            ),
          ),
        ),
      ],
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
              'No Phytochemical Matches Query',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try clearing filters or search by compound names like "Curcumin", "Withaferin", or "Artemisinin".',
              textAlign: TextAlign.center,
              style: GoogleFonts.questrial(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
