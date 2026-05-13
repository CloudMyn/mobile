import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_skeleton.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/activity_item.dart';
import '../../data/services/kinerja_service.dart';
import '../controllers/kinerja_controller.dart';
import 'kinerja_create_page.dart';
import 'kinerja_detail_page.dart';
import 'widgets/kinerja_item_detail_sheet.dart';
import 'widgets/monthly_stats_widget.dart';

class KinerjaListPage extends StatefulWidget {
  const KinerjaListPage({super.key});

  @override
  State<KinerjaListPage> createState() => _KinerjaListPageState();
}

class _KinerjaListPageState extends State<KinerjaListPage> {
  late final KinerjaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      KinerjaController(service: Get.find<KinerjaService>()),
      tag: 'kinerja_list',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Kinerja',
        variant: AppTopAppBarVariant.standard,
        centerTitle: true,
      ),
      body: Obx(
        () {
          if (_controller.isLoadingActivities.value &&
              _controller.activities.isEmpty) {
            return _buildLoadingSkeleton();
          }

          if (_controller.errorMessage.value != null &&
              _controller.activities.isEmpty) {
            return _buildErrorState();
          }

          final threeDaysItems = _controller.last3DaysActivities;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                _controller.loadActivities(),
                _controller.loadMonthlyStats(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s16.w,
                AppSpacing.s8.h,
                AppSpacing.s16.w,
                AppSpacing.s32.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Statistics Section ─────────────────────
                  Obx(() {
                    final stats = _controller.monthlyStats.value;
                    if (stats == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        MonthlyStatsWidget(stats: stats),
                        SizedBox(height: AppSpacing.s16.h),
                      ],
                    );
                  }),

                  // ── 3 Hari Terakhir Header ────────────────
                  Text(
                    '3 Hari Terakhir',
                    style: typography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s4.h),
                  Text(
                    'Kinerja yang dicatat dalam 3 hari terakhir',
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16.h),

                  // ── 3-Day Content ─────────────────────────
                  if (threeDaysItems.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: AppSpacing.s32.h),
                      child: AppEmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Belum ada catatan kinerja',
                        subtitle: 'Belum ada aktivitas dalam 3 hari terakhir',
                        actionLabel: 'Buat Kinerja',
                        onAction: () => _navigateToCreate(context),
                      ),
                    )
                  else
                    ...threeDaysItems.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
                        child: _ActivityCard3Day(
                          item: item,
                          colors: colors,
                          typography: typography,
                          onEdit: () => _navigateToEdit(context, item),
                          onDelete: () =>
                              _confirmDelete(context, item, colors, typography),
                        ),
                      ),
                    ),

                  // ── Lihat Selengkapnya Button ─────────────
                  if (threeDaysItems.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.s16.h),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Lihat Selengkapnya',
                        onPressed: () => _navigateToDetailPage(context),
                        style: AppButtonStyle.outlined,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      itemCount: 3,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
        child: AppCard(
          outlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 120.w, height: 12.h),
              SizedBox(height: AppSpacing.s8.h),
              AppSkeleton(width: double.infinity, height: 10.h),
              SizedBox(height: AppSpacing.s8.h),
              AppSkeleton(width: 80.w, height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
          SizedBox(height: AppSpacing.s16.h),
          Text(
            _controller.errorMessage.value ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.s16.h),
          AppButton(
            label: 'Coba Lagi',
            onPressed: () {
              _controller.loadActivities();
              _controller.loadMonthlyStats();
            },
          ),
        ],
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Get.to(() => const KinerjaCreatePage());
  }

  void _navigateToEdit(BuildContext context, ActivityItem item) {
    Get.to(() => KinerjaCreatePage(item: item));
  }

  void _navigateToDetailPage(BuildContext context) {
    Get.to(() => KinerjaDetailPage());
  }

  void _confirmDelete(
    BuildContext context,
    ActivityItem item,
    AppColors colors,
    AppTypography typography,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus Kinerja',
          style: typography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan kinerja ini?',
          style: typography.bodyMedium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: typography.labelLarge.copyWith(color: colors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.deleteActivity(item.id);
            },
            child: Text(
              'Hapus',
              style: typography.labelLarge.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3-Day Activity Card ─────────────────────────────────────────

class _ActivityCard3Day extends StatelessWidget {
  final ActivityItem item;
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard3Day({
    required this.item,
    required this.colors,
    required this.typography,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null;

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: icon jenis + nama + tanggal ────────────
          Row(
            children: [
              Icon(
                _getTypeIcon(item.typeId),
                size: 18,
                color: colors.primary,
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Text(
                  item.typeName,
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatShortDate(item.date),
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),

          // ── Description ───────────────────────────────────
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          // ── Image thumbnail ───────────────────────────────
          if (hasImage) ...[
            SizedBox(height: AppSpacing.s8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r8),
              child: Image.file(
                File(item.imageUrl!),
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],

          SizedBox(height: AppSpacing.s8.h),

          // ── Action Row: Edit | Delete | Lihat Detail ─────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit',
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                color: colors.primary,
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Hapus',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                color: colors.error,
              ),
              // Lihat Detail button
              TextButton.icon(
                onPressed: () => _showDetailSheet(context),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Lihat Detail'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12.w,
                  ),
                  textStyle: typography.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r16),
        ),
      ),
      builder: (_) => KinerjaItemDetailSheet(item: item),
    );
  }

  IconData _getTypeIcon(String typeId) {
    switch (typeId) {
      case 'kedinasan':
        return Icons.work_history_rounded;
      case 'bimtek':
        return Icons.school_rounded;
      case 'rakor':
        return Icons.groups_rounded;
      case 'pelayanan':
        return Icons.handshake_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }

  String _formatShortDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
