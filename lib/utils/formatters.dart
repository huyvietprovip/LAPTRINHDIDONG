import 'package:intl/intl.dart';

/// Các hàm định dạng hiển thị.
class Formatters {
  Formatters._();

  /// Đổi số giây thành dạng "mm:ss", ví dụ 125 -> "02:05".
  static String duration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Định dạng ngày giờ, ví dụ "14/10/2026 21:07".
  static String dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm').format(value);

  /// Định dạng phần trăm, ví dụ 0.8333 -> "83%".
  static String percent(double ratio) => '${(ratio * 100).round()}%';
}