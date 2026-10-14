/// Mô hình dữ liệu cho một đáp án của câu hỏi.
class AnswerModel {
  final int id; // Thứ tự đáp án trong câu hỏi (1, 2, 3...)
  final String content; // Nội dung đáp án
  final bool isCorrect; // true nếu đây là đáp án đúng

  const AnswerModel({
    required this.id,
    required this.content,
    required this.isCorrect,
  });

  /// Tạo AnswerModel từ Map (đọc từ JSON hoặc Firestore).
  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      id: map['id'] as int,
      content: map['content'] as String,
      isCorrect: map['isCorrect'] as bool? ?? false,
    );
  }

  /// Chuyển AnswerModel thành Map để lưu trữ.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isCorrect': isCorrect,
    };
  }
}