import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';

/// Màn hình Trang chủ thiết kế chuẩn theo giao diện Figma.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Lấy chữ cái viết tắt của tên người dùng (VD: "Nguyễn Hoàng" -> "NH")
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'HV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Lời chào theo khung giờ thực tế
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng,';
    if (hour < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final questionProvider = context.watch<QuestionProvider>();

    final userName = auth.user?.displayName.isNotEmpty == true
        ? auth.user!.displayName
        : 'Nguyễn Hoàng';

    final totalQuestions = questionProvider.questions.length;
    final learnedCount = questionProvider.learnedCount;
    final topicCount = questionProvider.topics.isNotEmpty
        ? questionProvider.topics.length
        : 12;
    final signGroupCount = questionProvider.signs
        .map((s) => s.group)
        .toSet()
        .length;

    // Tính tiến độ hiển thị trên thẻ Banner và thẻ Học gần đây
    final double progressRatio = totalQuestions == 0
        ? 0.66
        : (learnedCount / totalQuestions).clamp(0.0, 1.0);
    final int accuracyPercent = learnedCount == 0
        ? 84
        : ((questionProvider.correctLearnedCount / learnedCount) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => questionProvider.loadAllData(uid: auth.user?.uid),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. THANH HEADER TRÊN CÙNG (Logo MotoLearn + Avatar)
                _buildTopBar(context, userName),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. LỜI CHÀO & CHUỖI NGÀY HỌC (STREAK)
                      _buildGreetingSection(userName),
                      const SizedBox(height: 18),

                      // 3. THẺ BANNER TIẾN ĐỘ HÔM NAY
                      _buildHeroProgressCard(
                        context,
                        learnedCount: learnedCount,
                        totalQuestions: totalQuestions,
                        progressRatio: progressRatio,
                      ),
                      const SizedBox(height: 24),

                      // 4. TIÊU ĐỀ "Học và ôn luyện" + "Xem tất cả"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Học và ôn luyện',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.learning,
                            ),
                            child: const Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 5. LƯỚI 6 MỤC ÔN LUYỆN (2 cột chuẩn Figma)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.05,
                        children: [
                          _FigmaMenuCard(
                            title: 'Học lý thuyết',
                            subtitle: '$topicCount chủ đề',
                            icon: Icons.menu_book_rounded,
                            iconColor: const Color(0xFF2563EB),
                            bgColor: const Color(0xFFEFF6FF),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.learning,
                            ),
                          ),
                          _FigmaMenuCard(
                            title: 'Ôn tập ${totalQuestions > 0 ? totalQuestions : 600} câu',
                            subtitle: 'Đã học $learnedCount câu',
                            icon: Icons.bar_chart_rounded,
                            iconColor: const Color(0xFF10B981),
                            bgColor: const Color(0xFFECFDF5),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.learning,
                            ),
                          ),
                          _FigmaMenuCard(
                            title: 'Thi thử lý thuyết',
                            subtitle:
                                '${AppConstants.examQuestionCount} câu • ${AppConstants.examDurationMinutes} phút',
                            icon: Icons.timer_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            bgColor: const Color(0xFFFFFBEB),
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.exam),
                          ),
                          _FigmaMenuCard(
                            title: 'Học biển báo',
                            subtitle:
                                '${signGroupCount > 0 ? signGroupCount : 4} nhóm biển báo',
                            icon: Icons.warning_amber_rounded,
                            iconColor: const Color(0xFFEF4444),
                            bgColor: const Color(0xFFFEF2F2),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.trafficSigns,
                            ),
                          ),
                          _FigmaMenuCard(
                            title: 'Học sa hình',
                            subtitle: 'Tình huống thực tế',
                            icon: Icons.two_wheeler_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            bgColor: const Color(0xFFF5F3FF),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.learning,
                            ),
                          ),
                          _FigmaMenuCard(
                            title: 'Yêu thích & Mẹo',
                            subtitle:
                                '${questionProvider.favoriteIds.length} yêu thích • ${questionProvider.wrongIds.length} câu sai',
                            icon: Icons.lightbulb_outline_rounded,
                            iconColor: const Color(0xFFD97706),
                            bgColor: const Color(0xFFFEF3C7),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.favorites,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 6. THẺ HỌC GẦN ĐÂY
                      _buildRecentStudyCard(
                        context,
                        percent: accuracyPercent,
                        topicTitle: questionProvider.topics.isNotEmpty
                            ? questionProvider.topics.first.name
                            : 'Quy tắc nhường đường',
                        remainingCount:
                            (totalQuestions - learnedCount).clamp(0, 999),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 7. THANH ĐIỀU HƯỚNG DƯỚI ĐÁY (BOTTOM NAVIGATION BAR)
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Header chứa Logo MotoLearn và Avatar viết tắt có chấm xanh online
  Widget _buildTopBar(BuildContext context, String userName) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Icon mũ bảo hiểm nền xanh
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0B63F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_motorsports_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          // Chữ MotoLearn 2 màu
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              children: [
                TextSpan(
                  text: 'Moto',
                  style: TextStyle(color: Color(0xFF0F172A)),
                ),
                TextSpan(
                  text: 'Learn',
                  style: TextStyle(color: Color(0xFF10B981)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Avatar viết tắt kèm chấm tròn xanh lá
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    _getInitials(userName),
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Phần lời chào và huy hiệu chuỗi 7 ngày
  Widget _buildGreetingSection(String userName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFEA580C),
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                '7 ',
                style: TextStyle(
                  color: Color(0xFFEA580C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'ngày',
                style: TextStyle(
                  color: Color(0xFF9A3412),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Thẻ Banner xanh đậm hiển thị "TIẾN ĐỘ HÔM NAY"
  Widget _buildHeroProgressCard(
    BuildContext context, {
    required int learnedCount,
    required int totalQuestions,
    required double progressRatio,
  }) {
    final progressText = totalQuestions > 0
        ? '$learnedCount/$totalQuestions câu đã hoàn thành'
        : '12/18 bài đã hoàn thành';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.pushNamed(context, AppRoutes.learning),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F4C81), Color(0xFF1565C0)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TIẾN ĐỘ HÔM NAY',
                    style: TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tiếp tục chinh phục\nbằng lái A1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      color: const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progressText,
                    style: const TextStyle(
                      color: Color(0xFFDBEAFE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.two_wheeler_rounded,
              size: 74,
              color: Color(0xFF34D399),
            ),
          ],
        ),
      ),
    );
  }

  /// Thẻ "HỌC GẦN ĐÂY" có vòng tròn phần trăm bên trái
  Widget _buildRecentStudyCard(
    BuildContext context, {
    required int percent,
    required String topicTitle,
    required int remainingCount,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pushNamed(context, AppRoutes.learning),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vòng tròn hiển thị %
            SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: (percent / 100).clamp(0.0, 1.0),
                    strokeWidth: 4.5,
                    backgroundColor: const Color(0xFFD1FAE5),
                    color: const Color(0xFF10B981),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HỌC GẦN ĐÂY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topicTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    remainingCount > 0
                        ? 'Còn $remainingCount câu hỏi'
                        : 'Đã hoàn thành chủ đề',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Thanh điều hướng 5 mục dưới đáy giống Figma
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Đang ở Trang chủ
            case 1:
              Navigator.pushNamed(context, AppRoutes.learning);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.exam);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.history);
              break;
            case 4:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Lý thuyết',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Thi thử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Tiến độ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

/// Thẻ danh mục ngang (Icon bên trái, Tiêu đề + Phụ đề bên phải) chuẩn Figma.
class _FigmaMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _FigmaMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}