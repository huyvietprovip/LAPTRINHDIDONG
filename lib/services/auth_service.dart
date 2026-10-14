import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'firebase_service.dart';

/// Dịch vụ xác thực người dùng.
class AuthService {
  static const String _localUserKey = 'local_logged_in_user';

  /// Lấy người dùng hiện tại.
  Future<UserModel?> getCurrentUser() async {
    if (FirebaseService.isAvailable) {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(fbUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? 'Học viên',
        createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localUserKey);
      if (raw == null) return null;
      return UserModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  /// Đăng nhập bằng email và mật khẩu.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (FirebaseService.isAvailable) {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = cred.user!;
      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(fbUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? email,
        displayName: fbUser.displayName ?? email.split('@').first,
        createdAt: DateTime.now(),
      );
    } else {
      // Chế độ Local khi chưa bật Firebase
      final prefs = await SharedPreferences.getInstance();
      final user = UserModel(
        uid: 'local_${email.trim().hashCode}',
        email: email.trim(),
        displayName: email.trim().split('@').first,
        createdAt: DateTime.now(),
      );
      await prefs.setString(_localUserKey, jsonEncode(user.toMap()));
      return user;
    }
  }

  /// Đăng ký tài khoản mới.
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (FirebaseService.isAvailable) {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(displayName.trim());

      final user = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());

      return user;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final user = UserModel(
        uid: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );
      await prefs.setString(_localUserKey, jsonEncode(user.toMap()));
      return user;
    }
  }

  /// Cập nhật tên hiển thị.
  Future<UserModel> updateProfile({
    required UserModel currentUser,
    required String displayName,
  }) async {
    final updated = currentUser.copyWith(displayName: displayName.trim());

    if (FirebaseService.isAvailable) {
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(displayName.trim());
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(updated.uid)
          .set(updated.toMap());
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localUserKey, jsonEncode(updated.toMap()));
    }
    return updated;
  }

  /// Đăng xuất.
  Future<void> signOut() async {
    if (FirebaseService.isAvailable) {
      await FirebaseAuth.instance.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localUserKey);
  }
}