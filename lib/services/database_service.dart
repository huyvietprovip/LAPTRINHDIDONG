import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_result_model.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/traffic_sign_model.dart';
import '../utils/app_constants.dart';
import 'firebase_service.dart';

/// Dịch vụ đọc dữ liệu JSON từ assets và lưu trữ dữ liệu người dùng.
class DatabaseService {
  // ===== ĐỌC DỮ LIỆU TỪ ASSETS =====

  Future<List<QuestionModel>> loadQuestionsFromAssets() async {
    final raw = await rootBundle.loadString(AppConstants.questionsAsset);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => QuestionModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<TopicModel>> loadTopicsFromAssets() async {
    final raw = await rootBundle.loadString(AppConstants.topicsAsset);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TopicModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<TrafficSignModel>> loadTrafficSignsFromAssets() async {
    final raw = await rootBundle.loadString(AppConstants.signsAsset);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) =>
            TrafficSignModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ===== LƯU & ĐỌC CÂU HỎI YÊU THÍCH / CÂU SAI =====

  Future<Set<int>> getIntSet(String key, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final localList = prefs.getStringList(key) ?? [];
    final result = localList.map(int.parse).toSet();

    if (FirebaseService.isAvailable && uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.progressCollection)
            .doc(key)
            .get();
        if (doc.exists && doc.data()?['ids'] != null) {
          final remoteIds = List<int>.from(doc.data()!['ids'] as List);
          result.addAll(remoteIds);
        }
      } catch (_) {}
    }
    return result;
  }

  Future<void> saveIntSet(String key, Set<int> ids, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, ids.map((e) => e.toString()).toList());

    if (FirebaseService.isAvailable && uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.progressCollection)
            .doc(key)
            .set({'ids': ids.toList()});
      } catch (_) {}
    }
  }

  // ===== LƯU & ĐỌC TIẾN ĐỘ HỌC LÝ THUYẾT (questionId -> isCorrect) =====

  Future<Map<int, bool>> getLearningProgress({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.progressCollection);
    if (raw == null) return {};
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return decoded.map((k, v) => MapEntry(int.parse(k), v as bool));
  }

  Future<void> saveLearningProgress(
    Map<int, bool> progress, {
    String? uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = progress.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(AppConstants.progressCollection, jsonEncode(encoded));

    if (FirebaseService.isAvailable && uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.progressCollection)
            .doc('learning_stats')
            .set(encoded);
      } catch (_) {}
    }
  }

  // ===== LƯU & ĐỌC LỊCH SỬ THI THỬ =====

  Future<List<ExamResultModel>> getExamHistory({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList =
        prefs.getStringList(AppConstants.examResultsCollection) ?? [];
    final results = rawList
        .map((e) =>
            ExamResultModel.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    if (FirebaseService.isAvailable && uid != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.examResultsCollection)
            .orderBy('takenAt', descending: true)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => ExamResultModel.fromMap(d.data()))
              .toList();
        }
      } catch (_) {}
    }

    results.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return results;
  }

  Future<void> saveExamResult(ExamResultModel result, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final current =
        prefs.getStringList(AppConstants.examResultsCollection) ?? [];
    current.insert(0, jsonEncode(result.toMap()));
    await prefs.setStringList(AppConstants.examResultsCollection, current);

    if (FirebaseService.isAvailable && uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.examResultsCollection)
            .doc(result.id)
            .set(result.toMap());
      } catch (_) {}
    }
  }
} 