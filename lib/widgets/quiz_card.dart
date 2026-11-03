import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../theme/app_theme.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final bool isCompleted;
  final bool isPerfectlyCompleted;
  final int? bestScore;

  const QuizCard({
    Key? key,
    required this.quiz,
    this.onTap,
    this.isCompleted = false,
    this.isPerfectlyCompleted = false,
    this.bestScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _getAccentColor(quiz.category);
    final IconData categoryIcon = _getQuizIcon(quiz.category);
    return GestureDetector(
      onTap: isPerfectlyCompleted ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isPerfectlyCompleted
              ? AppColors.sageGreen.withOpacity(0.35)
              : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.solidBlack, width: 2),
          boxShadow: isPerfectlyCompleted
              ? []
              : [const BoxShadow(color: AppColors.solidBlack, offset: Offset(3, 3), blurRadius: 0)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.solidBlack, width: 2),
                ),
                child: Icon(categoryIcon, color: AppColors.solidBlack, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack, height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaChip(icon: Icons.assignment_outlined, label: '${quiz.questionCount} Qs'),
                        const SizedBox(width: 8),
                        _MetaChip(icon: Icons.timer_outlined, label: _formatTime(quiz.timeLimit)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.butterYellow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 13, color: AppColors.solidBlack),
                        const SizedBox(width: 2),
                        Text('${quiz.points}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isPerfectlyCompleted)
                    _StatusBadge(label: 'PERFECT', color: AppColors.sageGreen)
                  else if (isCompleted && bestScore != null)
                    _StatusBadge(label: '${bestScore}%', color: AppColors.softSky)
                  else if (isCompleted)
                    _StatusBadge(label: 'DONE', color: AppColors.softSky)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.paperCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.solidBlack, width: 1.5),
                      ),
                      child: Text('START', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccentColor(String category) {
    switch (category.toLowerCase()) {
      case 'climate science': return AppColors.softSky;
      case 'sustainability': return AppColors.sageGreen;
      case 'environmental science': return AppColors.mintGreen;
      case 'renewable energy': return AppColors.butterYellow;
      default: return AppColors.dustyCoral;
    }
  }

  IconData _getQuizIcon(String category) {
    switch (category.toLowerCase()) {
      case 'climate science': return Icons.wb_cloudy_rounded;
      case 'sustainability': return Icons.eco_rounded;
      case 'environmental science': return Icons.nature_rounded;
      case 'renewable energy': return Icons.electric_bolt_rounded;
      default: return Icons.quiz_rounded;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    return minutes > 0 ? '${minutes}m' : '${seconds}s';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.paperCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.solidBlack, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.solidBlack),
          const SizedBox(width: 3),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.solidBlack)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.solidBlack, width: 1.5),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
    );
  }
}
