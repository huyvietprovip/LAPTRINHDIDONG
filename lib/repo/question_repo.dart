import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/traffic_sign_model.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';

/// Repository quản lý dữ liệu câu hỏi, chủ đề, biển báo và tiến độ ôn tập.
class QuestionRepo {
  final DatabaseService _dbService;

  QuestionRepo({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<List<QuestionModel>> getQuestions() =>
      _dbService.loadQuestionsFromAssets();

  Future<List<TopicModel>> getTopics() => _dbService.loadTopicsFromAssets();

  Future<List<TrafficSignModel>> getTrafficSigns() =>
      _dbService.loadTrafficSignsFromAssets();

  Future<Set<int>> getFavoriteIds({String? uid}) =>
      _dbService.getIntSet(AppConstants.favoritesCollection, uid: uid);

  Future<void> saveFavoriteIds(Set<int> ids, {String? uid}) =>
      _dbService.saveIntSet(AppConstants.favoritesCollection, ids, uid: uid);

  Future<Set<int>> getWrongQuestionIds({String? uid}) =>
      _dbService.getIntSet(AppConstants.wrongQuestionsCollection, uid: uid);

  Future<void> saveWrongQuestionIds(Set<int> ids, {String? uid}) =>
      _dbService.saveIntSet(
        AppConstants.wrongQuestionsCollection,
        ids,
        uid: uid,
      );

  Future<Map<int, bool>> getLearningProgress({String? uid}) =>
      _dbService.getLearningProgress(uid: uid);

  Future<void> saveLearningProgress(
    Map<int, bool> progress, {
    String? uid,
  }) =>
      _dbService.saveLearningProgress(progress, uid: uid);
}