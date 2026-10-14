import 'dart:math';
import '../models/exam_result_model.dart';
import '../models/question_model.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';

/// Repository xử lý tạo đề thi, chấm điểm và lưu lịch sử thi thử.
class ExamRepo {
  final DatabaseService _dbService;

  ExamRepo({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  /// Rút ngẫu nhiên bộ đề thi theo chuẩn (ưu tiên có ít nhất 1-2 câu điểm liệt).
  List<QuestionModel> generateExamQuestions(List<QuestionModel> allQuestions) {
    if (allQuestions.isEmpty) return [];
    final random = Random();

    final criticals = allQuestions.where((q) => q.isCritical).toList()
      ..shuffle(random);
    final normals = allQuestions.where((q) => !q.isCritical).toList()
      ..shuffle(random);

    final int targetCount =
        min(AppConstants.examQuestionCount, allQuestions.length);
    final List<QuestionModel> examSet = [];

    // Đảm bảo có từ 1 đến 2 câu điểm liệt trong đề
    if (criticals.isNotEmpty) {
      examSet.addAll(criticals.take(min(2, criticals.length)));
    }

    final remaining = targetCount - examSet.length;
    examSet.addAll(normals.take(remaining));
    examSet.shuffle(random);

    return examSet;
  }

  /// Chấm điểm bài thi thử.
  ExamResultModel evaluateExam({
    required List<QuestionModel> examQuestions,
    required Map<int, int> selectedAnswers,
    required int durationSeconds,
  }) {
    int correctCount = 0;
    bool failedCritical = false;

    for (final q in examQuestions) {
      final chosenId = selectedAnswers[q.id];
      final isCorrect = chosenId != null && q.isCorrectAnswer(chosenId);

      if (isCorrect) {
        correctCount++;
      } else if (q.isCritical) {
        failedCritical = true;
      }
    }

    return ExamResultModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      takenAt: DateTime.now(),
      totalQuestions: examQuestions.length,
      correctCount: correctCount,
      durationSeconds: durationSeconds,
      failedCritical: failedCritical,
      passScore: min(AppConstants.examPassScore, examQuestions.length),
      selectedAnswers: Map<int, int>.from(selectedAnswers),
    );
  }

  Future<List<ExamResultModel>> getExamHistory({String? uid}) =>
      _dbService.getExamHistory(uid: uid);

  Future<void> saveExamResult(ExamResultModel result, {String? uid}) =>
      _dbService.saveExamResult(result, uid: uid);
}