import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Chưa cấu hình Firebase. Ứng dụng tự động chạy chế độ Local.',
    );
  }
}