import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/school.dart';
import '../theme/app_theme.dart';

class SchoolCard extends StatelessWidget {
  final School school;
  final bool joined;
  final VoidCallback onJoin;

  const SchoolCard({
    super.key,
    required this.school,
    required this.joined,
    required this.onJoin,
  });

  Color _getBadgeColor(String id) {
    switch (id) {
      case 'pccoe':
        return AppColors.sageGreen;
      case 'coep':
        return AppColors.butterYellow;
      case 'vit_pune':
        return AppColors.dustyCoral;
      case 'pict':
        return const Color(0xFFC7D2FE);
      case 'mit_wpu':
        return AppColors.butterYellow;
      case 'viit_pune':
        return AppColors.sageGreen;
      default:
        return AppColors.butterYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor(school.id);

    return NeoCard(
      color: AppColors.cardWhite,
      radius: 18,
      borderWidth: 2.0,
      shadowOffset: const Offset(2.5, 3.5),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.solidBlack, width: 2.0),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.solidBlack,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name.isNotEmpty ? school.name : 'College Campus',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.paperCream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.solidBlack, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.group_rounded, size: 12, color: AppColors.solidBlack),
                              const SizedBox(width: 4),
                              Text(
                                '${school.memberCount} active members',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.solidBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (joined)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.solidBlack, width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.solidBlack,
                        offset: Offset(1.5, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.solidBlack),
                      const SizedBox(width: 6),
                      Text(
                        'Joined Campus',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ],
                  ),
                )
              else
                InkWell(
                  onTap: onJoin,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.butterYellow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.solidBlack, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.solidBlack,
                          offset: Offset(2, 2.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login_rounded, size: 16, color: AppColors.solidBlack),
                        const SizedBox(width: 6),
                        Text(
                          'Join Hub',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
