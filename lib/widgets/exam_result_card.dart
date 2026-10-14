import 'package:flutter/material.dart';
import '../models/exam_result_model.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

/// Thẻ tóm tắt kết quả một lần thi thử.
class ExamResultCard extends StatelessWidget {
  final ExamResultModel result;
  final VoidCallback? onTap;

  const ExamResultCard({super.key, required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool passed = result.isPassed;
    final Color color = passed ? AppColors.success : AppColors.error;

    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(passed ? Icons.emoji_events : Icons.highlight_off,
                  color: color, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.correctCount}/${result.totalQuestions} câu đúng',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.dateTime(result.takenAt)}  •  '
                      '${Formatters.duration(result.durationSeconds)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    if (result.failedCritical)
                      const Text(
                        'Sai câu điểm liệt',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  passed ? 'ĐẠT' : 'CHƯA ĐẠT',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}