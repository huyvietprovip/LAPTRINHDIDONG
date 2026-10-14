/// Mô hình dữ liệu cho một chủ đề câu hỏi.
class TopicModel {
  final String id; // Mã chủ đề, ví dụ: "quy_tac"
  final String name; // Tên hiển thị, ví dụ: "Quy tắc giao thông"
  final String? description; // Mô tả ngắn (có thể không có)

  const TopicModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}