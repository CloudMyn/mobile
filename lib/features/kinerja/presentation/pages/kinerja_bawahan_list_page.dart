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
import '../../data/models/subordinate_activity_item.dart';
import '../controllers/kinerja_bawahan_controller.dart';
import 'widgets/kinerja_bawahan_detail_sheet.dart';

class KinerjaBawahanListPage extends StatefulWidget {
  const KinerjaBawahanListPage({super.key});

  @override
  State<KinerjaBawahanListPage> createState() => _KinerjaBawahanListPageState();
}

class _KinerjaBawahanListPageState extends State<KinerjaBawahanListPage> with SingleTickerProviderStateMixin {
  late final KinerjaBawahanController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<KinerjaBawahanController>();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initial fetch
    _controller.loadActivities(ActivityStatus.pending, refresh: true);
    _controller.loadActivities(ActivityStatus.approved, refresh: true);
    _controller.loadActivities(ActivityStatus.rejected, refresh: true);
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
        title: 'Kinerja Bawahan',
        variant: AppTopAppBarVariant.withBack,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: colors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              unselectedLabelColor: colors.onSurface.withValues(alpha: 0.5),
              indicatorColor: colors.primary,
              tabAlignment: TabAlignment.fill,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Disetujui'),
                Tab(text: 'Ditolak'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(ActivityStatus.pending, colors, typography),
                _buildTabContent(ActivityStatus.approved, colors, typography),
                _buildTabContent(ActivityStatus.rejected, colors, typography),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ActivityStatus status, AppColors colors, AppTypography typography) {
    return Obx(() {
      final list = status == ActivityStatus.pending 
          ? _controller.pendingActivities
          : status == ActivityStatus.approved
              ? _controller.approvedActivities
              : _controller.rejectedActivities;
      
      final isLoading = status == ActivityStatus.pending
          ? _controller.isLoadingPending.value
          : status == ActivityStatus.approved
              ? _controller.isLoadingApproved.value
              : _controller.isLoadingRejected.value;
              
      final hasMore = status == ActivityStatus.pending
          ? _controller.hasMorePending.value
          : status == ActivityStatus.approved
              ? _controller.hasMoreApproved.value
              : _controller.hasMoreRejected.value;

      if (list.isEmpty && isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (list.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _controller.loadActivities(status, refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const AppEmptyState(
                icon: Icons.assignment_outlined,
                title: 'Tidak ada data',
                subtitle: 'Belum ada catatan kinerja bawahan di sini.',
              ),
            ),
          ),
        );
      }

      final groupedData = _controller.groupActivities(list);
      final groupKeys = groupedData.keys.toList();

      return RefreshIndicator(
        onRefresh: () => _controller.loadActivities(status, refresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              _controller.loadActivities(status);
            }
            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w, vertical: AppSpacing.s16.h),
            itemCount: groupKeys.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == groupKeys.length) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.s16.h),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final date = groupKeys[index];
              final items = groupedData[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.s8.h, top: index == 0 ? 0 : AppSpacing.s16.h),
                    child: Text(
                      _formatDateGroup(date),
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
                    child: _SubordinateActivityCard(
                      item: item,
                      colors: colors,
                      typography: typography,
                      onTap: () => _showDetailSheet(context, item),
                    ),
                  )),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  void _showDetailSheet(BuildContext context, SubordinateActivityItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r16)),
      ),
      builder: (_) => KinerjaBawahanDetailSheet(item: item),
    );
  }

  String _formatDateGroup(DateTime d) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _SubordinateActivityCard extends StatelessWidget {
  final SubordinateActivityItem item;
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onTap;

  const _SubordinateActivityCard({
    required this.item,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  item.subordinateAvatar,
                  style: typography.labelSmall.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subordinateName,
                      style: typography.labelLarge.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.subordinateNip,
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          Row(
            children: [
              Icon(_getTypeIcon(item.typeId), size: 16, color: colors.primary),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Text(
                  item.typeName,
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (item.hasAttachment) ...[
            SizedBox(height: AppSpacing.s8.h),
            Row(
              children: [
                Icon(
                  item.isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                  size: 14,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                SizedBox(width: AppSpacing.s4.w),
                Text(
                  'Terdapat Lampiran',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bg;
    Color fg;
    String label;
    
    switch (item.status) {
      case ActivityStatus.pending:
        bg = colors.warning.withValues(alpha: 0.2);
        fg = colors.warning;
        label = 'Pending';
        break;
      case ActivityStatus.approved:
        bg = colors.success.withValues(alpha: 0.2);
        fg = colors.success;
        label = 'Disetujui';
        break;
      case ActivityStatus.rejected:
        bg = colors.error.withValues(alpha: 0.2);
        fg = colors.error;
        label = 'Ditolak';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getTypeIcon(String typeId) {
    switch (typeId) {
      case 'kedinasan': return Icons.work_history_rounded;
      case 'bimtek': return Icons.school_rounded;
      case 'rakor': return Icons.groups_rounded;
      case 'pelayanan': return Icons.handshake_rounded;
      default: return Icons.assignment_rounded;
    }
  }
}
