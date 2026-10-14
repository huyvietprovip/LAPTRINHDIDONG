import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/traffic_sign_model.dart';
import '../repo/question_repo.dart';

/// Provider quản lý câu hỏi lý thuyết, biển báo, yêu thích, câu sai và tiến độ học.
class QuestionProvider extends ChangeNotifier {
  final QuestionRepo _repo;

  QuestionProvider({QuestionRepo? repo}) : _repo = repo ?? QuestionRepo();

  List<QuestionModel> _questions = [];
  List<TopicModel> _topics = [];
  List<TrafficSignModel> _signs = [];
  Set<int> _favoriteIds = {};
  Set<int> _wrongIds = {};
  Map<int, bool> _learningProgress = {}; // questionId -> trả lời đúng/sai

  bool _isLoading = false;
  String? _errorMessage;

  List<QuestionModel> get questions => _questions;
  List<TopicModel> get topics => _topics;
  List<TrafficSignModel> get signs => _signs;
  Set<int> get favoriteIds => _favoriteIds;
  Set<int> get wrongIds => _wrongIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Số câu đã làm trong mục Học lý thuyết.
  int get learnedCount => _learningProgress.length;

  /// Số câu trả lời đúng trong mục Học lý thuyết.
  int get correctLearnedCount =>
      _learningProgress.values.where((isCorrect) => isCorrect).length;

  /// Danh sách câu hỏi yêu thích.
  List<QuestionModel> get favoriteQuestions =>
      _questions.where((q) => _favoriteIds.contains(q.id)).toList();

  /// Danh sách câu hỏi đã trả lời sai.
  List<QuestionModel> get wrongQuestions =>
      _questions.where((q) => _wrongIds.contains(q.id)).toList();

  /// Tải toàn bộ dữ liệu câu hỏi, chủ đề, biển báo và tiến độ.
  Future<void> loadAllData({String? uid}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getQuestions(),
        _repo.getTopics(),
        _repo.getTrafficSigns(),
        _repo.getFavoriteIds(uid: uid),
        _repo.getWrongQuestionIds(uid: uid),
        _repo.getLearningProgress(uid: uid),
      ]);

      _questions = results[0] as List<QuestionModel>;
      _topics = results[1] as List<TopicModel>;
      _signs = results[2] as List<TrafficSignModel>;
      _favoriteIds = results[3] as Set<int>;
      _wrongIds = results[4] as Set<int>;
      _learningProgress = results[5] as Map<int, bool>;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lọc câu hỏi theo mã chủ đề (null hoặc 'all' sẽ trả về tất cả).
  List<QuestionModel> questionsByTopic(String? topicId) {
    if (topicId == null || topicId == 'all') return _questions;
    if (topicId == 'critical') {
      return _questions.where((q) => q.isCritical).toList();
    }
    return _questions.where((q) => q.topicId == topicId).toList();
  }

  /// Kiểm tra một câu hỏi có nằm trong danh sách yêu thích không.
  bool isFavorite(int questionId) => _favoriteIds.contains(questionId);

  /// Bật/tắt trạng thái yêu thích của một câu hỏi.
  Future<void> toggleFavorite(int questionId, {String? uid}) async {
    if (_favoriteIds.contains(questionId)) {
      _favoriteIds.remove(questionId);
    } else {
      _favoriteIds.add(questionId);
    }
    notifyListeners();
    await _repo.saveFavoriteIds(_favoriteIds, uid: uid);
  }

  /// Ghi nhận kết quả khi người dùng trả lời một câu hỏi.
  Future<void> recordAnswer(
    QuestionModel question,
    int selectedAnswerId, {
    String? uid,
  }) async {
    final isCorrect = question.isCorrectAnswer(selectedAnswerId);
    _learningProgress[question.id] = isCorrect;

    if (!isCorrect) {
      _wrongIds.add(question.id);
    } else {
      // Nếu trả lời đúng lại câu từng sai thì xóa khỏi danh sách câu sai
      _wrongIds.remove(question.id);
    }

    notifyListeners();
    await _repo.saveLearningProgress(_learningProgress, uid: uid);
    await _repo.saveWrongQuestionIds(_wrongIds, uid: uid);
  }

  /// Ghi nhận hàng loạt các câu trả lời sai sau khi nộp bài thi thử.
  Future<void> recordExamWrongs(
    List<QuestionModel> examQuestions,
    Map<int, int> selectedAnswers, {
    String? uid,
  }) async {
    for (final q in examQuestions) {
      final chosen = selectedAnswers[q.id];
      final isCorrect = chosen != null && q.isCorrectAnswer(chosen);
      _learningProgress[q.id] = isCorrect;
      if (!isCorrect) {
        _wrongIds.add(q.id);
      }
    }
    notifyListeners();
    await _repo.saveLearningProgress(_learningProgress, uid: uid);
    await _repo.saveWrongQuestionIds(_wrongIds, uid: uid);
  }
}