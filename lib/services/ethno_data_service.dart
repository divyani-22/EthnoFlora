import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/herb_drug_interaction.dart';
import '../models/medicinal_plant.dart';
import '../models/phytochemical.dart';

/// Central singleton data service for EthnoFlora AI.
/// Loads and caches ethnobotanical plants, phytochemicals, and herb-drug interactions.
class EthnoDataService {
  // Singleton instance
  static final EthnoDataService _instance = EthnoDataService._internal();
  factory EthnoDataService() => _instance;
  EthnoDataService._internal();

  /// Static accessor for convenience
  static EthnoDataService get instance => _instance;

  // Cached data lists
  List<MedicinalPlant> _plants = [];
  List<Phytochemical> _phytochemicals = [];
  List<HerbDrugInteraction> _interactions = [];

  bool _isInitialized = false;

  /// Whether the data has been loaded into memory
  bool get isInitialized => _isInitialized;

  /// Unmodifiable view of cached medicinal plants
  List<MedicinalPlant> get plants => List.unmodifiable(_plants);

  /// Unmodifiable view of cached phytochemicals
  List<Phytochemical> get phytochemicals => List.unmodifiable(_phytochemicals);

  /// Unmodifiable view of cached herb-drug interactions
  List<HerbDrugInteraction> get interactions =>
      List.unmodifiable(_interactions);

  /// Initializes the service by loading all asset datasets.
  Future<void> init() async {
    await loadData();
  }

  /// Alias for init
  Future<void> initialize() async {
    await loadData();
  }

  /// Loads the 3 JSON files using rootBundle and caches them in memory.
  /// Falls back gracefully to default datasets if an asset is missing or corrupted.
  Future<void> loadData({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;

    await Future.wait([
      _loadPlants(),
      _loadPhytochemicals(),
      _loadInteractions(),
    ]);

    _isInitialized = true;
    debugPrint(
      'EthnoDataService: Loaded ${_plants.length} plants, '
      '${_phytochemicals.length} phytochemicals, '
      '${_interactions.length} interactions.',
    );
  }

  /// Loads medicinal plants from assets/data/medicinal_plants.json
  Future<void> _loadPlants() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/medicinal_plants.json');
      final dynamic decoded = json.decode(jsonString);
      final list = _extractList(decoded, ['plants', 'medicinalPlants', 'data']);

      _plants = list
          .whereType<Map>()
          .map((item) =>
              MedicinalPlant.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stack) {
      debugPrint('EthnoDataService: Error loading medicinal_plants.json: $e');
      if (kDebugMode) debugPrint(stack.toString());
      if (_plants.isEmpty) {
        _plants = _getDefaultPlants();
      }
    }
  }

  /// Loads phytochemicals from assets/data/phytochemicals.json
  Future<void> _loadPhytochemicals() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/phytochemicals.json');
      final dynamic decoded = json.decode(jsonString);
      final list =
          _extractList(decoded, ['phytochemicals', 'compounds', 'data']);

