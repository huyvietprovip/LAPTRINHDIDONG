/// Mô hình dữ liệu cho người dùng của ứng dụng.
class UserModel {
  final String uid; // Mã người dùng từ Firebase Authentication
  final String email;
  final String displayName; // Tên hiển thị
  final DateTime createdAt; // Ngày tạo tài khoản

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  /// Tạo bản sao với một vài trường được thay đổi (dùng khi cập nhật hồ sơ).
  UserModel copyWith({String? displayName}) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}