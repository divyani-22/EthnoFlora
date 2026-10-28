/// HerbDrugInteraction model representing clinical interactions between herbal remedies and prescription pharmaceuticals.
class HerbDrugInteraction {
  final String id;
  final String herbName;
  final String botanicalName;
  final String prescriptionDrug;
  final String drugClass;
  final String severity; // High, Moderate, Low, etc.
  final String cypMechanism; // e.g. CYP3A4 inhibition/induction
  final String clinicalEffect;
  final String managementRecommendation;
  final String evidenceLevel;

  const HerbDrugInteraction({
    required this.id,
    required this.herbName,
    required this.botanicalName,
    required this.prescriptionDrug,
    required this.drugClass,
    required this.severity,
    required this.cypMechanism,
    required this.clinicalEffect,
    required this.managementRecommendation,
    required this.evidenceLevel,
  });

  /// Factory constructor to parse a [HerbDrugInteraction] from a JSON map.
  /// Seamlessly supports both camelCase and snake_case JSON schemas.
  factory HerbDrugInteraction.fromJson(Map<String, dynamic> json) {
    return HerbDrugInteraction(
      id: (json['id'] ?? '').toString(),
      herbName:
          (json['herb_name'] ?? json['herbName'] ?? '').toString(),
      botanicalName:
          (json['botanical_name'] ?? json['botanicalName'] ?? '').toString(),
      prescriptionDrug:
          (json['prescription_drug'] ?? json['prescriptionDrug'] ?? '')
              .toString(),
      drugClass:
          (json['drug_class'] ?? json['drugClass'] ?? '').toString(),
      severity: (json['severity'] ?? '').toString(),
      cypMechanism:
          (json['cyp_mechanism'] ?? json['cypMechanism'] ?? '').toString(),
      clinicalEffect:
          (json['clinical_effect'] ?? json['clinicalEffect'] ?? '').toString(),
      managementRecommendation: (json['management_recommendation'] ??
              json['managementRecommendation'] ??
              '')
          .toString(),
      evidenceLevel:
          (json['evidence_level'] ?? json['evidenceLevel'] ?? '').toString(),
    );
  }

  /// Converts this [HerbDrugInteraction] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'herbName': herbName,
      'botanicalName': botanicalName,
      'prescriptionDrug': prescriptionDrug,
      'drugClass': drugClass,
      'severity': severity,
      'cypMechanism': cypMechanism,
      'clinicalEffect': clinicalEffect,
      'managementRecommendation': managementRecommendation,
      'evidenceLevel': evidenceLevel,
    };
  }

  HerbDrugInteraction copyWith({
    String? id,
    String? herbName,
    String? botanicalName,
    String? prescriptionDrug,
    String? drugClass,
    String? severity,
    String? cypMechanism,
    String? clinicalEffect,
    String? managementRecommendation,
    String? evidenceLevel,
  }) {
    return HerbDrugInteraction(
      id: id ?? this.id,
      herbName: herbName ?? this.herbName,
      botanicalName: botanicalName ?? this.botanicalName,
      prescriptionDrug: prescriptionDrug ?? this.prescriptionDrug,
      drugClass: drugClass ?? this.drugClass,
      severity: severity ?? this.severity,
      cypMechanism: cypMechanism ?? this.cypMechanism,
      clinicalEffect: clinicalEffect ?? this.clinicalEffect,
      managementRecommendation:
          managementRecommendation ?? this.managementRecommendation,
      evidenceLevel: evidenceLevel ?? this.evidenceLevel,
    );
  }

  @override
  String toString() =>
      'HerbDrugInteraction(herb: $herbName, drug: $prescriptionDrug, severity: $severity)';
}
