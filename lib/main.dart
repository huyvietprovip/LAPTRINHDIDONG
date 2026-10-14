import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/question_provider.dart';
import 'screens/exam_result_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/traffic_sign_screen.dart';
import 'services/firebase_service.dart';
import 'utils/app_colors.dart';
import 'utils/app_constants.dart';
import 'utils/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase (tự động fallback về chế độ Local nếu chưa cấu hình)
  await FirebaseService.init();

  runApp(const MotoLearnApp());
}

class MotoLearnApp extends StatelessWidget {
  const MotoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppColors.theme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.learning: (_) => const LearningScreen(),
          AppRoutes.trafficSigns: (_) => const TrafficSignScreen(),
          AppRoutes.exam: (_) => const ExamScreen(),
          AppRoutes.examResult: (_) => const ExamResultScreen(),
          AppRoutes.favorites: (_) => const FavoriteScreen(),
          AppRoutes.history: (_) => const HistoryScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}