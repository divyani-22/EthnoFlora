import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/ai_chat_screen.dart';
import '../models/user.dart';

/// PhytoDoc AI floating button.
/// Provides 1-tap access to the PhytoDoc AI botanical & ethnobotanical chat assistant.
class PhytoDocAIButton extends StatelessWidget {
  final AppUser user;

  const PhytoDocAIButton({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'PhytoDoc AI',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AIChatScreen(user: user),
            ),
          );
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/ai.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const Icon(
                Icons.psychology,
                size: 20,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Backward-compatibility alias
typedef PhytoDoc AIButton = PhytoDocAIButton;
