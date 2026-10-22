import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/database_service.dart';
/// Màn hình Hồ sơ cá nhân.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    DatabaseService().syncQuestionsToFirestore();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(_nameCtrl.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã cập nhật thông tin cá nhân!'
              : (auth.errorMessage ?? 'Lỗi cập nhật'),
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: user == null
            ? _buildGuestView(context)
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày tham gia: ${Formatters.dateTime(user.createdAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FirebaseService.isAvailable
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        FirebaseService.isAvailable
                            ? 'Đồng bộ trực tuyến (Firebase)'
                            : 'Chế độ lưu cục bộ (Local)',
                        style: TextStyle(
                          fontSize: 12,
                          color: FirebaseService.isAvailable
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _nameCtrl,
                      label: 'Tên hiển thị',
                      prefixIcon: Icons.badge_outlined,
                      validator: Validators.displayName,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Lưu thay đổi',
                      icon: Icons.save_outlined,
                      isLoading: auth.isLoading,
                      onPressed: _updateProfile,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Đăng xuất',
                      icon: Icons.logout,
                      isOutlined: true,
                      onPressed: () async {
                        await auth.signOut();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.account_circle_outlined,
          size: 88,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),
        const Text(
          'Bạn đang sử dụng chế độ Khách',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Đăng nhập tài khoản để lưu trữ và đồng bộ kết quả thi thử, câu hỏi yêu thích của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        CustomButton(
          label: 'Đăng nhập',
          icon: Icons.login,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: 'Đăng ký tài khoản mới',
          isOutlined: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
        ),
      ],
    );
  }
}