      _phytochemicals = list
          .whereType<Map>()
          .map((item) =>
              Phytochemical.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stack) {
      debugPrint('EthnoDataService: Error loading phytochemicals.json: $e');
      if (kDebugMode) debugPrint(stack.toString());
      if (_phytochemicals.isEmpty) {
        _phytochemicals = _getDefaultPhytochemicals();
      }
    }
  }

  /// Loads herb-drug interactions from assets/data/herb_drug_interactions.json
  Future<void> _loadInteractions() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/herb_drug_interactions.json');
      final dynamic decoded = json.decode(jsonString);
      final list = _extractList(
          decoded, ['interactions', 'herbDrugInteractions', 'data']);

      _interactions = list
          .whereType<Map>()
          .map((item) => HerbDrugInteraction.fromJson(
              Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stack) {
      debugPrint(
          'EthnoDataService: Error loading herb_drug_interactions.json: $e');
      if (kDebugMode) debugPrint(stack.toString());
      if (_interactions.isEmpty) {
        _interactions = _getDefaultInteractions();
      }
    }
  }

  /// Extracts a list from either a JSON array or a wrapped JSON object
  List<dynamic> _extractList(dynamic decodedJson, List<String> possibleKeys) {
    if (decodedJson is List) {
      return decodedJson;
    }
    if (decodedJson is Map) {
      for (final key in possibleKeys) {
        if (decodedJson[key] is List) {
          return decodedJson[key] as List;
        }
      }
      for (final val in decodedJson.values) {
        if (val is List) {
          return val;
        }
      }
    }
    return const [];
  }

  // ==========================================
  // Search & Filter Methods
  // ==========================================

  /// Searches medicinal plants by common name, scientific name, traditional system,
  /// family, or active metabolite.
  List<MedicinalPlant> searchPlants(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.unmodifiable(_plants);
    }

    return _plants.where((plant) {
      return plant.commonName.toLowerCase().contains(q) ||
          plant.scientificName.toLowerCase().contains(q) ||
          plant.traditionalSystem.toLowerCase().contains(q) ||
          plant.family.toLowerCase().contains(q) ||
          plant.traditionalUses.toLowerCase().contains(q) ||
          plant.activeMetabolites.any((m) => m.toLowerCase().contains(q));
    }).toList();
  }

  /// Finds a plant by its unique identifier.
  MedicinalPlant? getPlantById(String id) {
    final targetId = id.trim().toLowerCase();
    if (targetId.isEmpty) return null;
    try {
      return _plants.firstWhere(
        (p) => p.id.trim().toLowerCase() == targetId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Filters plants by IUCN red list status (e.g., 'Critically Endangered', 'Vulnerable', 'Least Concern').
  List<MedicinalPlant> filterPlantsByIucn(String status) {
    final s = status.trim().toLowerCase();
    if (s.isEmpty || s == 'all') {
      return List.unmodifiable(_plants);
    }
    return _plants.where((p) => p.iucnStatus.trim().toLowerCase() == s).toList();
  }

  /// Searches phytochemicals by name, chemical class, formula, target, activity, or plant sources.
  List<Phytochemical> searchPhytochemicals(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.unmodifiable(_phytochemicals);
    }

    return _phytochemicals.where((compound) {
      return compound.name.toLowerCase().contains(q) ||
          compound.chemicalClass.toLowerCase().contains(q) ||
          compound.molecularFormula.toLowerCase().contains(q) ||
          compound.primaryTarget.toLowerCase().contains(q) ||
          compound.biologicalActivity.toLowerCase().contains(q) ||
          compound.plantSources.any((source) => source.toLowerCase().contains(q));
    }).toList();
  }

  /// Retrieves all phytochemicals that originate from a specific plant.
  List<Phytochemical> getPhytochemicalsForPlant(String plantName) {
    final pName = plantName.trim().toLowerCase();
    if (pName.isEmpty) return const [];

    return _phytochemicals.where((compound) {
      return compound.plantSources.any((source) {
        final src = source.toLowerCase();
        return src == pName || src.contains(pName) || pName.contains(src);
      });
    }).toList();
  }

  /// Checks for herb-drug interactions matching either the herb name or prescription drug name/class.
  List<HerbDrugInteraction> checkDrugInteractions({
    String? herbQuery,
    String? drugQuery,
  }) {
    final hq = herbQuery?.trim().toLowerCase();
    final dq = drugQuery?.trim().toLowerCase();

    final hasHerb = hq != null && hq.isNotEmpty;
    final hasDrug = dq != null && dq.isNotEmpty;

    if (!hasHerb && !hasDrug) {
      return List.unmodifiable(_interactions);
    }

    return _interactions.where((interaction) {
      bool matchesHerb = true;
      if (hasHerb) {
        matchesHerb = interaction.herbName.toLowerCase().contains(hq) ||
            interaction.botanicalName.toLowerCase().contains(hq);
      }

      bool matchesDrug = true;
      if (hasDrug) {
        matchesDrug = interaction.prescriptionDrug.toLowerCase().contains(dq) ||
            interaction.drugClass.toLowerCase().contains(dq);
      }

      return matchesHerb && matchesDrug;
    }).toList();
  }

  // ==========================================
  // Built-in Graceful Fallback Datasets
  // ==========================================

  List<MedicinalPlant> _getDefaultPlants() {
    return [
      MedicinalPlant(
        id: 'plant_ashwagandha',
        commonName: 'Ashwagandha',
        scientificName: 'Withania somnifera',
        family: 'Solanaceae',
        traditionalSystem: 'Ayurveda',
        traditionalUses:
            'Rasayana (rejuvenator), adaptogen, stress reduction, vitality',
        plantPartsUsed: const ['Roots', 'Leaves'],
        activeMetabolites: const [
          'Withaferin A',
          'Withanolide D',
          'Sitoindoside IX'
        ],
        molecularTargets: const ['GABA-A Receptor', 'Hsp90', 'NF-kB'],
        iucnStatus: 'Least Concern',
        nativeRegion: 'India, Mediterranean, Middle East',
        gbifCoordinates: const GbifCoordinates(
          latitude: 26.9124,
          longitude: 75.7873,
          locality: 'Rajasthan, India',
        ),
        harvestingRisk: 'Moderate due to wild uprooting demand',
        nagoyaAbsStatus: 'Access and Benefit-Sharing Registered under NBA India',
        evidenceGrade: 'Grade A (Multiple RCTs & Meta-analyses)',
        whoMonographAvailable: true,
        summary:
            'Ashwagandha is an ancient medicinal herb revered in Ayurvedic medicine as a potent adaptogen for neuroprotection, stress alleviation, and immune modulation.',
      ),
      MedicinalPlant(
        id: 'plant_tulsi',
        commonName: 'Holy Basil (Tulsi)',
        scientificName: 'Ocimum sanctum',
        family: 'Lamiaceae',
        traditionalSystem: 'Ayurveda & Siddha',
        traditionalUses:
            'Respiratory ailments, cough, fever, anti-stress, immunomodulation',
        plantPartsUsed: const ['Leaves', 'Seeds'],
        activeMetabolites: const ['Eugenol', 'Ursolic acid', 'Rosmarinic acid'],
        molecularTargets: const ['COX-2', 'LOX', 'iNOS'],
        iucnStatus: 'Least Concern',
        nativeRegion: 'Indian Subcontinent, Southeast Asia',
        gbifCoordinates: const GbifCoordinates(
          latitude: 19.0760,
          longitude: 72.8777,
          locality: 'Maharashtra, India',
        ),
        harvestingRisk: 'Low (Widely cultivated)',
        nagoyaAbsStatus: 'Traditional knowledge protected under TKDL',
        evidenceGrade: 'Grade A',
        whoMonographAvailable: true,
        summary:
            'Holy Basil is an aromatic shrub considered sacred and endowed with antimicrobial, adaptogenic, and cardio-protective bioactivities.',
      ),
      MedicinalPlant(
        id: 'plant_turmeric',
        commonName: 'Turmeric (Haridra)',
        scientificName: 'Curcuma longa',
        family: 'Zingiberaceae',
        traditionalSystem: 'Ayurveda, Siddha, Unani',
        traditionalUses:
            'Wound healing, anti-inflammatory, digestive aid, hepatoprotective',
        plantPartsUsed: const ['Rhizome'],
        activeMetabolites: const [
          'Curcumin',
          'Demethoxycurcumin',
          'Bisdemethoxycurcumin'
        ],
        molecularTargets: const ['NF-kB', 'TNF-alpha', 'COX-2', 'STAT3'],
        iucnStatus: 'Data Deficient',
        nativeRegion: 'South Asia',
        gbifCoordinates: const GbifCoordinates(
          latitude: 11.1271,
          longitude: 78.6569,
          locality: 'Tamil Nadu, India',
        ),
        harvestingRisk: 'Low (Widely cultivated)',
        nagoyaAbsStatus: 'Protected under Indian ABS Framework',
        evidenceGrade: 'Grade A',
        whoMonographAvailable: true,
        summary:
            'Curcuma longa rhizome produces curcuminoids with validated antioxidant, chemopreventive, and anti-inflammatory properties.',
      ),
    ];
  }

  List<Phytochemical> _getDefaultPhytochemicals() {
    return [
      const Phytochemical(
        id: 'phyto_withaferin_a',
        name: 'Withaferin A',
        plantSources: ['Withania somnifera', 'Ashwagandha'],
        chemicalClass: 'Steroidal Lactone (Withanolide)',
        molecularFormula: 'C28H38O6',
        smiles: 'CC1C2C(CC3C2(CCC4C3CCC5(C4)OC(=O)C(=C5)C)C)OC(=O)C1(O)C',
        inchikey: 'PPSMQVWCLPWSFY-UHFFFAOYSA-N',
        pubchemCid: 265237,
        molecularWeight: 470.6,
        logP: 3.2,
        hBondDonors: 2,
        hBondAcceptors: 6,
        tpsa: 96.2,
        rotatableBonds: 2,
        lipinskiViolations: 0,
        isDrugLike: true,
        primaryTarget: 'Hsp90 / Vimentin',
        biologicalActivity: 'Anti-inflammatory, Anti-tumor, Neuroprotective',
      ),
      const Phytochemical(
        id: 'phyto_curcumin',
        name: 'Curcumin',
        plantSources: ['Curcuma longa', 'Turmeric'],
        chemicalClass: 'Diarylheptanoid',
        molecularFormula: 'C21H20O6',
        smiles: 'COC1=C(C=CC(=C1)/C=C/C(=O)CC(=O)/C=C/C2=CC(=C(C=C2)O)OC)O',
        inchikey: 'WHKOWTPKCNVTKC-UHFFFAOYSA-N',
        pubchemCid: 969516,
        molecularWeight: 368.38,
        logP: 3.29,
        hBondDonors: 2,
        hBondAcceptors: 6,
        tpsa: 93.1,
        rotatableBonds: 8,
        lipinskiViolations: 0,
        isDrugLike: true,
        primaryTarget: 'NF-kB p65 / COX-2',
        biologicalActivity: 'Anti-inflammatory, Antioxidant, Antiproliferative',
      ),
      const Phytochemical(
        id: 'phyto_eugenol',
        name: 'Eugenol',
        plantSources: ['Ocimum sanctum', 'Tulsi', 'Syzygium aromaticum'],
        chemicalClass: 'Phenylpropanoid',
        molecularFormula: 'C10H12O2',
        smiles: 'COC1=C(C=CC(=C1)CC=C)O',
        inchikey: 'WFDXOXNFNRHQEC-UHFFFAOYSA-N',
        pubchemCid: 3314,
        molecularWeight: 164.2,
        logP: 2.27,
        hBondDonors: 1,
        hBondAcceptors: 2,
        tpsa: 29.5,
        rotatableBonds: 3,
        lipinskiViolations: 0,
        isDrugLike: true,
        primaryTarget: 'TRPV1 / COX-1',
        biologicalActivity: 'Analgesic, Antiseptic, Anti-inflammatory',
      ),
    ];
  }

  List<HerbDrugInteraction> _getDefaultInteractions() {
    return [
      const HerbDrugInteraction(
        id: 'hdi_ashwa_sedatives',
        herbName: 'Ashwagandha',
        botanicalName: 'Withania somnifera',
        prescriptionDrug: 'Diazepam / Lorazepam',
        drugClass: 'Benzodiazepines / CNS Depressants',
        severity: 'Moderate',
        cypMechanism: 'Additive GABAergic agonism & CNS depression',
        clinicalEffect:
            'Potentiates sedative effects leading to excessive somnolence and psychomotor impairment.',
        managementRecommendation:
            'Avoid co-administration or monitor sedation closely; reduce sedative dose if necessary.',
        evidenceLevel: 'Moderate (Animal studies & Clinical case reports)',
      ),
      const HerbDrugInteraction(
        id: 'hdi_turmeric_warfarin',
        herbName: 'Turmeric / Curcumin',
        botanicalName: 'Curcuma longa',
        prescriptionDrug: 'Warfarin',
        drugClass: 'Anticoagulant',
        severity: 'High',
        cypMechanism: 'CYP2C9 inhibition & platelet aggregation inhibition',
        clinicalEffect:
            'Increased free warfarin serum concentration and elevated INR, leading to hemorrhage risk.',
        managementRecommendation:
            'Avoid high-dose curcumin supplements; monitor INR frequently if combined.',
        evidenceLevel: 'High (Documented pharmacokinetic interaction & case series)',
      ),
      const HerbDrugInteraction(
        id: 'hdi_tulsi_antidiabetics',
        herbName: 'Tulsi',
        botanicalName: 'Ocimum sanctum',
        prescriptionDrug: 'Metformin / Glipizide',
        drugClass: 'Antidiabetic agents',
        severity: 'Moderate',
        cypMechanism: 'Additive insulin secretagogue and hypoglycemic synergy',
        clinicalEffect:
            'Potential synergistic blood glucose lowering increasing hypoglycemia risk.',
        managementRecommendation:
            'Regularly monitor blood glucose levels and adjust pharmaceutical dosing as needed.',
        evidenceLevel: 'Moderate (Controlled trials & animal models)',
      ),
    ];
  }
}
