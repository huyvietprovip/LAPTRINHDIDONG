/// Các hàm kiểm tra dữ liệu nhập vào.
class Validators {
  Validators._();

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (text.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  /// Dùng cho ô "Nhập lại mật khẩu"; truyền mật khẩu gốc vào [original].
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if ((value ?? '').isEmpty) return 'Vui lòng nhập lại mật khẩu';
      if (value != original) return 'Mật khẩu nhập lại không khớp';
      return null;
    };
  }

  static String? displayName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập họ tên';
    if (text.length < 2) return 'Họ tên quá ngắn';
    return null;
  }
}