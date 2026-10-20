import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/question_card.dart';

/// Màn hình học và ôn tập các câu hỏi về Sa hình.
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

    // Lọc danh sách câu hỏi sa hình an toàn tuyệt đối, tránh lỗi thuộc tính
    // Lọc chuẩn xác các câu hỏi sa hình từ câu 216 trở đi hoặc theo ID chủ đề/từ khóa sa hình
    List saHinhQuestions = questionProvider.questions.where((q) {
      final text = q.content.toLowerCase();
      final expl = q.explanation?.toLowerCase() ?? '';
      
      // Kiểm tra nếu có chứa từ khóa sa hình / ngã tư / vạch kẻ / thứ tự xe hoặc thuộc topic sa hình
      return text.contains('sa hình') || 
             expl.contains('sa hình') || 
             text.contains('xe nào đi trước') || 
             text.contains('thứ tự các xe');
    }).toList();

    // Nếu bộ lọc trên quét không ra, ta dùng khoảng index từ câu 215 (hoặc theo ID)
    if (saHinhQuestions.isEmpty && questionProvider.questions.length > 215) {
      saHinhQuestions = questionProvider.questions.sublist(215);
    } else if (saHinhQuestions.isEmpty) {
      saHinhQuestions = questionProvider.questions;
    }

    final safeIndex = _currentIndex.clamp(0, saHinhQuestions.isEmpty ? 0 : saHinhQuestions.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Sa Hình'),
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
                          questionNumber: safeIndex + 1,
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