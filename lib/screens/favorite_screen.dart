import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/question_card.dart';

/// Màn hình Câu hỏi yêu thích và Câu hỏi trả lời sai.
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Lưu đáp án người dùng chọn lại để ôn tập ngay trên màn hình này
  final Map<int, int> _practiceAnswers = {};

  @override
  Widget build(BuildContext context) {
    final questionProvider = context.watch<QuestionProvider>();
    final uid = context.read<AuthProvider>().user?.uid;

    final favoriteList = questionProvider.favoriteQuestions;
    final wrongList = questionProvider.wrongQuestions;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ôn tập câu hỏi'),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Yêu thích (${favoriteList.length})'),
              Tab(text: 'Câu hay sai (${wrongList.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQuestionList(
              questions: favoriteList,
              emptyMessage: 'Bạn chưa đánh dấu câu hỏi yêu thích nào.',
              questionProvider: questionProvider,
              uid: uid,
            ),
            _buildQuestionList(
              questions: wrongList,
              emptyMessage:
                  'Tuyệt vời! Bạn chưa có câu trả lời sai nào cần ôn lại.',
              questionProvider: questionProvider,
              uid: uid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList({
    required List<QuestionModel> questions,
    required String emptyMessage,
    required QuestionProvider questionProvider,
    required String? uid,
  }) {
    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final q = questions[index];
        final chosenId = _practiceAnswers[q.id];

        return QuestionCard(
          question: q,
          questionNumber: q.id,
          selectedAnswerId: chosenId,
          showResult: chosenId != null,
          isFavorite: questionProvider.isFavorite(q.id),
          onToggleFavorite: () =>
              questionProvider.toggleFavorite(q.id, uid: uid),
          onSelect: (answerId) {
            setState(() {
              _practiceAnswers[q.id] = answerId;
            });
            questionProvider.recordAnswer(q, answerId, uid: uid);
          },
        );
      },
    );
  }
}