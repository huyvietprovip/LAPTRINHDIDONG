import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Nút bấm dùng chung, hỗ trợ trạng thái đang xử lý và kiểu viền.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    // Khi đang tải thì vô hiệu hóa nút để tránh bấm nhiều lần.
    final VoidCallback? action = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    const padding = EdgeInsets.symmetric(vertical: 14);

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: action,
              style: OutlinedButton.styleFrom(
                padding: padding,
                shape: shape,
                foregroundColor: AppColors.primary,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                padding: padding,
                shape: shape,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: child,
            ),
    );
  }
}