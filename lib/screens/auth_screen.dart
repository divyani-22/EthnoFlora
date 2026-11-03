import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/email_auth_form.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoCard(
            color: AppColors.paperCream,
            radius: 22,
            borderWidth: 2.0,
            shadowOffset: const Offset(4, 4),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.solidBlack, width: 2.0),
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.solidBlack, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  "Welcome to EthnoFlora AI!",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.solidBlack.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 20),
                NeoButton(
                  text: "Enter Research Portal",
                  color: AppColors.butterYellow,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      body: PaperGridBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Plant & Gardener flat illustration matching reference
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const EcoPlantIllustration(),
                    ),
                    const SizedBox(height: 16),

                    // Title & Tagline matching reference
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Welcome to EthnoFlora AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Ethnobotanical Intelligence & Biodiversity Conservation',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Authentication Form
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: EmailAuthForm(showSuccessDialog: _showSuccessDialog),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Official EthnoFlora AI Logo Emblem badge matching the Neo-Brutalist design
class EcoPlantIllustration extends StatelessWidget {
  const EcoPlantIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: AppColors.electricMint,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.solidBlack, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.solidBlack,
            offset: Offset(3.5, 4.0),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
