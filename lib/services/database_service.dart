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
import 'package:flutter/foundation.dart';

/// Dịch vụ đọc dữ liệu JSON từ assets và lưu trữ dữ liệu người dùng.
class DatabaseService {
  // ===== ĐỌC & ĐỒNG BỘ CÂU HỎI =====

  Future<List<QuestionModel>> loadQuestionsFromAssets() async {
    final raw = await rootBundle.loadString(AppConstants.questionsAsset);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => QuestionModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Ưu tiên đọc danh sách câu hỏi từ Cloud Firestore, nếu lỗi/mất mạng thì fallback về file JSON local
  Future<List<QuestionModel>> loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .orderBy('id')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => QuestionModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      debugPrint('Lỗi đọc câu hỏi từ Firestore, chuyển về dùng asset: $e');
    }
    return loadQuestionsFromAssets();
  }

  /// Đồng bộ toàn bộ câu hỏi từ file JSON lên Cloud Firestore
  Future<void> syncQuestionsToFirestore() async {
    try {
      final raw = await rootBundle.loadString(AppConstants.questionsAsset);
      final list = jsonDecode(raw) as List<dynamic>;
      final firestore = FirebaseFirestore.instance;

      for (var item in list) {
        final mapItem = Map<String, dynamic>.from(item as Map);
        final int id = mapItem['id'];
        await firestore.collection('questions').doc(id.toString()).set(mapItem);
      }
      debugPrint('🎉 Đồng bộ thành công toàn bộ ${list.length} câu hỏi lên Cloud Firestore!');
    } catch (e) {
      debugPrint('❌ Lỗi đồng bộ câu hỏi lên Firestore: $e');
    }
  }

  // ===== ĐỌC & ĐỒNG BỘ BIỂN BÁO =====

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
        .map((e) => TrafficSignModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Ưu tiên đọc danh sách biển báo từ Cloud Firestore, nếu lỗi thì fallback về asset
  Future<List<TrafficSignModel>> loadTrafficSigns() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('traffic_signs')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => TrafficSignModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      debugPrint('Lỗi đọc biển báo từ Firestore, chuyển về dùng asset: $e');
    }
    return loadTrafficSignsFromAssets();
  }

  /// Đồng bộ toàn bộ biển báo từ file JSON lên Cloud Firestore
  Future<void> syncTrafficSignsToFirestore() async {
    try {
      final raw = await rootBundle.loadString(AppConstants.signsAsset);
      final list = jsonDecode(raw) as List<dynamic>;
      final firestore = FirebaseFirestore.instance;

      for (var item in list) {
        final mapItem = Map<String, dynamic>.from(item as Map);
        final String id = mapItem['id'].toString(); // Dùng mã biển (VD: P.126) làm Document ID
        await firestore.collection('traffic_signs').doc(id).set(mapItem);
      }
      debugPrint('🎉 Đồng bộ thành công toàn bộ ${list.length} biển báo lên Cloud Firestore!');
    } catch (e) {
      debugPrint('❌ Lỗi đồng bộ biển báo lên Firestore: $e');
    }
  }

  // ===== CÁC HÀM LƯU & ĐỌC KHÁC GIỮ NGUYÊN =====
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

  Future<List<ExamResultModel>> getExamHistory({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(AppConstants.examResultsCollection) ?? [];
    final results = rawList
        .map((e) => ExamResultModel.fromMap(jsonDecode(e) as Map<String, dynamic>))
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
          return snap.docs.map((d) => ExamResultModel.fromMap(d.data())).toList();
        }
      } catch (_) {}
    }

    results.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return results;
  }

  Future<void> saveExamResult(ExamResultModel result, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(AppConstants.examResultsCollection) ?? [];
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