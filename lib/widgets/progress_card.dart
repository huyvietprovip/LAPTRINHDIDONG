import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

/// Thẻ thống kê tiến độ học tập.
class ProgressCard extends StatelessWidget {
  final int learnedCount; // Số câu đã làm
  final int correctCount; // Số câu trả lời đúng

  const ProgressCard({
    super.key,
    required this.learnedCount,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    // Tránh chia cho 0 khi chưa làm câu nào.
    final double accuracy = learnedCount == 0 ? 0 : correctCount / learnedCount;

    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ học tập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat('Đã làm', '$learnedCount', AppColors.primary),
                _stat('Trả lời đúng', '$correctCount', AppColors.success),
                _stat('Chính xác', Formatters.percent(accuracy), AppColors.accent),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accuracy,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}