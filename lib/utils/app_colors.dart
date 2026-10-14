import 'package:flutter/material.dart';

/// Bảng màu của ứng dụng.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0); // Xanh dương chủ đạo
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFFFFB300); // Vàng cảnh báo
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  static const Color success = Color(0xFF2E7D32); // Đáp án đúng, đạt
  static const Color error = Color(0xFFC62828); // Đáp án sai, chưa đạt
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF616E7C);

  /// Theme dùng cho MaterialApp trong main.dart.
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      );
}