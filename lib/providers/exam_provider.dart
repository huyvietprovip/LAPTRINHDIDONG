import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exam_result_model.dart';
import '../models/question_model.dart';
import '../repo/exam_repo.dart';
import '../utils/app_constants.dart';

/// Provider quản lý bài thi thử và lịch sử thi.
class ExamProvider extends ChangeNotifier {
  final ExamRepo _repo;

  ExamProvider({ExamRepo? repo}) : _repo = repo ?? ExamRepo();

  List<QuestionModel> _examQuestions = [];
  Map<int, int> _selectedAnswers = {}; // questionId -> answerId
  int _currentIndex = 0;
  int _remainingSeconds = AppConstants.examDurationMinutes * 60;
  Timer? _timer;
  bool _isSubmitted = false;
  ExamResultModel? _lastResult;
  List<ExamResultModel> _history = [];
  bool _isLoadingHistory = false;

  List<QuestionModel> get examQuestions => _examQuestions;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  int get currentIndex => _currentIndex;
  int get remainingSeconds => _remainingSeconds;
  bool get isSubmitted => _isSubmitted;
  ExamResultModel? get lastResult => _lastResult;
  List<ExamResultModel> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  QuestionModel? get currentQuestion =>
      _examQuestions.isEmpty ? null : _examQuestions[_currentIndex];

  /// Bắt đầu một đề thi thử mới.
  void startNewExam(
    List<QuestionModel> allQuestions, {
    VoidCallback? onTimeUp,
  }) {
    _timer?.cancel();
    _examQuestions = _repo.generateExamQuestions(allQuestions);
    _selectedAnswers = {};
    _currentIndex = 0;
    _isSubmitted = false;
    _lastResult = null;
    _remainingSeconds = AppConstants.examDurationMinutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        if (onTimeUp != null) onTimeUp();
      }
    });

    notifyListeners();
  }

  /// Chọn hoặc thay đổi đáp án cho câu hỏi.
  void selectAnswer(int questionId, int answerId) {
    if (_isSubmitted) return;
    _selectedAnswers[questionId] = answerId;
    notifyListeners();
  }

  /// Chuyển đến câu hỏi theo chỉ số.
  void goToQuestion(int index) {
    if (index >= 0 && index < _examQuestions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() => goToQuestion(_currentIndex + 1);
  void previousQuestion() => goToQuestion(_currentIndex - 1);

  /// Nộp bài và chấm điểm.
  Future<ExamResultModel> submitExam({String? uid}) async {
    _timer?.cancel();
    _isSubmitted = true;

    final totalSeconds = AppConstants.examDurationMinutes * 60;
    final usedSeconds = totalSeconds - _remainingSeconds;

    final result = _repo.evaluateExam(
      examQuestions: _examQuestions,
      selectedAnswers: _selectedAnswers,
      durationSeconds: usedSeconds > 0 ? usedSeconds : 1,
    );

    _lastResult = result;
    _history.insert(0, result);
    notifyListeners();

    await _repo.saveExamResult(result, uid: uid);
    return result;
  }

  /// Tải lịch sử các lần thi thử.
  Future<void> loadHistory({String? uid}) async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      _history = await _repo.getExamHistory(uid: uid);
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Xem lại một kết quả thi trong lịch sử.
  void setReviewResult(
    ExamResultModel result,
    List<QuestionModel> allQuestions,
  ) {
    _lastResult = result;
    _selectedAnswers = result.selectedAnswers;
    // Khôi phục danh sách câu hỏi thuộc lần thi đó (hoặc lấy toàn bộ câu đã chọn)
    final ids = result.selectedAnswers.keys.toSet();
    final matched = allQuestions.where((q) => ids.contains(q.id)).toList();
    _examQuestions = matched.isNotEmpty
        ? matched
        : allQuestions.take(result.totalQuestions).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 