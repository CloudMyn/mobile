import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../core/network/session_manager.dart';
import 'developer_support_page.dart';

class DeveloperInfo {
  final String name;
  final String role;
  final String department;
  final String imageUrl;

  DeveloperInfo({
    required this.name,
    required this.role,
    required this.department,
    required this.imageUrl,
  });
}

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<DeveloperInfo> developers = [
    DeveloperInfo(
      name: 'John Doe',
      role: 'Project Manager',
      department: 'Dinas Kominfo',
      imageUrl:
          'https://ui-avatars.com/api/?name=John+Doe&background=0D8ABC&color=fff',
    ),
    DeveloperInfo(
      name: 'Jane Smith',
      role: 'UI/UX Designer',
      department: 'Tim Pengembang',
      imageUrl:
          'https://ui-avatars.com/api/?name=Jane+Smith&background=E040FB&color=fff',
    ),
  ];

  final Set<int> _tappedDeveloperIndices = {};

  void _onDeveloperTapped(int index) {
    if (!_tappedDeveloperIndices.contains(index)) {
      setState(() {
        _tappedDeveloperIndices.add(index);
      });

      if (_tappedDeveloperIndices.length == developers.length) {
        _unlockDeveloperSupport();
      }
    }
  }

  void _unlockDeveloperSupport() {
    _tappedDeveloperIndices.clear();

    final sessionManager = Get.find<SessionManager>();
    final isDeveloper = sessionManager.currentUser.value?.isDeveloper ?? false;

    if (!isDeveloper) {
      Get.snackbar(
        'Halo Semuanya! 👋',
        'Terima kasih sudah menyapa tim pengembang kami!',
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(AppSpacing.s16.w),
        borderRadius: 16.0,
        icon: const Icon(Icons.waving_hand, color: Colors.white, size: 28),
        shouldIconPulse: true,
        forwardAnimationCurve: Curves.elasticOut,
        reverseAnimationCurve: Curves.easeOut,
        animationDuration: const Duration(milliseconds: 1500),
        duration: const Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );
      return;
    }

    Get.snackbar(
      'Developer Mode Unlocked',
      'Akses Developer Support telah dibuka.',
      backgroundColor:
          Theme.of(context).extension<AppColors>()?.surface ?? Colors.black87,
      colorText:
          Theme.of(context).extension<AppColors>()?.onSurface ?? Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(AppSpacing.s16.w),
    );

    Get.to(() => const DeveloperSupportPage());
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Tentang Aplikasi',
        variant: AppTopAppBarVariant.withBack,
        onBack: () => Get.back(),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24.w,
                AppSpacing.s32.h,
                AppSpacing.s24.w,
                AppSpacing.s16.h,
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.groups_rounded,
                          size: 50.w,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s24.h),
                  Text(
                    'Tim Pengembang',
                    style: typography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onBackground,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  Text(
                    'Pihak-pihak yang terlibat dalam pengembangan aplikasi E-Kinerja.',
                    textAlign: TextAlign.center,
                    style: typography.bodyMedium.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16.w,
              vertical: AppSpacing.s16.h,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final dev = developers[index];
                // Staggered animation calculation
                final start = index * 0.1;
                final end = (start + 0.4).clamp(0.0, 1.0);

                final slideAnimation =
                    Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(start, end, curve: Curves.easeOutCubic),
                      ),
                    );

                final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(start, end, curve: Curves.easeOut),
                      ),
                    );

                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
                      child: GestureDetector(
                        onTap: () => _onDeveloperTapped(index),
                        child: _DeveloperCard(
                          developer: dev,
                          colors: colors,
                          typography: typography,
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: developers.length),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s32.h)),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final DeveloperInfo developer;
  final AppColors colors;
  final AppTypography typography;

  const _DeveloperCard({
    required this.developer,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(developer.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  developer.name,
                  style: typography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  developer.role,
                  style: typography.bodyMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8.w,
                    vertical: AppSpacing.s4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadius.r4),
                  ),
                  child: Text(
                    developer.department,
                    style: typography.labelSmall.copyWith(
                      color: colors.outline,
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
}
