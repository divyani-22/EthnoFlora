import 'package:flutter_test/flutter_test.dart';
import 'package:ethnoflora/models/medicinal_plant.dart';
import 'package:ethnoflora/models/phytochemical.dart';
import 'package:ethnoflora/models/herb_drug_interaction.dart';
import 'package:ethnoflora/services/ethno_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EthnoFlora Models Tests', () {
    test('MedicinalPlant fromJson and toJson serialization', () {
      final jsonMap = {
        'id': 'plant_1',
        'commonName': 'Neem',
        'scientificName': 'Azadirachta indica',
        'family': 'Meliaceae',
        'traditionalSystem': 'Ayurveda',
        'traditionalUses': 'Skin conditions, dental care, diabetes',
        'plantPartsUsed': ['Leaves', 'Bark', 'Oil'],
        'activeMetabolites': ['Azadirachtin', 'Nimbin'],
        'molecularTargets': ['MAPK', 'IKK'],
        'iucnStatus': 'Least Concern',
        'nativeRegion': 'Indian Subcontinent',
        'gbifCoordinates': {
          'latitude': 20.5937,
          'longitude': 78.9629,
          'locality': 'India',
        },
        'harvestingRisk': 'Low',
        'nagoyaAbsStatus': 'Compliant',
        'evidenceGrade': 'Grade B',
        'whoMonographAvailable': true,
        'summary': 'Broad spectrum therapeutic tree.',
      };

      final plant = MedicinalPlant.fromJson(jsonMap);
      expect(plant.id, 'plant_1');
      expect(plant.commonName, 'Neem');
      expect(plant.plantPartsUsed.length, 3);
      expect(plant.gbifCoordinates?.latitude, 20.5937);
      expect(plant.whoMonographAvailable, isTrue);

      final exported = plant.toJson();
      expect(exported['id'], 'plant_1');
      expect(exported['scientificName'], 'Azadirachta indica');
      expect(exported['gbifCoordinates']['locality'], 'India');
    });

    test('Phytochemical fromJson and toJson serialization', () {
      final jsonMap = {
        'id': 'phyto_1',
        'name': 'Berberine',
        'plantSources': ['Berberis aristata', 'Hydrastis canadensis'],
        'chemicalClass': 'Isoquinoline Alkaloid',
        'molecularFormula': 'C20H18NO4+',
        'smiles': 'COC1=C(C2=C[N+]3=C(C=C2C=C1)C4=CC5=C(C=C4CC3)OCO5)OC',
        'inchikey': 'PBMIPKDPDLTXFZ-UHFFFAOYSA-N',
        'pubchemCid': 2353,
        'molecularWeight': 336.4,
        'logP': 2.5,
        'hBondDonors': 0,
        'hBondAcceptors': 4,
        'tpsa': 40.8,
        'rotatableBonds': 2,
        'lipinskiViolations': 0,
        'isDrugLike': true,
        'primaryTarget': 'AMPK / PCSK9',
        'biologicalActivity': 'Hypoglycemic, lipid-lowering, antimicrobial',
      };

      final compound = Phytochemical.fromJson(jsonMap);
      expect(compound.id, 'phyto_1');
      expect(compound.name, 'Berberine');
      expect(compound.pubchemCid, 2353);
      expect(compound.molecularWeight, 336.4);
      expect(compound.isDrugLike, isTrue);

      final exported = compound.toJson();
      expect(exported['name'], 'Berberine');
      expect(exported['chemicalClass'], 'Isoquinoline Alkaloid');
    });

    test('HerbDrugInteraction fromJson and toJson serialization', () {
      final jsonMap = {
        'id': 'hdi_1',
        'herbName': 'Ginkgo',
        'botanicalName': 'Ginkgo biloba',
        'prescriptionDrug': 'Aspirin',
        'drugClass': 'Antiplatelet',
        'severity': 'Moderate',
        'cypMechanism': 'Platelet-activating factor antagonism',
        'clinicalEffect': 'Increased bleeding time',
        'managementRecommendation': 'Monitor for signs of hemorrhage',
        'evidenceLevel': 'Moderate',
      };

      final interaction = HerbDrugInteraction.fromJson(jsonMap);
      expect(interaction.id, 'hdi_1');
      expect(interaction.herbName, 'Ginkgo');
      expect(interaction.prescriptionDrug, 'Aspirin');
      expect(interaction.severity, 'Moderate');

      final exported = interaction.toJson();
      expect(exported['id'], 'hdi_1');
      expect(exported['botanicalName'], 'Ginkgo biloba');
    });
  });

  group('EthnoDataService Service and Fallback Tests', () {
    test('Fallback initialization and query tests', () async {
      final service = EthnoDataService();
      await service.init();

      expect(service.isInitialized, isTrue);
      expect(service.plants.isNotEmpty, isTrue);
      expect(service.phytochemicals.isNotEmpty, isTrue);
      expect(service.interactions.isNotEmpty, isTrue);

      // Search plants
      final ashwaSearch = service.searchPlants('Ashwagandha');
      expect(ashwaSearch.isNotEmpty, isTrue);
      expect(ashwaSearch.first.commonName, 'Ashwagandha');

      // Search by metabolite
      final metaboliteSearch = service.searchPlants('Withaferin A');
      expect(metaboliteSearch.isNotEmpty, isTrue);

      // Get plant by id
      final plant = service.getPlantById('plant_withania_somnifera') ??
          service.getPlantById('plant_ashwagandha');
      expect(plant, isNotNull);
      expect(plant?.scientificName.contains('Withania somnifera'), isTrue);

      // Filter by IUCN
      final iucnPlants = service.filterPlantsByIucn('Least Concern');
      expect(iucnPlants.isNotEmpty, isTrue);

      // Search phytochemicals
      final phytoResults = service.searchPhytochemicals('Curcumin');
      expect(phytoResults.isNotEmpty, isTrue);
      expect(phytoResults.first.molecularFormula, 'C21H20O6');

      // Get phytochemicals for plant
      final plantPhyto = service.getPhytochemicalsForPlant('Curcuma');
      expect(plantPhyto.isNotEmpty, isTrue);
      expect(plantPhyto.first.name, 'Curcumin');

      // Check drug interactions
      final interactionsHerb =
          service.checkDrugInteractions(herbQuery: 'St. John');
      expect(interactionsHerb.isNotEmpty, isTrue);

      final interactionsDrug =
          service.checkDrugInteractions(drugQuery: 'Cyclosporine');
      expect(interactionsDrug.isNotEmpty, isTrue);

      final combinedCheck = service.checkDrugInteractions(
        herbQuery: 'St. John',
        drugQuery: 'Cyclosporine',
      );
      expect(combinedCheck.isNotEmpty, isTrue);
    });
  });
}
