import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/activity_item.dart';
import '../controllers/kinerja_controller.dart';
import 'widgets/kinerja_item_detail_sheet.dart';

/// Halaman full page yang menampilkan timeline bulanan di kiri
/// dan daftar aktivitas yang dikelompokkan per tanggal di kanan,
/// dengan lazy load pagination.
class KinerjaDetailPage extends StatefulWidget {
  const KinerjaDetailPage({super.key});

  @override
  State<KinerjaDetailPage> createState() => _KinerjaDetailPageState();
}

class _KinerjaDetailPageState extends State<KinerjaDetailPage> {
  late final KinerjaController _controller;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<KinerjaController>(tag: 'kinerja_list');
    _controller.loadDetailActivities(refresh: true);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      if (!_controller.isLoadingMore.value && _controller.hasMore.value) {
        _controller.loadDetailActivities();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Detail Kinerja',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Obx(
        () {
          if (_controller.isLoadingMore.value &&
              _controller.allActivities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══ Timeline Bulanan (kiri) ═══════════════════
              _buildTimeline(context, colors, typography),

              // Divider vertikal
              Container(
                width: 1,
                color: colors.outline.withValues(alpha: 0.12),
              ),

              // ══ Daftar Aktivitas (kanan) ═══════════════════
              Expanded(
                child: _buildActivityList(colors, typography),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Timeline Bulanan ────────────────────────────────────────

  Widget _buildTimeline(
    BuildContext context,
    AppColors colors,
    AppTypography typography,
  ) {
    final currentMonth = _controller.currentDetailMonth.value;
    final now = DateTime.now();
    final maxMonth = now.month;

    return SizedBox(
      width: 56.w,
      child: ListView.builder(
        padding: EdgeInsets.only(top: AppSpacing.s12.h),
        itemCount: maxMonth,
        itemBuilder: (_, index) {
          final month = index + 1;
          final isSelected = month == currentMonth;
          final monthName = KinerjaController.shortMonthName(month);
          final isLast = index == maxMonth - 1;

          return GestureDetector(
            onTap: () => _controller.changeDetailMonth(month),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 56.h,
              child: Row(
                children: [
                  // Kolom timeline (dot + line)
                  SizedBox(
                    width: 24.w,
                    child: Column(
                      children: [
                        // Garis atas
                        if (index > 0)
                          Container(
                            width: 2,
                            height: 18.h,
                            color: isSelected
                                ? colors.primary
                                : colors.outline.withValues(alpha: 0.2),
                          )
                        else
                          SizedBox(height: 18.h),

                        // Dot
                        Container(
                          width: isSelected ? 12 : 8,
                          height: isSelected ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? colors.primary
                                : colors.onSurface.withValues(alpha: 0.5),
                            border: isSelected
                                ? Border.all(
                                    color: colors.primaryContainer,
                                    width: 2)
                                : null,
                          ),
                        ),

                        // Garis bawah
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 18.h,
                            color: isSelected
                                ? colors.primary.withValues(alpha: 0.4)
                                : colors.outline.withValues(alpha: 0.2),
                          )
                        else
                          const Spacer(),
                      ],
                    ),
                  ),

                  // Label bulan
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.s4.w),
                    child: Text(
                      monthName,
                      style: typography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? colors.primary
                            : colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Daftar Aktivitas (kanan) ────────────────────────────────

  Widget _buildActivityList(AppColors colors, AppTypography typography) {
    if (_controller.allActivities.isEmpty) {
      return AppEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Belum ada data kinerja',
        subtitle: 'Tidak ada aktivitas untuk bulan ini.',
      );
    }

    final grouped = _controller.groupedByDateDetail;

    return ListView(
      controller: _scrollCtrl,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      children: [
        // ── Info bulan terpilih ──────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
          child: Row(
            children: [
              Icon(
                Icons.circle_rounded,
                size: 8,
                color: colors.primary,
              ),
              SizedBox(width: AppSpacing.s4.w),
              Text(
                _controller.currentDetailMonthName,
                style: typography.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: AppSpacing.s4.w),
              Text(
                '${_controller.currentDetailYear.value}',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const Spacer(),
              Text(
                '${_controller.allActivities.length} kegiatan',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),

        // ── Grouped cards ────────────────────────────────
        for (final entry in grouped.entries)
          ..._buildDateGroup(entry.key, entry.value, colors, typography),

        // ── Loading more indicator ───────────────────────
        if (_controller.isLoadingMore.value)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s16.h),
            child: const Center(child: CircularProgressIndicator()),
          ),

        // ── End of list indicator ────────────────────────
        if (!_controller.hasMore.value && _controller.allActivities.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s16.h),
            child: Center(
              child: Text(
                'Semua data telah dimuat',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDateGroup(
    DateTime date,
    List<ActivityItem> items,
    AppColors colors,
    AppTypography typography,
  ) {
    final widgets = <Widget>[];

    // Date header
    widgets.add(
      Padding(
        padding: EdgeInsets.only(top: AppSpacing.s8.h, bottom: AppSpacing.s4.h),
        child: Text(
          _formatDateHeader(date),
          style: typography.labelSmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    // Activity cards
    for (final item in items) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
          child: _DetailPageActivityCard(
            item: item,
            colors: colors,
            typography: typography,
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatDateHeader(DateTime date) {
    final dayNames = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}

// ── Detail Page Activity Card ──────────────────────────────────

class _DetailPageActivityCard extends StatelessWidget {
  final ActivityItem item;
  final AppColors colors;
  final AppTypography typography;

  const _DetailPageActivityCard({
    required this.item,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null;

    return GestureDetector(
      onTap: () => _showDetailSheet(context),
      child: AppCard(
        outlined: true,
        padding: EdgeInsets.all(AppSpacing.s8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: icon + type + image badge
            Row(
              children: [
                Icon(
                  _getTypeIcon(item.typeId),
                  size: 16,
                  color: colors.primary,
                ),
                SizedBox(width: AppSpacing.s4.w),
                Expanded(
                  child: Text(
                    item.typeName,
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasImage)
                  Icon(
                    Icons.image_rounded,
                    size: 14,
                    color: colors.onSurface.withValues(alpha: 0.35),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.s4.h),
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.caption.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if ((item.startTime != null && item.endTime != null) || item.status != null) ...[
              SizedBox(height: AppSpacing.s8.h),
              Row(
                children: [
                  if (item.startTime != null && item.endTime != null) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: AppSpacing.s2.w),
                    Text(
                      '${item.startTime} - ${item.endTime}',
                      style: typography.caption.copyWith(
                        fontSize: 10,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (item.status != null) _buildStatusChip(item.status!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        status,
        style: typography.caption.copyWith(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
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
}
