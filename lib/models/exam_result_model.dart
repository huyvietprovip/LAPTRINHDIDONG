/// Mô hình dữ liệu cho kết quả một lần thi thử.
class ExamResultModel {
  final String id; // Mã lần thi (dùng làm id document trong Firestore)
  final DateTime takenAt; // Thời điểm nộp bài
  final int totalQuestions; // Tổng số câu của đề
  final int correctCount; // Số câu đúng
  final int durationSeconds; // Thời gian làm bài (giây)
  final bool failedCritical; // true nếu sai câu điểm liệt
  final int passScore; // Số câu đúng tối thiểu để đạt
  final Map<int, int> selectedAnswers; // questionId -> answerId đã chọn

  const ExamResultModel({
    required this.id,
    required this.takenAt,
    required this.totalQuestions,
    required this.correctCount,
    required this.durationSeconds,
    required this.failedCritical,
    required this.passScore,
    required this.selectedAnswers,
  });

  /// Số câu sai (gồm cả câu bỏ trống).
  int get wrongCount => totalQuestions - correctCount;

  /// Đạt khi đủ số câu đúng và không sai câu điểm liệt.
  bool get isPassed => correctCount >= passScore && !failedCritical;

  /// Tỷ lệ chính xác, từ 0.0 đến 1.0.
  double get accuracy =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions;

  factory ExamResultModel.fromMap(Map<String, dynamic> map) {
    // Firestore chỉ cho phép khóa kiểu String nên khi lưu ta đổi int -> String,
    // khi đọc lại phải đổi ngược String -> int.
    final rawAnswers =
        Map<String, dynamic>.from(map['selectedAnswers'] as Map? ?? {});
    final answers = rawAnswers.map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );

    return ExamResultModel(
      id: map['id'] as String,
      takenAt: DateTime.parse(map['takenAt'] as String),
      totalQuestions: map['totalQuestions'] as int,
      correctCount: map['correctCount'] as int,
      durationSeconds: map['durationSeconds'] as int,
      failedCritical: map['failedCritical'] as bool? ?? false,
      passScore: map['passScore'] as int,
      selectedAnswers: answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'takenAt': takenAt.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'durationSeconds': durationSeconds,
      'failedCritical': failedCritical,
      'passScore': passScore,
      'selectedAnswers':
          selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
    };
  }
}