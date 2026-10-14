import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Dịch vụ khởi tạo và kiểm tra trạng thái kết nối Firebase.
class FirebaseService {
  FirebaseService._();

  static bool _isAvailable = false;

  /// Trả về true nếu Firebase đã được cấu hình và khởi tạo thành công.
  static bool get isAvailable => _isAvailable;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isAvailable = true;
    } catch (e) {
      // Nếu chưa cấu hình flutterfire configure, ứng dụng tự động chuyển sang chế độ Offline/Local.
      _isAvailable = false;
      debugPrint('Firebase chưa được cấu hình, chạy chế độ Local: $e');
    }
  }
}