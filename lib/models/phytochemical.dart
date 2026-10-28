/// Phytochemical model representing an active bio-compound identified in plants.
class Phytochemical {
  final String id;
  final String name;
  final List<String> plantSources;
  final String chemicalClass;
  final String molecularFormula;
  final String smiles;
  final String inchikey;
  final int pubchemCid;
  final double molecularWeight;
  final double logP;
  final int hBondDonors;
  final int hBondAcceptors;
  final double tpsa;
  final int rotatableBonds;
  final int lipinskiViolations;
  final bool isDrugLike;
  final String primaryTarget;
  final String biologicalActivity;

  const Phytochemical({
    required this.id,
    required this.name,
    required this.plantSources,
    required this.chemicalClass,
    required this.molecularFormula,
    required this.smiles,
    required this.inchikey,
    required this.pubchemCid,
    required this.molecularWeight,
    required this.logP,
    required this.hBondDonors,
    required this.hBondAcceptors,
    required this.tpsa,
    required this.rotatableBonds,
    required this.lipinskiViolations,
    required this.isDrugLike,
    required this.primaryTarget,
    required this.biologicalActivity,
  });

  /// Factory constructor to create a [Phytochemical] from a JSON map.
  /// Seamlessly supports both camelCase and snake_case JSON schemas.
  factory Phytochemical.fromJson(Map<String, dynamic> json) {
    final rawPlantSources =
        json['plant_sources'] ?? json['plantSources'];
    final rawChemicalClass =
        json['chemical_class'] ?? json['chemicalClass'];
    final rawFormula =
        json['molecular_formula'] ?? json['molecularFormula'];
    final rawPubchem =
        json['pubchem_cid'] ?? json['pubchemCid'];
    final rawMw =
        json['molecular_weight'] ?? json['molecularWeight'];
    final rawLogP =
        json['logp'] ?? json['logP'];
    final rawHbd =
        json['h_bond_donors'] ?? json['hBondDonors'];
    final rawHba =
        json['h_bond_acceptors'] ?? json['hBondAcceptors'];
    final rawRb =
        json['rotatable_bonds'] ?? json['rotatableBonds'];
    final rawLipinski =
        json['lipinski_violations'] ?? json['lipinskiViolations'];
    final rawDrugLike =
        json['is_druglike'] ?? json['isDrugLike'];
    final rawPrimaryTarget =
        json['primary_target'] ?? json['primaryTarget'];
    final rawActivity =
        json['biological_activity'] ?? json['biologicalActivity'];

    return Phytochemical(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      plantSources: (rawPlantSources as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      chemicalClass: (rawChemicalClass ?? '').toString(),
      molecularFormula: (rawFormula ?? '').toString(),
      smiles: (json['smiles'] ?? '').toString(),
      inchikey: (json['inchikey'] ?? '').toString(),
      pubchemCid: (rawPubchem as num?)?.toInt() ?? 0,
      molecularWeight: (rawMw as num?)?.toDouble() ?? 0.0,
      logP: (rawLogP as num?)?.toDouble() ?? 0.0,
      hBondDonors: (rawHbd as num?)?.toInt() ?? 0,
      hBondAcceptors: (rawHba as num?)?.toInt() ?? 0,
      tpsa: (json['tpsa'] as num?)?.toDouble() ?? 0.0,
      rotatableBonds: (rawRb as num?)?.toInt() ?? 0,
      lipinskiViolations: (rawLipinski as num?)?.toInt() ?? 0,
      isDrugLike: rawDrugLike == true ||
          rawDrugLike?.toString().toLowerCase() == 'true',
      primaryTarget: (rawPrimaryTarget ?? '').toString(),
      biologicalActivity: (rawActivity ?? '').toString(),
    );
  }

  /// Converts this [Phytochemical] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantSources': plantSources,
      'chemicalClass': chemicalClass,
      'molecularFormula': molecularFormula,
      'smiles': smiles,
      'inchikey': inchikey,
      'pubchemCid': pubchemCid,
      'molecularWeight': molecularWeight,
      'logP': logP,
      'hBondDonors': hBondDonors,
      'hBondAcceptors': hBondAcceptors,
      'tpsa': tpsa,
      'rotatableBonds': rotatableBonds,
      'lipinskiViolations': lipinskiViolations,
      'isDrugLike': isDrugLike,
      'primaryTarget': primaryTarget,
      'biologicalActivity': biologicalActivity,
    };
  }

  Phytochemical copyWith({
    String? id,
    String? name,
    List<String>? plantSources,
    String? chemicalClass,
    String? molecularFormula,
    String? smiles,
    String? inchikey,
    int? pubchemCid,
    double? molecularWeight,
    double? logP,
    int? hBondDonors,
    int? hBondAcceptors,
    double? tpsa,
    int? rotatableBonds,
    int? lipinskiViolations,
    bool? isDrugLike,
    String? primaryTarget,
    String? biologicalActivity,
  }) {
    return Phytochemical(
      id: id ?? this.id,
      name: name ?? this.name,
      plantSources: plantSources ?? this.plantSources,
      chemicalClass: chemicalClass ?? this.chemicalClass,
      molecularFormula: molecularFormula ?? this.molecularFormula,
      smiles: smiles ?? this.smiles,
      inchikey: inchikey ?? this.inchikey,
      pubchemCid: pubchemCid ?? this.pubchemCid,
      molecularWeight: molecularWeight ?? this.molecularWeight,
      logP: logP ?? this.logP,
      hBondDonors: hBondDonors ?? this.hBondDonors,
      hBondAcceptors: hBondAcceptors ?? this.hBondAcceptors,
      tpsa: tpsa ?? this.tpsa,
      rotatableBonds: rotatableBonds ?? this.rotatableBonds,
      lipinskiViolations: lipinskiViolations ?? this.lipinskiViolations,
      isDrugLike: isDrugLike ?? this.isDrugLike,
      primaryTarget: primaryTarget ?? this.primaryTarget,
      biologicalActivity: biologicalActivity ?? this.biologicalActivity,
    );
  }

  @override
  String toString() =>
      'Phytochemical(id: $id, name: $name, formula: $molecularFormula, mw: $molecularWeight)';
}
