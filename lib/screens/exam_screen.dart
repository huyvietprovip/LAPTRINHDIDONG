import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/question_card.dart';

/// Màn hình làm bài Thi thử lý thuyết.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allQuestions = context.read<QuestionProvider>().questions;
      context.read<ExamProvider>().startNewExam(
            allQuestions,
            onTimeUp: _handleAutoSubmit,
          );
    });
  }

  Future<void> _handleAutoSubmit() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hết thời gian làm bài! Hệ thống tự động nộp bài.'),
        backgroundColor: AppColors.error,
      ),
    );
    await _submitExam();
  }

  Future<void> _confirmAndSubmit() async {
    final exam = context.read<ExamProvider>();
    final unanswered =
        exam.examQuestions.length - exam.selectedAnswers.length;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: Text(
          unanswered > 0
              ? 'Bạn còn $unanswered câu chưa chọn đáp án. Bạn có chắc chắn muốn nộp bài không?'
              : 'Bạn đã hoàn thành tất cả câu hỏi. Nộp bài ngay?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Làm tiếp'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitExam();
    }
  }

  Future<void> _submitExam() async {
    final uid = context.read<AuthProvider>().user?.uid;
    final exam = context.read<ExamProvider>();
    final questionProvider = context.read<QuestionProvider>();

    await exam.submitExam(uid: uid);
    await questionProvider.recordExamWrongs(
      exam.examQuestions,
      exam.selectedAnswers,
      uid: uid,
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.examResult);
  }

  @override
  Widget build(BuildContext context) {
    final exam = context.watch<ExamProvider>();
    final question = exam.currentQuestion;

    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thi thử')),
        body: const Center(child: Text('Không có dữ liệu câu hỏi để tạo đề.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 20),
            const SizedBox(width: 6),
            Text(Formatters.duration(exam.remainingSeconds)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _confirmAndSubmit,
            child: const Text(
              'NỘP BÀI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh danh sách số thứ tự câu hỏi để nhảy nhanh
          Container(
            height: 52,
            color: AppColors.surface,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: exam.examQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final q = exam.examQuestions[index];
                final isAnswered = exam.selectedAnswers.containsKey(q.id);
                final isCurrent = exam.currentIndex == index;

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => exam.goToQuestion(index),
                  child: Container(
                    width: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : isAnswered
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? Colors.white
                            : isAnswered
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Nội dung câu hỏi hiện tại
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: QuestionCard(
                question: question,
                questionNumber: exam.currentIndex + 1,
                selectedAnswerId: exam.selectedAnswers[question.id],
                showResult: false,
                onSelect: (answerId) => exam.selectAnswer(question.id, answerId),
              ),
            ),
          ),

          // Nút chuyển câu
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Câu trước',
                    icon: Icons.arrow_back,
                    isOutlined: true,
                    onPressed:
                        exam.currentIndex > 0 ? exam.previousQuestion : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: exam.currentIndex < exam.examQuestions.length - 1
                        ? 'Câu tiếp'
                        : 'Nộp bài',
                    icon: exam.currentIndex < exam.examQuestions.length - 1
                        ? Icons.arrow_forward
                        : Icons.check_circle_outline,
                    onPressed: exam.currentIndex < exam.examQuestions.length - 1
                        ? exam.nextQuestion
                        : _confirmAndSubmit,
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