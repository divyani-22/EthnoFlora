import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_message.dart';
import '../theme/app_theme.dart';

class AIMessageBubble extends StatelessWidget {
  final AIMessage message;

  const AIMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.butterYellow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.solidBlack, width: 1.8),
                boxShadow: const [
                  BoxShadow(color: AppColors.solidBlack, offset: Offset(1.5, 1.5), blurRadius: 0),
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.solidBlack, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.dustyCoral : AppColors.cardWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(color: AppColors.solidBlack, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.solidBlack,
                    offset: Offset(2, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.solidBlack,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sageGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.solidBlack, width: 1.8),
                boxShadow: const [
                  BoxShadow(color: AppColors.solidBlack, offset: Offset(1.5, 1.5), blurRadius: 0),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.solidBlack, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
