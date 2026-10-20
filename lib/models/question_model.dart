import 'answer_model.dart';

/// Mô hình dữ liệu cho một câu hỏi lý thuyết.
class QuestionModel {
  final int id; // Mã câu hỏi
  final String content; // Nội dung câu hỏi
  final List<AnswerModel> answers; // Danh sách đáp án
  final String topicId; // Mã chủ đề
  final int correctAnswer; // ID của đáp án đúng (khớp với JSON mới)
  final String explanation; // Giải thích đáp án đúng
  final String? imagePath; // Đường dẫn hình minh họa
  final bool isCritical; // Câu điểm liệt: sai là trượt

  const QuestionModel({
    required this.id,
    required this.content,
    required this.answers,
    required this.topicId,
    required this.correctAnswer,
    this.explanation = '',
    this.imagePath,
    this.isCritical = false,
  });

  /// Mã (id) của đáp án đúng.
  int get correctAnswerId => correctAnswer;

  /// Kiểm tra đáp án người dùng chọn có đúng không.
  bool isCorrectAnswer(int answerId) => answerId == correctAnswerId;

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int,
      // Hỗ trợ cả trường 'question' (từ JSON mới) lẫn 'content'
      content: (map['question'] ?? map['content']) as String? ?? '',
      answers: (map['answers'] as List<dynamic>)
          .map((e) => AnswerModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      // Hỗ trợ cả 'topic' lẫn 'topicId'
      topicId: (map['topic'] ?? map['topicId']) as String? ?? 'Quy định chung',
      correctAnswer: map['correctAnswer'] as int? ?? 1,
      explanation: map['explanation'] as String? ?? '',
      // Hỗ trợ cả 'imageUrl' lẫn 'imagePath'
      imagePath: (map['imageUrl'] ?? map['imagePath']) as String?,
      isCritical: map['isCritical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': content,
      'answers': answers.map((a) => a.toMap()).toList(),
      'topic': topicId,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'imageUrl': imagePath,
      'isCritical': isCritical,
    };
  }
}