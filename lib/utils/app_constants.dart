/// Các hằng số dùng chung toàn ứng dụng.
class AppConstants {
  AppConstants._(); // Không cho tạo đối tượng

  static const String appName = 'MotoLearn';

  // ===== Quy chế đề thi thử =====
  // LƯU Ý: hãy đối chiếu với quy định mới nhất của Bộ GTVT rồi chỉnh lại
  // cho đúng hạng bằng (A1, A...). Chỉ cần sửa ở đây, toàn app tự cập nhật.
  static const int examQuestionCount = 25; // Số câu mỗi đề
  static const int examPassScore = 21; // Số câu đúng tối thiểu để đạt
  static const int examDurationMinutes = 19; // Thời gian làm bài (phút)

  // ===== Đường dẫn dữ liệu trong assets =====
  static const String questionsAsset = 'assets/data/questions.json';
  static const String topicsAsset = 'assets/data/topics.json';
  static const String signsAsset = 'assets/data/traffic_signs.json';

  // ===== Tên collection trên Firestore =====
  static const String usersCollection = 'users';
  static const String examResultsCollection = 'exam_results';
  static const String favoritesCollection = 'favorites';
  static const String wrongQuestionsCollection = 'wrong_questions';
  static const String progressCollection = 'progress';
}