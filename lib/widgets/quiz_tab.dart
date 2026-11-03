import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../widgets/quiz_card.dart';
import '../widgets/quiz_progress_card.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../screens/quiz_detail_screen.dart';

class QuizTab extends StatefulWidget {
  final AppUser user;
  const QuizTab({Key? key, required this.user}) : super(key: key);
  @override
  _QuizTabState createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  List<Quiz> _quizzes = [];
  List<QuizProgress> _quizProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    if (mounted) setState(() { _isLoading = true; });
    try {
      final quizzes = await QuizService.getQuizzes();
      if (mounted) setState(() { _quizzes = quizzes; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load quizzes', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.dustyCoral,
          ),
        );
      }
    }
  }

  List<Quiz> get _newQuizzes {
    return _quizzes.where((quiz) {
      return !_quizProgress.any((p) => p.quizId == quiz.id && p.isCompleted);
    }).toList();
  }

  List<QuizProgress> get _continueQuizzes {
    return _quizProgress.where((p) => !p.isCompleted && p.currentQuestion > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paperCream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(child: _isLoading ? _buildLoadingIndicator() : _buildQuizContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final firstName = widget.user.displayName.split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hey, ${firstName}!',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mutedText),
          ),
          const SizedBox(height: 2),
          Text(
            'Test Your Knowledge',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.solidBlack, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.solidBlack, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading quizzes...', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mutedText)),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return RefreshIndicator(
      color: AppColors.solidBlack,
      backgroundColor: AppColors.cardWhite,
      onRefresh: _loadQuizzes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_continueQuizzes.isNotEmpty) ...[
              _buildSectionHeader('Continue Quiz', AppColors.dustyCoral),
              const SizedBox(height: 10),
              ..._continueQuizzes.where((p) => _quizzes.any((q) => q.id == p.quizId)).map((progress) {
                final quiz = _quizzes.firstWhere((q) => q.id == progress.quizId);
                return QuizProgressCard(quiz: quiz, progress: progress, onContinue: () => _startQuiz(quiz), onDelete: () => _deleteProgress(progress));
              }),
              const SizedBox(height: 20),
            ],
            if (_newQuizzes.isNotEmpty) ...[
              _buildSectionHeader('Available Quizzes', AppColors.sageGreen),
              const SizedBox(height: 10),
              ..._newQuizzes.map((quiz) => FutureBuilder<Map<String, dynamic>>(
                future: _getQuizCompletionStatus(quiz.id),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  final isCompleted = data['isCompleted'] as bool? ?? false;
                  final isPerfect = data['isPerfectlyCompleted'] as bool? ?? false;
                  final bestScore = data['bestScore'] as int?;
                  return QuizCard(quiz: quiz, onTap: isPerfect ? null : () => _startQuiz(quiz), isCompleted: isCompleted, isPerfectlyCompleted: isPerfect, bestScore: bestScore);
                },
              )),
            ],
            if (_newQuizzes.isEmpty && _continueQuizzes.isEmpty) _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: AppColors.solidBlack, width: 1.5)),
        ),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.solidBlack)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.cardWhite, shape: BoxShape.circle, border: Border.all(color: AppColors.solidBlack, width: 2)),
              child: const Icon(Icons.quiz_rounded, size: 48, color: AppColors.solidBlack),
            ),
            const SizedBox(height: 16),
            Text('No quizzes yet!', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
            const SizedBox(height: 6),
            Text('Check back soon for climate education quizzes', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedText), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _startQuiz(Quiz quiz) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizDetailScreen(quiz: quiz, user: widget.user),
      ),
    );
    if (mounted) {
      _loadQuizzes();
    }
  }

  void _deleteProgress(QuizProgress progress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.solidBlack, width: 2)),
        title: Text('Delete Progress?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
        content: Text('This will delete your saved progress for this quiz.', style: GoogleFonts.plusJakartaSans(color: AppColors.mutedText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.mutedText, fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: () {
              setState(() { _quizProgress.removeWhere((p) => p.id == progress.id); });
              Navigator.pop(ctx);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.dustyCoral, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.solidBlack, width: 1.5)),
              child: Text('Delete', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.solidBlack)),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getQuizCompletionStatus(String quizId) async {
    try {
      final bestAttempt = await QuizService.getUserBestAttempt(widget.user.id, quizId);
      final isPerfect = await QuizService.hasUserCompletedQuizPerfectly(widget.user.id, quizId);
      if (bestAttempt == null) {
        return {'isCompleted': false, 'isPerfectlyCompleted': false, 'bestScore': null};
      }
      return {
        'isCompleted': bestAttempt.isCompleted,
        'isPerfectlyCompleted': isPerfect,
        'bestScore': bestAttempt.finalScore.round(),
      };
    } catch (e) {
      return {'isCompleted': false, 'isPerfectlyCompleted': false, 'bestScore': null};
    }
  }
}
