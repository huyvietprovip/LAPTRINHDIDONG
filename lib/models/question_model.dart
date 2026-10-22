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
    final int correctAnswerId = map['correctAnswer'] as int? ?? 1;

    final rawAnswers = (map['answers'] as List<dynamic>?);
    List<AnswerModel> parsedAnswers = [];

    if (rawAnswers != null) {
      parsedAnswers = rawAnswers.map((e) {
        final answerMap = Map<String, dynamic>.from(e as Map);
        final int ansId = answerMap['id'] as int? ?? 0;
        
        // Tự động gán isCorrect = true nếu id của đáp án khớp với correctAnswer của câu hỏi
        answerMap['isCorrect'] = (ansId == correctAnswerId);
        
        return AnswerModel.fromMap(answerMap);
      }).toList();
    }

    return QuestionModel(
      id: map['id'] as int? ?? 0,
      content: (map['question'] ?? map['content']) as String? ?? '',
      answers: parsedAnswers,
      topicId: (map['topic'] ?? map['topicId']) as String? ?? 'Quy định chung',
      correctAnswer: correctAnswerId,
      explanation: map['explanation'] as String? ?? '',
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