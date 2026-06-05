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
import '../../../../design_system/components/molecules/app_search_bar.dart';
import '../../data/models/subordinate_submission_item.dart';
import '../../data/models/submission_item.dart';
import '../controllers/subordinate_submission_controller.dart';
import '../controllers/submission_controller.dart';
import 'subordinate_submission_detail_page.dart';

class SubordinateSubmissionListPage extends StatefulWidget {
  const SubordinateSubmissionListPage({super.key});

  @override
  State<SubordinateSubmissionListPage> createState() => _SubordinateSubmissionListPageState();
}

class _SubordinateSubmissionListPageState extends State<SubordinateSubmissionListPage>
    with SingleTickerProviderStateMixin {
  late final SubordinateSubmissionController _controller;
  late final SubmissionController _submissionController;
  late final TabController _tabController;

  final List<String> _months = [
    'Semua Bulan',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SubordinateSubmissionController>();
    _submissionController = Get.find<SubmissionController>();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Persetujuan Pengajuan',
        variant: AppTopAppBarVariant.withBack,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Search Bar Section ─────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.s16.w, AppSpacing.s12.h, AppSpacing.s16.w, AppSpacing.s8.h),
            child: AppSearchBar(
              placeholder: 'Cari nama atau NIP bawahan...',
              onSearch: (value) => _controller.searchQuery.value = value,
              onClear: () => _controller.searchQuery.value = '',
            ),
          ),

          // ── Filter Row Section ─────────────────────────────
          _buildFilterRow(colors, typography),

          // ── Tab Bar Section ───────────────────────────────
          TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.fill,
            tabs: const [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Ditolak'),
            ],
          ),

          // ── Tab Bar View Section ──────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Obx(() => _buildList(context, _controller.filteredPending, SubmissionStatus.pending, colors, typography)),
                Obx(() => _buildList(context, _controller.filteredApproved, SubmissionStatus.approved, colors, typography)),
                Obx(() => _buildList(context, _controller.filteredRejected, SubmissionStatus.rejected, colors, typography)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AppColors colors, AppTypography typography) {
    final currentYear = DateTime.now().year;
    final years = [0, currentYear - 1, currentYear, currentYear + 1];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w, vertical: AppSpacing.s8.h),
      child: Row(
        children: [
          // 1. Type Dropdown Filter
          Obx(() {
            final selectedType = _controller.selectedTypeId.value;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
              margin: EdgeInsets.only(right: AppSpacing.s8.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedType,
                  hint: Text('Semua Jenis', style: typography.bodySmall.copyWith(color: colors.onSurface)),
                  icon: Icon(Icons.arrow_drop_down, color: colors.outline),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Semua Jenis', style: typography.bodySmall),
                    ),
                    ..._submissionController.types.map((type) {
                      return DropdownMenuItem<int?>(
                        value: type.id,
                        child: Text(type.name, style: typography.bodySmall),
                      );
                    }),
                  ],
                  onChanged: (val) => _controller.selectedTypeId.value = val,
                ),
              ),
            );
          }),

          // 2. Month Dropdown Filter
          Obx(() {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
              margin: EdgeInsets.only(right: AppSpacing.s8.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _controller.selectedMonth.value,
                  icon: Icon(Icons.arrow_drop_down, color: colors.outline),
                  items: List.generate(13, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(_months[index], style: typography.bodySmall),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) _controller.selectedMonth.value = val;
                  },
                ),
              ),
            );
          }),

          // 3. Year Dropdown Filter
          Obx(() {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _controller.selectedYear.value,
                  icon: Icon(Icons.arrow_drop_down, color: colors.outline),
                  items: years.map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text(y == 0 ? 'Semua Tahun' : y.toString(), style: typography.bodySmall),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _controller.selectedYear.value = val;
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<SubordinateSubmissionItem> list,
    SubmissionStatus status,
    AppColors colors,
    AppTypography typography,
  ) {
    if (_controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      String subtitle = 'Tidak ada pengajuan dengan status ini.';
      if (_controller.searchQuery.isNotEmpty ||
          _controller.selectedTypeId.value != null ||
          _controller.selectedMonth.value != 0 ||
          _controller.selectedYear.value != 0) {
        subtitle = 'Coba ubah filter atau pencarian Anda.';
      }
      return AppEmptyState(
        icon: Icons.subway_rounded,
        title: 'Tidak Ada Pengajuan',
        subtitle: subtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.loadAllData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w, vertical: AppSpacing.s12.h),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
            child: _SubordinateSubmissionCard(item: item, colors: colors, typography: typography),
          );
        },
      ),
    );
  }
}

class _SubordinateSubmissionCard extends StatelessWidget {
  final SubordinateSubmissionItem item;
  final AppColors colors;
  final AppTypography typography;

  const _SubordinateSubmissionCard({
    required this.item,
    required this.colors,
    required this.typography,
  });

  Color _getStatusColor() {
    return switch (item.status) {
      SubmissionStatus.pending => colors.warning,
      SubmissionStatus.approved => colors.success,
      SubmissionStatus.rejected => colors.error,
      _ => colors.outline,
    };
  }

  String _getDurationText() {
    if (item.totalDays != null) {
      return '${item.formattedDate} (${item.totalDays} hari)';
    } else if (item.totalHours != null) {
      return '${item.formattedDate} ${item.startTime}-${item.endTime} (${item.totalHours} jam)';
    }
    return item.formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      onTap: () => Get.to(() => SubordinateSubmissionDetailPage(item: item)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subordinate Avatar/Initials
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              item.subordinateAvatar,
              style: typography.bodyMedium.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // Submission info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.subordinateName,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildBadge(
                      item.status.label,
                      _getStatusColor().withValues(alpha: 0.1),
                      _getStatusColor(),
                    ),
                  ],
                ),
                Text(
                  'NIP. ${item.subordinateNip}',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: AppSpacing.s8.h),

                Row(
                  children: [
                    _buildBadge(
                      item.typeName,
                      colors.primary.withValues(alpha: 0.08),
                      colors.primary,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s8.h),

                Text(
                  _getDurationText(),
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),

                Text(
                  item.title.isNotEmpty ? item.title : item.description,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        text,
        style: typography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
