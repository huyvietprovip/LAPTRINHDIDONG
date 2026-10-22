import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
/// Màn hình hiển thị kết quả thi thử lý thuyết GPLX.
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examProvider = context.watch<ExamProvider>();
    final result = examProvider.lastResult;

    // Nếu không có dữ liệu kết quả (ví dụ user truy cập trực tiếp bằng URL/Route)
    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kết quả thi thử'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tìm thấy dữ liệu kết quả thi gần nhất.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả thi thử'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ tổng quan kết quả (Đạt / Không đạt)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: result.isPassed ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: result.isPassed ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    result.isPassed ? Icons.check_circle : Icons.cancel,
                    size: 64,
                    color: result.isPassed ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.isPassed ? 'ĐẠT' : 'KHÔNG ĐẠT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: result.isPassed ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.isPassed
                        ? 'Chúc mừng bạn đã vượt qua bài thi sát hạch lý thuyết!'
                        : 'Bạn chưa đạt yêu cầu. Hãy ôn tập thêm các câu điểm liệt và câu trả lời sai nhé!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chi tiết điểm số
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildResultRow('Tổng số câu hỏi:', '${result.totalQuestions} câu'),
                    const Divider(height: 24),
                    _buildResultRow('Số câu trả lời đúng:', '${result.correctCount} câu', color: Colors.green),
                    const Divider(height: 24),
                    _buildResultRow('Số câu trả lời sai:', '${result.totalQuestions - result.correctCount} câu', color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Các nút điều hướng
            ElevatedButton.icon(
              onPressed: () {
                // Thi lại: Quay lại màn hình thi thử
                Navigator.pushReplacementNamed(context, AppRoutes.exam);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thi lại đề mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Về trang chủ
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('Về trang chủ'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}