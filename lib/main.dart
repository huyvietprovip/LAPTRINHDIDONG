import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/question_provider.dart';
import 'providers/exam_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/exam_result_screen.dart';
import 'screens/traffic_sign_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sa_hinh_screen.dart';

import 'utils/app_routes.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase và cập nhật trạng thái sử dụng Firebase.
  await FirebaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: MaterialApp(
        title: 'MotoLearn - Ôn Thi GPLX A1-A4',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.learning: (context) => const LearningScreen(),
          AppRoutes.exam: (context) => const ExamScreen(),
          AppRoutes.examResult: (context) => const ExamResultScreen(),
          AppRoutes.trafficSigns: (context) => const TrafficSignScreen(),
          AppRoutes.favorites: (context) => const FavoriteScreen(),
          AppRoutes.history: (context) => const HistoryScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.saHinh: (context) => const SaHinhScreen(),
        },
      ),
    );
  }
}