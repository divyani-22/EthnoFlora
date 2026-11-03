import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../theme/app_theme.dart';

class QuizProgressCard extends StatelessWidget {
  final Quiz quiz;
  final QuizProgress progress;
  final VoidCallback? onContinue;
  final VoidCallback? onDelete;

  const QuizProgressCard({
    Key? key,
    required this.quiz,
    required this.progress,
    this.onContinue,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double pct = progress.totalQuestions > 0
        ? (progress.currentQuestion / progress.totalQuestions).clamp(0.0, 1.0)
        : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.solidBlack, width: 2),
        boxShadow: const [BoxShadow(color: AppColors.solidBlack, offset: Offset(3, 3), blurRadius: 0)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _getAccentColor(quiz.category),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.solidBlack, width: 2),
                  ),
                  child: Icon(_getQuizIcon(quiz.category), color: AppColors.solidBlack, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quiz.title,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.solidBlack, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onDelete != null)
                            GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.dustyCoral.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.solidBlack, width: 1.2),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.solidBlack, size: 16),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MetaChip(icon: Icons.assignment_outlined, label: '${progress.currentQuestion}/${progress.totalQuestions} done'),
                          const SizedBox(width: 8),
                          _MetaChip(icon: Icons.timer_outlined, label: _formatTime(progress.timeSpent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.solidBlack)),
                Text('${(pct * 100).round()}%', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.paperCream,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.solidBlack, width: 1.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(decoration: BoxDecoration(color: AppColors.sageGreen, borderRadius: BorderRadius.circular(8))),
              ),
            ),
            const SizedBox(height: 12),
            if (onContinue != null)
              GestureDetector(
                onTap: onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.butterYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.solidBlack, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.solidBlack, offset: Offset(2, 2), blurRadius: 0)],
                  ),
                  child: Center(
                    child: Text('Continue Quiz \u2192', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
                  ),
                ),
              ),
          ],
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
    return minutes > 0 ? '${minutes}m spent' : '${seconds}s spent';
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
