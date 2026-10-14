import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/question_card.dart';

/// Màn hình Học lý thuyết theo chủ đề.
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String _selectedTopicId = 'all';
  int _currentIndex = 0;

  // Lưu đáp án người dùng vừa chọn trong phiên học: questionId -> answerId
  final Map<int, int> _answeredMap = {};

  void _changeTopic(String topicId) {
    setState(() {
      _selectedTopicId = topicId;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = context.watch<QuestionProvider>();
    final uid = context.read<AuthProvider>().user?.uid;
    final filteredQuestions =
        questionProvider.questionsByTopic(_selectedTopicId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học lý thuyết'),
      ),
      body: Column(
        children: [
          // Thanh chọn chủ đề ngang
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildTopicChip('all', 'Tất cả (${questionProvider.questions.length})'),
                  _buildTopicChip('critical', 'Câu điểm liệt'),
                  ...questionProvider.topics.map(
                    (t) => _buildTopicChip(t.id, t.name),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Nội dung câu hỏi
          Expanded(
            child: filteredQuestions.isEmpty
                ? const Center(
                    child: Text(
                      'Không có câu hỏi nào trong chủ đề này.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (context) {
                        final safeIndex = _currentIndex.clamp(
                          0,
                          filteredQuestions.length - 1,
                        );
                        final question = filteredQuestions[safeIndex];
                        final selectedAnswer = _answeredMap[question.id];

                        return QuestionCard(
                          question: question,
                          questionNumber: safeIndex + 1,
                          selectedAnswerId: selectedAnswer,
                          showResult: selectedAnswer != null,
                          isFavorite: questionProvider.isFavorite(question.id),
                          onToggleFavorite: () => questionProvider
                              .toggleFavorite(question.id, uid: uid),
                          onSelect: (answerId) {
                            setState(() {
                              _answeredMap[question.id] = answerId;
                            });
                            questionProvider.recordAnswer(
                              question,
                              answerId,
                              uid: uid,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),

          // Thanh điều hướng Câu trước / Câu tiếp
          if (filteredQuestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Câu trước',
                      icon: Icons.arrow_back,
                      isOutlined: true,
                      onPressed: _currentIndex > 0
                          ? () => setState(() => _currentIndex--)
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${_currentIndex + 1}/${filteredQuestions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      label: 'Câu tiếp',
                      icon: Icons.arrow_forward,
                      onPressed: _currentIndex < filteredQuestions.length - 1
                          ? () => setState(() => _currentIndex++)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String id, String label) {
    final isSelected = _selectedTopicId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => _changeTopic(id),
      ),
    );
  }
}