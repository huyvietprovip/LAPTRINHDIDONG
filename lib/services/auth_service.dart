import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'firebase_service.dart';

/// Dịch vụ xác thực người dùng (Kết hợp Firebase & SharedPreferences cục bộ).
class AuthService {
  static const String _localUserKey = 'local_logged_in_user';

  /// Lấy người dùng hiện tại (Hỗ trợ dự phòng offline bằng SharedPreferences).
  Future<UserModel?> getCurrentUser() async {
    if (FirebaseService.isAvailable) {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser == null) {
        // Nếu Firebase không có, thử lấy từ local cache
        return await _getUserFromLocal();
      }

      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(fbUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!);
        await _saveUserToLocal(user); // Lưu cache cục bộ
        return user;
      }
      
      final user = UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? 'Học viên',
        createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      );
      await _saveUserToLocal(user);
      return user;
    } else {
      // Khi mất mạng / Không có Firebase -> Đọc từ bộ nhớ cục bộ
      return await _getUserFromLocal();
    }
  }

  Future<void> _saveUserToLocal(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localUserKey, jsonEncode(user.toMap()));
    } catch (_) {}
  }

  Future<UserModel?> _getUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localUserKey);
      if (raw == null) return null;
      return UserModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Đăng nhập bằng email và mật khẩu.
  /// Đăng nhập bằng email và mật khẩu (Hỗ trợ bắt lỗi mất mạng tự động chuyển sang Local).
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Cố gắng gọi Firebase đăng nhập trực tuyến
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = cred.user!;
      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(fbUser.uid)
          .get();

      UserModel user;
      if (doc.exists && doc.data() != null) {
        user = UserModel.fromMap(doc.data()!);
      } else {
        user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? email,
          displayName: fbUser.displayName ?? email.split('@').first,
          createdAt: DateTime.now(),
        );
      }
      await _saveUserToLocal(user);
      return user;
    } catch (e) {
      // NẾU GẶP LỖI MẤT MẠNG HOẶC LỖI KẾT NỐI -> Tự động chuyển sang chế độ Local (SharedPreferences)
      final errorMessage = e.toString();
      if (errorMessage.contains('network-request-failed') || errorMessage.contains('network') || !FirebaseService.isAvailable) {
        final localUser = await _getUserFromLocal();
        if (localUser != null) {
          return localUser; // Trả về tài khoản đã lưu cục bộ trước đó
        }
      }
      // Nếu không phải lỗi mạng hoặc chưa từng lưu cục bộ thì báo lỗi bình thường
      rethrow;
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

      await _saveUserToLocal(user);
      return user;
    } else {
      final user = UserModel(
        uid: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
      );
      await _saveUserToLocal(user);
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
    }
    await _saveUserToLocal(updated);
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