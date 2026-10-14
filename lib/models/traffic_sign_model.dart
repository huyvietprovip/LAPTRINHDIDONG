/// Mô hình dữ liệu cho một biển báo giao thông.
class TrafficSignModel {
  final String id; // Mã biển báo, ví dụ: "P.102"
  final String name; // Tên biển báo
  final String group; // Nhóm: cấm, nguy hiểm, hiệu lệnh, chỉ dẫn, phụ
  final String meaning; // Ý nghĩa của biển báo
  final String imagePath; // Đường dẫn hình trong assets/images/signs/

  const TrafficSignModel({
    required this.id,
    required this.name,
    required this.group,
    required this.meaning,
    required this.imagePath,
  });

  factory TrafficSignModel.fromMap(Map<String, dynamic> map) {
    return TrafficSignModel(
      id: map['id'] as String,
      name: map['name'] as String,
      group: map['group'] as String,
      meaning: map['meaning'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'meaning': meaning,
      'imagePath': imagePath,
    };
  }
}