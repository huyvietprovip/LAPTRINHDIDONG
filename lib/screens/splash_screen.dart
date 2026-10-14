import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';

/// Màn hình chờ khi khởi động ứng dụng.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final authProvider = context.read<AuthProvider>();
    final questionProvider = context.read<QuestionProvider>();
    final examProvider = context.read<ExamProvider>();

    await authProvider.checkAuthState();
    final uid = authProvider.user?.uid;

    await Future.wait([
      questionProvider.loadAllData(uid: uid),
      examProvider.loadHistory(uid: uid),
    ]);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.two_wheeler, size: 88, color: Colors.white),
            SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ôn thi lý thuyết bằng lái xe máy A1/A2',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}