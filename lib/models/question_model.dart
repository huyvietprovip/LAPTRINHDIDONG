import 'answer_model.dart';

/// Mô hình dữ liệu cho một câu hỏi lý thuyết.
class QuestionModel {
  final int id; // Mã câu hỏi
  final String content; // Nội dung câu hỏi
  final List<AnswerModel> answers; // Danh sách đáp án
  final String topicId; // Mã chủ đề (khớp với TopicModel.id)
  final String explanation; // Giải thích đáp án đúng
  final String? imagePath; // Đường dẫn hình minh họa trong assets (có thể không có)
  final bool isCritical; // Câu điểm liệt: sai là trượt

  const QuestionModel({
    required this.id,
    required this.content,
    required this.answers,
    required this.topicId,
    required this.explanation,
    this.imagePath,
    this.isCritical = false,
  });

  /// Mã (id) của đáp án đúng.
  int get correctAnswerId =>
      answers.firstWhere((a) => a.isCorrect).id;

  /// Kiểm tra đáp án người dùng chọn có đúng không.
  bool isCorrectAnswer(int answerId) => answerId == correctAnswerId;

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int,
      content: map['content'] as String,
      answers: (map['answers'] as List<dynamic>)
          .map((e) => AnswerModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      topicId: map['topicId'] as String,
      explanation: map['explanation'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      isCritical: map['isCritical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'answers': answers.map((a) => a.toMap()).toList(),
      'topicId': topicId,
      'explanation': explanation,
      'imagePath': imagePath,
      'isCritical': isCritical,
    };
  }
}