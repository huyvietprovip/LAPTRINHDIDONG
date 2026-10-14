import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/question_card.dart';

/// Màn hình Kết quả thi thử và xem lại đáp án chi tiết.
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exam = context.watch<ExamProvider>();
    final result = exam.lastResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả thi')),
        body: const Center(child: Text('Không tìm thấy dữ liệu kết quả thi.')),
      );
    }

    final passed = result.isPassed;
    final statusColor = passed ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài thi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ tổng kết kết quả
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.emoji_events : Icons.cancel_outlined,
                    size: 64,
                    color: statusColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed ? 'CHÚC MỪNG! BẠN ĐÃ ĐẠT' : 'CHƯA ĐẠT YÊU CẦU',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (result.failedCritical) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Lý do trượt: Bạn đã trả lời sai câu hỏi điểm liệt!',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        'Điểm số',
                        '${result.correctCount}/${result.totalQuestions}',
                        AppColors.primary,
                      ),
                      _buildMetric(
                        'Câu sai/bỏ trống',
                        '${result.wrongCount}',
                        AppColors.error,
                      ),
                      _buildMetric(
                        'Thời gian',
                        Formatters.duration(result.durationSeconds),
                        AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Về trang chủ',
                          isOutlined: true,
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.home,
                            (route) => false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Thi lại đề mới',
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.exam,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Chi tiết đáp án và giải thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Danh sách xem lại từng câu hỏi
          ...List.generate(exam.examQuestions.length, (index) {
            final q = exam.examQuestions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuestionCard(
                question: q,
                questionNumber: index + 1,
                selectedAnswerId: result.selectedAnswers[q.id],
                showResult: true,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}