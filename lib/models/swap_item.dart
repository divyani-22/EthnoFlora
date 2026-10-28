enum SwapCategory {
  textbooks,
  labEquipment,
  uniforms,
  electronics,
  notesStationery,
  other,
}

enum ItemCondition {
  likeNew,
  good,
  fair,
}

enum SwapType {
  freeGiveaway,
  itemSwap,
}

class SwapItem {
  final String id;
  final String title;
  final String description;
  final SwapCategory category;
  final ItemCondition condition;
  final SwapType swapType;
  final String campusName;
  final String? swapPreference; // e.g., "Looking for Class 12 NCERT Chemistry" or null for free
  final double wasteDivertedKg; // Estimated kg of landfill waste diverted
  final double co2SavedKg; // Estimated kg of CO2 saved
  final String donorName;
  final String donorId;
  final int donorKarmaScore; // Flora Coins score
  final String? donorAvatarUrl;
  final String imageUrl;
  final DateTime createdAt;
  bool isAvailable;
  String status; // 'available', 'requested', 'handover_agreed', 'completed'

  SwapItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.swapType,
    required this.campusName,
    this.swapPreference,
    required this.wasteDivertedKg,
    required this.co2SavedKg,
    required this.donorName,
    required this.donorId,
    required this.donorKarmaScore,
    this.donorAvatarUrl,
    required this.imageUrl,
    required this.createdAt,
    this.isAvailable = true,
    this.status = 'available',
  });

  String get categoryDisplay {
    switch (category) {
      case SwapCategory.textbooks:
        return 'Textbooks';
      case SwapCategory.labEquipment:
        return 'Lab Equipment';
      case SwapCategory.uniforms:
        return 'Uniforms & Coats';
      case SwapCategory.electronics:
        return 'Electronics & Calculators';
      case SwapCategory.notesStationery:
        return 'Notes & Stationery';
      case SwapCategory.other:
        return 'Other';
    }
  }

  String get conditionDisplay {
    switch (condition) {
      case ItemCondition.likeNew:
        return 'Like New';
      case ItemCondition.good:
        return 'Good';
      case ItemCondition.fair:
        return 'Fair';
    }
  }

  String get swapTypeDisplay {
    return swapType == SwapType.freeGiveaway ? 'Free Giveaway' : 'Item Swap';
  }

  static double estimateWaste(SwapCategory category) {
    switch (category) {
      case SwapCategory.textbooks:
        return 1.4; // Average weight of textbook in kg
      case SwapCategory.labEquipment:
        return 0.8; // Lab glass/tools
      case SwapCategory.uniforms:
        return 0.6; // Uniform/lab coat
      case SwapCategory.electronics:
        return 0.3; // Calculator/gadget
      case SwapCategory.notesStationery:
        return 0.9; // Register/binders
      case SwapCategory.other:
        return 1.0;
    }
  }

  static double estimateCo2(SwapCategory category) {
    // Manufacturing CO2 emission factors per kg of recycled product
    return double.parse((estimateWaste(category) * 2.2).toStringAsFixed(1));
  }
}
