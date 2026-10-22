import 'package:flutter/material.dart';
import '../models/traffic_sign_model.dart';
import '../utils/app_colors.dart';

/// Thẻ hiển thị một biển báo giao thông.
class TrafficSignCard extends StatelessWidget {
  final TrafficSignModel sign;
  const TrafficSignCard({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Image.asset(
                sign.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // In chi tiết lỗi ra console và hiển thị trực tiếp lên app để debug
                  debugPrint('❌ LỖI LOAD ẢNH [Path: ${sign.imagePath}]: $error');
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Sai path:\n${sign.imagePath}',
                        style: const TextStyle(color: Colors.red, fontSize: 8),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sign.id} - ${sign.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sign.group,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(sign.meaning),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}