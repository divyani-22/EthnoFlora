import 'package:flutter/material.dart';

class RewardItem {
  final String id;
  final String title;
  final String description;
  final int coinsCost;
  final IconData icon;
  final String category; // 'Herbarium', 'Taxonomy', 'Cheminformatics', 'Nagoya ABS'
  final String badgeLabel;
  final String voucherInstructions;
  final Color accentColor;

  const RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.coinsCost,
    required this.icon,
    required this.category,
    required this.badgeLabel,
    required this.voucherInstructions,
    required this.accentColor,
  });

  // Alias for backward compatibility
  int get karmaCost => coinsCost;
}

class RedeemedVoucher {
  final String id;
  final String rewardId;
  final String rewardTitle;
  final String voucherCode;
  final int coinsSpent;
  final DateTime redeemedAt;
  final String instructions;
  final bool isUsed;

  const RedeemedVoucher({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.voucherCode,
    required this.coinsSpent,
    required this.redeemedAt,
    required this.instructions,
    this.isUsed = false,
  });

  int get karmaSpent => coinsSpent;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'voucherCode': voucherCode,
      'coinsSpent': coinsSpent,
      'redeemedAt': redeemedAt.toIso8601String(),
      'instructions': instructions,
      'isUsed': isUsed,
    };
  }

  factory RedeemedVoucher.fromMap(Map<String, dynamic> map) {
    return RedeemedVoucher(
      id: map['id']?.toString() ?? '',
      rewardId: map['rewardId']?.toString() ?? '',
      rewardTitle: map['rewardTitle']?.toString() ?? '',
      voucherCode: map['voucherCode']?.toString() ?? '',
      coinsSpent: (map['coinsSpent'] ?? map['karmaSpent'] as num?)?.toInt() ?? 0,
      redeemedAt: map['redeemedAt'] is DateTime
          ? map['redeemedAt'] as DateTime
          : (DateTime.tryParse(map['redeemedAt']?.toString() ?? '') ?? DateTime.now()),
      instructions: map['instructions']?.toString() ?? '',
      isUsed: map['isUsed'] == true,
    );
  }
}
