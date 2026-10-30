
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'firebase_service.dart';

/// Dịch vụ xác thực người dùng.
class AuthService {
  /// Lấy người dùng hiện tại.
  Future<UserModel?> getCurrentUser() async {
    if (!FirebaseService.isAvailable) {
      return null;
    }

    final fbUser = FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(fbUser.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }

    // Nếu tài khoản đã xác thực nhưng chưa có hồ sơ Firestore,
    // tạo hồ sơ cho chính tài khoản Firebase đó.
    final user = UserModel(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'Học viên',
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  /// Đăng nhập bằng email và mật khẩu.
  /// Chỉ chấp nhận tài khoản được Firebase Authentication xác thực.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isAvailable) {
      throw Exception(
        'Firebase chưa sẵn sàng. '
        'Vui lòng kiểm tra cấu hình và kết nối mạng.',
      );
    }

    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final fbUser = credential.user;

    if (fbUser == null) {
      throw Exception('Đăng nhập thất bại. Vui lòng thử lại.');
    }

    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(fbUser.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }

    final user = UserModel(
      uid: fbUser.uid,
      email: fbUser.email ?? email.trim(),
      displayName:
          fbUser.displayName ?? email.trim().split('@').first,
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  /// Đăng ký tài khoản mới.
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!FirebaseService.isAvailable) {
      throw Exception(
        'Firebase chưa sẵn sàng. '
        'Không thể đăng ký tài khoản lúc này.',
      );
    }

    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final fbUser = credential.user;

    if (fbUser == null) {
      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    }

    await fbUser.updateDisplayName(displayName.trim());

    final user = UserModel(
      uid: fbUser.uid,
      email: email.trim(),
      displayName: displayName.trim(),
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  /// Cập nhật tên hiển thị.
  Future<UserModel> updateProfile({
    required UserModel currentUser,
    required String displayName,
  }) async {
    if (!FirebaseService.isAvailable) {
      throw Exception(
        'Firebase chưa sẵn sàng. Không thể cập nhật hồ sơ.',
      );
    }

    final fbUser = FirebaseAuth.instance.currentUser;

    if (fbUser == null || fbUser.uid != currentUser.uid) {
      throw Exception('Bạn cần đăng nhập lại để cập nhật hồ sơ.');
    }

    final updated = currentUser.copyWith(
      displayName: displayName.trim(),
    );

    await fbUser.updateDisplayName(displayName.trim());

    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(updated.uid)
        .set(updated.toMap());

    return updated;
  }

  /// Đăng xuất.
  Future<void> signOut() async {
    if (!FirebaseService.isAvailable) {
      throw Exception(
        'Firebase chưa sẵn sàng. Không thể xác nhận đăng xuất.',
      );
    }

    await FirebaseAuth.instance.signOut();
  }
}
