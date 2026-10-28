/// GbifCoordinates represents geospatial coordinates and locality from GBIF.
class GbifCoordinates {
  final double latitude;
  final double longitude;
  final String locality;

  const GbifCoordinates({
    required this.latitude,
    required this.longitude,
    required this.locality,
  });

  factory GbifCoordinates.fromJson(Map<String, dynamic> json) {
    return GbifCoordinates(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locality: (json['locality'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'locality': locality,
    };
  }

  @override
  String toString() =>
      'GbifCoordinates(latitude: $latitude, longitude: $longitude, locality: $locality)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GbifCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          locality == other.locality;

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ locality.hashCode;
}

/// MedicinalPlant model representing an ethnobotanical medicinal plant.
class MedicinalPlant {
  final String id;
  final String commonName;
  final String scientificName;
  final String family;
  final String traditionalSystem;
  final String traditionalUses;
  final List<String> plantPartsUsed;
  final List<String> activeMetabolites;
  final List<String> molecularTargets;
  final String iucnStatus;
  final String nativeRegion;
  final GbifCoordinates? gbifCoordinates;
  final String harvestingRisk;
  final String nagoyaAbsStatus;
  final String evidenceGrade;
  final bool whoMonographAvailable;
  final String summary;

  const MedicinalPlant({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.traditionalSystem,
    required this.traditionalUses,
    required this.plantPartsUsed,
    required this.activeMetabolites,
    required this.molecularTargets,
    required this.iucnStatus,
    required this.nativeRegion,
    this.gbifCoordinates,
    required this.harvestingRisk,
    required this.nagoyaAbsStatus,
    required this.evidenceGrade,
    required this.whoMonographAvailable,
    required this.summary,
  });

  /// Factory constructor to parse a [MedicinalPlant] from JSON map.
  /// Seamlessly handles both camelCase and snake_case JSON schemas.
  factory MedicinalPlant.fromJson(Map<String, dynamic> json) {
    // Parse traditionalUses whether provided as String or List
    final rawUses = json['traditional_uses'] ?? json['traditionalUses'];
    String parsedTraditionalUses = '';
    if (rawUses is List) {
      parsedTraditionalUses =
          rawUses.map((e) => e.toString()).join(', ');
    } else if (rawUses != null) {
      parsedTraditionalUses = rawUses.toString();
    }

    // Parse GBIF coordinates
    final rawGbif = json['gbif_coordinates'] ?? json['gbifCoordinates'];
    GbifCoordinates? parsedGbif;
    if (rawGbif is Map) {
      parsedGbif = GbifCoordinates.fromJson(
        Map<String, dynamic>.from(rawGbif),
      );
    }

    final rawParts = json['plant_parts_used'] ?? json['plantPartsUsed'];
    final rawMetabolites =
        json['active_metabolites'] ?? json['activeMetabolites'];
    final rawTargets = json['molecular_targets'] ?? json['molecularTargets'];
    final rawWho =
        json['who_monograph_available'] ?? json['whoMonographAvailable'];

    return MedicinalPlant(
      id: (json['id'] ?? '').toString(),
      commonName:
          (json['common_name'] ?? json['commonName'] ?? '').toString(),
      scientificName:
          (json['scientific_name'] ?? json['scientificName'] ?? '').toString(),
      family: (json['family'] ?? '').toString(),
      traditionalSystem:
          (json['traditional_system'] ?? json['traditionalSystem'] ?? '')
              .toString(),
      traditionalUses: parsedTraditionalUses,
      plantPartsUsed: (rawParts as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      activeMetabolites: (rawMetabolites as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      molecularTargets: (rawTargets as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      iucnStatus: (json['iucn_status'] ?? json['iucnStatus'] ?? '').toString(),
      nativeRegion:
          (json['native_region'] ?? json['nativeRegion'] ?? '').toString(),
      gbifCoordinates: parsedGbif,
      harvestingRisk:
          (json['harvesting_risk'] ?? json['harvestingRisk'] ?? '').toString(),
      nagoyaAbsStatus:
          (json['nagoya_abs_status'] ?? json['nagoyaAbsStatus'] ?? '')
              .toString(),
      evidenceGrade:
          (json['evidence_grade'] ?? json['evidenceGrade'] ?? '').toString(),
      whoMonographAvailable: rawWho == true ||
          rawWho?.toString().toLowerCase() == 'true',
      summary: (json['summary'] ?? '').toString(),
    );
  }

  /// Converts this [MedicinalPlant] instance into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commonName': commonName,
      'scientificName': scientificName,
      'family': family,
      'traditionalSystem': traditionalSystem,
      'traditionalUses': traditionalUses,
      'plantPartsUsed': plantPartsUsed,
      'activeMetabolites': activeMetabolites,
      'molecularTargets': molecularTargets,
      'iucnStatus': iucnStatus,
      'nativeRegion': nativeRegion,
      'gbifCoordinates': gbifCoordinates?.toJson(),
      'harvestingRisk': harvestingRisk,
      'nagoyaAbsStatus': nagoyaAbsStatus,
      'evidenceGrade': evidenceGrade,
      'whoMonographAvailable': whoMonographAvailable,
      'summary': summary,
    };
  }

  /// Helper getter returning gbif coordinates as a map if present
  Map<String, dynamic>? get gbifCoordinatesMap => gbifCoordinates?.toJson();

  /// Helper getter returning traditional uses split as a list
  List<String> get traditionalUsesList {
    if (traditionalUses.isEmpty) return const [];
    return traditionalUses
        .split(RegExp(r',\s*'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  MedicinalPlant copyWith({
    String? id,
    String? commonName,
    String? scientificName,
    String? family,
    String? traditionalSystem,
    String? traditionalUses,
    List<String>? plantPartsUsed,
    List<String>? activeMetabolites,
    List<String>? molecularTargets,
    String? iucnStatus,
    String? nativeRegion,
    GbifCoordinates? gbifCoordinates,
    String? harvestingRisk,
    String? nagoyaAbsStatus,
    String? evidenceGrade,
    bool? whoMonographAvailable,
    String? summary,
  }) {
    return MedicinalPlant(
      id: id ?? this.id,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      family: family ?? this.family,
      traditionalSystem: traditionalSystem ?? this.traditionalSystem,
      traditionalUses: traditionalUses ?? this.traditionalUses,
      plantPartsUsed: plantPartsUsed ?? this.plantPartsUsed,
      activeMetabolites: activeMetabolites ?? this.activeMetabolites,
      molecularTargets: molecularTargets ?? this.molecularTargets,
      iucnStatus: iucnStatus ?? this.iucnStatus,
      nativeRegion: nativeRegion ?? this.nativeRegion,
      gbifCoordinates: gbifCoordinates ?? this.gbifCoordinates,
      harvestingRisk: harvestingRisk ?? this.harvestingRisk,
      nagoyaAbsStatus: nagoyaAbsStatus ?? this.nagoyaAbsStatus,
      evidenceGrade: evidenceGrade ?? this.evidenceGrade,
      whoMonographAvailable:
          whoMonographAvailable ?? this.whoMonographAvailable,
      summary: summary ?? this.summary,
    );
  }

  @override
  String toString() =>
      'MedicinalPlant(id: $id, commonName: $commonName, scientificName: $scientificName)';
}
