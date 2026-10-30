import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_item.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  static const String _vouchersPrefKey = 'ethnoflora_redeemed_vouchers';

  final List<RewardItem> availableRewards = const [
    RewardItem(
      id: 'reward_press_100',
      title: 'Herbarium Specimen Voucher Press & Drying Kit',
      description: 'Standard botanical field press with moisture-absorbent blotting boards and geo-tagging labels for wild ethnobotanical voucher collection.',
      karmaCost: 100,
      icon: Icons.spa_rounded,
      category: 'Herbarium',
      badgeLabel: 'Field Voucher Tool',
      voucherInstructions: 'Present this digital voucher to the Botanical Field Station Coordinator or Herbarium Curator to collect your specimen press kit.',
      accentColor: AppColors.sageGreen,
    ),
    RewardItem(
      id: 'reward_powo_150',
      title: 'POWO Binomial Taxonomy Verification Credit',
      description: 'Submit an unverified field specimen to Kew POWO taxonomists for certified binomial botanical identification and accession cataloging.',
      karmaCost: 150,
      icon: Icons.verified_rounded,
      category: 'Taxonomy',
      badgeLabel: 'Botanical Validation',
      voucherInstructions: 'Upload your high-res field photo and enter this voucher code in the POWO Taxonomic Clearing Portal for priority expert accession.',
      accentColor: AppColors.butterYellow,
    ),
    RewardItem(
      id: 'reward_lcms_250',
      title: 'LC-MS/GC-MS Metabolite Fingerprint Analysis',
      description: 'Subsidized mass spectrometry analysis for secondary bioactive metabolites (alkaloids, flavonoids, terpenoids) at a partner analytical lab.',
      karmaCost: 250,
      icon: Icons.science_rounded,
      category: 'Cheminformatics',
      badgeLabel: 'Analytical Mass-Spec',
      voucherInstructions: 'Quote this grant allocation code when shipping 500mg powdered leaf extract to the Partner Regional Natural Products Mass-Spec Facility.',
      accentColor: AppColors.dustyCoral,
    ),
    RewardItem(
      id: 'reward_abs_350',
      title: 'Community ABS Benefit-Sharing Seed Grant',
      description: 'Direct micro-grant allocated to indigenous traditional healers and forest dweller cooperatives under the UN CBD Nagoya Protocol framework.',
      karmaCost: 350,
      icon: Icons.handshake_rounded,
      category: 'Nagoya ABS',
      badgeLabel: 'Indigenous Sovereignty',
      voucherInstructions: 'Dispatched to the Local Biodiversity Management Committee (BMC) fund. Official ABS Certificate generated instantly in your profile.',
      accentColor: AppColors.leafGreen,
    ),
    RewardItem(
      id: 'reward_cert_500',
      title: 'International Nagoya Clearing-House Certified Audit',
      description: 'Official UN Convention on Biological Diversity (CBD) Clearing-House verified certificate guaranteeing sustainable harvesting and zero biopiracy.',
      karmaCost: 500,
      icon: Icons.workspace_premium_rounded,
      category: 'Nagoya ABS',
      badgeLabel: 'UN CBD Audit',
      voucherInstructions: 'Registered with the International ABS Clearing-House. Includes verifiable cryptographic SHA-256 hash and printable compliance charter.',
      accentColor: AppColors.butterYellow,
    ),
  ];

  Future<List<RedeemedVoucher>> getRedeemedVouchers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_vouchersPrefKey);
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => RedeemedVoucher.fromMap(Map<String, dynamic>.from(item as Map))).toList();
    } catch (e) {
      debugPrint('⚠️ Error loading vouchers: $e');
      return [];
    }
  }

  Future<RedeemedVoucher?> redeemReward(AppUser user, RewardItem perk) async {
    if (user.points < perk.karmaCost) {
      return null;
    }

    // Deduct points
    final userService = UserService();
    await userService.addUserPoints(user.id, -perk.karmaCost);

    // Generate unique voucher code
    final rnd = Random();
    final catCode = perk.category.replaceAll(' ', '').toUpperCase();
    final code = 'ETHNO-ABS-${catCode.substring(0, min(catCode.length, 4))}-${rnd.nextInt(9000) + 1000}';

    final voucher = RedeemedVoucher(
      id: 'vch_${DateTime.now().millisecondsSinceEpoch}',
      rewardId: perk.id,
      rewardTitle: perk.title,
      voucherCode: code,
      karmaSpent: perk.karmaCost,
      redeemedAt: DateTime.now(),
      instructions: perk.voucherInstructions,
    );

    // Save to preferences
    final vouchers = await getRedeemedVouchers();
    vouchers.insert(0, voucher);

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(vouchers.map((v) => v.toMap()).toList());
    await prefs.setString(_vouchersPrefKey, encoded);

    return voucher;
  }
}
