import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../utils/app_colors.dart';

/// Thẻ hiển thị một câu hỏi cùng các đáp án.
class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int? questionNumber; // Số thứ tự hiển thị (có thể không có)
  final int? selectedAnswerId; // Đáp án người dùng đang chọn
  final bool showResult; // true: hiện đúng/sai và giải thích
  final ValueChanged<int>? onSelect; // null: không cho chọn
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const QuestionCard({
    super.key,
    required this.question,
    this.questionNumber,
    this.selectedAnswerId,
    this.showResult = false,
    this.onSelect,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Text(
              question.content,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (question.imagePath != null) ...[
              const SizedBox(height: 12),
              _buildImage(question.imagePath!),
            ],
            const SizedBox(height: 12),
            ...question.answers.map(_buildAnswer),
            if (showResult && question.explanation.isNotEmpty) _buildExplanation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (questionNumber != null)
          Text(
            'Câu $questionNumber',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (question.isCritical) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Câu điểm liệt',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
        const Spacer(),
        if (onToggleFavorite != null)
          IconButton(
            tooltip: isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
            onPressed: onToggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        path,
        height: 140,
        fit: BoxFit.contain,
        // Chưa có ảnh thì hiện biểu tượng thay thế thay vì báo lỗi.
        errorBuilder: (_, __, ___) => const SizedBox(
          height: 80,
          child: Center(
            child: Icon(Icons.image_not_supported, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswer(answer) {
    final bool isSelected = selectedAnswerId == answer.id;

    Color borderColor = Colors.grey.shade300;
    Color fillColor = Colors.white;
    IconData? trailing;

    if (showResult) {
      if (answer.isCorrect) {
        borderColor = AppColors.success;
        fillColor = AppColors.success.withValues(alpha: 0.10);
        trailing = Icons.check_circle;
      } else if (isSelected) {
        borderColor = AppColors.error;
        fillColor = AppColors.error.withValues(alpha: 0.10);
        trailing = Icons.cancel;
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      fillColor = AppColors.primary.withValues(alpha: 0.10);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelect == null ? null : () => onSelect!(answer.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(child: Text('${answer.id}. ${answer.content}')),
              if (trailing != null)
                Icon(
                  trailing,
                  color: answer.isCorrect ? AppColors.success : AppColors.error,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Giải thích: ${question.explanation}'),
    );
  }
}