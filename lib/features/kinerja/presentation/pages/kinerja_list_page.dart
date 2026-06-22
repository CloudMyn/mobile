import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_skeleton.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/components/molecules/app_error_state.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/activity_item.dart';
import '../../data/services/kinerja_service.dart';
import '../controllers/kinerja_controller.dart';
import '../controllers/kinerja_bawahan_controller.dart';
import 'kinerja_bawahan_list_page.dart';
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
  late final KinerjaBawahanController _bawahanController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      KinerjaController(service: Get.find<KinerjaService>()),
      tag: 'kinerja_list',
    );
    _bawahanController = Get.find<KinerjaBawahanController>();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Kinerja Pegawai',
        variant: AppTopAppBarVariant.standard,
        centerTitle: true,
      ),
      body: Obx(() {
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
              _controller.loadTodayAttendance(),
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
                // ── Alert Card Belum Absen Masuk ───────────
                Obx(() {
                  final hasClockedIn = _controller.todayClockInTime.value != null;
                  if (hasClockedIn) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.s16.h),
                    child: AppCard(
                      outlined: true,
                      padding: EdgeInsets.all(AppSpacing.s16.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.s8.w),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.r8),
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: colors.error,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: AppSpacing.s12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Belum Absen Masuk',
                                  style: typography.titleSmall.copyWith(
                                    color: colors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.s4.h),
                                Text(
                                  'Anda belum melakukan absen masuk hari ini. Silakan absen masuk terlebih dahulu untuk dapat mencatat kinerja.',
                                  style: typography.bodySmall.copyWith(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // ── Status Bawahan Section ─────────────────
                Obx(() {
                  final pendingCount = _bawahanController.pendingCount.value;
                  if (pendingCount == 0) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.s16.h),
                    child: AppCard(
                      outlined: true,
                      onTap: () => Get.to(() => const KinerjaBawahanListPage()),
                      padding: EdgeInsets.all(AppSpacing.s16.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.s8.w),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.r8),
                            ),
                            child: Icon(
                              Icons.assignment_ind_rounded,
                              color: colors.warning,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: AppSpacing.s12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kinerja Bawahan',
                                  style: typography.titleSmall.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$pendingCount laporan menunggu persetujuan',
                                  style: typography.bodySmall.copyWith(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors.outline,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

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
                    child: Obx(() {
                      final hasClockedIn = _controller.todayClockInTime.value != null;
                      return AppEmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Belum ada catatan kinerja',
                        subtitle: 'Belum ada aktivitas dalam 3 hari terakhir',
                        actionLabel: hasClockedIn ? 'Buat Kinerja' : null,
                        onAction: hasClockedIn ? () => _navigateToCreate(context) : null,
                      );
                    }),
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
                if (_controller.activities.isNotEmpty) ...[
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
      }),
      floatingActionButton: Obx(() {
        final hasClockedIn = _controller.todayClockInTime.value != null;
        if (!hasClockedIn) return const SizedBox.shrink();

        return FloatingActionButton(
          onPressed: () => _navigateToCreate(context),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          child: const Icon(Icons.add_rounded),
        );
      }),
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
    final rawError = _controller.errorMessage.value ?? '';
    final isPermissionError =
        rawError.contains('403') ||
        rawError.contains('Akses ditolak') ||
        rawError.contains('Forbidden');

    return AppErrorState(
      icon: isPermissionError
          ? Icons.lock_outline_rounded
          : Icons.cloud_off_rounded,
      title: isPermissionError ? 'Akses Terbatas' : 'Gagal Memuat Kinerja',
      message: isPermissionError
          ? 'Anda tidak memiliki izin untuk melihat data kinerja. Silakan hubungi admin instansi Anda.'
          : 'Terjadi kesalahan saat memuat data kinerja Anda. Silakan coba beberapa saat lagi.',
      technicalDetails: rawError.isNotEmpty ? rawError : null,
      onRetry: () {
        _controller.loadActivities();
        _controller.loadMonthlyStats();
      },
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
              Icon(_getTypeIcon(item.typeId), size: 18, color: colors.primary),
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
          SizedBox(height: AppSpacing.s8.h),

          // ── Time & Status ────────────────────────────────
          Row(
            children: [
              if (item.startTime != null && item.endTime != null) ...[
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                SizedBox(width: AppSpacing.s4.w),
                Text(
                  '${item.startTime} - ${item.endTime}',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const Spacer(),
              if (item.status != null) _buildStatusChip(item.status!),
            ],
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
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;

    if (status == 'Selesai') {
      bg = colors.success.withValues(alpha: 0.15);
      fg = colors.success;
    } else {
      bg = colors.warning.withValues(alpha: 0.15);
      fg = colors.warning;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Text(
        status,
        style: typography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
