import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/exam_result_card.dart';
import '../widgets/progress_card.dart';

/// Màn hình Lịch sử thi thử và Thống kê tiến độ học tập.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examProvider = context.watch<ExamProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    final history = examProvider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử & Tiến độ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thống kê tổng quan
          ProgressCard(
            learnedCount: questionProvider.learnedCount,
            correctCount: questionProvider.correctLearnedCount,
          ),
          const SizedBox(height: 20),

          Text(
            'Lịch sử thi thử (${history.length} lần)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (examProvider.isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (history.isEmpty)
            const Card(
              color: AppColors.surface,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Bạn chưa thực hiện bài thi thử nào.\nHãy bắt đầu một đề thi thử để kiểm tra kiến thức!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            ...history.map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ExamResultCard(
                  result: result,
                  onTap: () {
                    examProvider.setReviewResult(
                      result,
                      questionProvider.questions,
                    );
                    Navigator.pushNamed(context, AppRoutes.examResult);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}