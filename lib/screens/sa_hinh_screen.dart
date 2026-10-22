import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/question_card.dart';

/// Màn hình học và ôn tập các câu hỏi về Sa hình (Từ câu 216 đến hết).
class SaHinhScreen extends StatefulWidget {
  const SaHinhScreen({super.key});

  @override
  State<SaHinhScreen> createState() => _SaHinhScreenState();
}

class _SaHinhScreenState extends State<SaHinhScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answeredMap = {};

  @override
  Widget build(BuildContext context) {
    final questionProvider = context.watch<QuestionProvider>();
    final uid = context.read<AuthProvider>().user?.uid;

    // Lấy chính xác các câu hỏi sa hình từ câu 216 trở đi (index 215 đến hết)
    List saHinhQuestions = [];
    if (questionProvider.questions.length > 215) {
      saHinhQuestions = questionProvider.questions.skip(215).toList();
    } else {
      // Fallback nếu tổng số câu ít hơn 216
      saHinhQuestions = questionProvider.questions;
    }

    final safeIndex = _currentIndex.clamp(0, saHinhQuestions.isEmpty ? 0 : saHinhQuestions.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Sa Hình (Từ câu 216)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: saHinhQuestions.isEmpty
          ? const Center(
              child: Text(
                'Không có dữ liệu câu hỏi sa hình.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (context) {
                        final question = saHinhQuestions[safeIndex];
                        final selectedAnswer = _answeredMap[question.id];

                        return QuestionCard(
                          question: question,
                          questionNumber: 216 + safeIndex, // Hiển thị số câu đúng chuẩn từ 216
                          selectedAnswerId: selectedAnswer,
                          showResult: selectedAnswer != null,
                          isFavorite: questionProvider.isFavorite(question.id),
                          onToggleFavorite: () => questionProvider.toggleFavorite(question.id, uid: uid),
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
                          '${safeIndex + 1}/${saHinhQuestions.length}',
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
                          onPressed: _currentIndex < saHinhQuestions.length - 1
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
}
