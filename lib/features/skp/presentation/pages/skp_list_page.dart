import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_dropdown.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/skp_report_model.dart';
import '../controllers/skp_list_controller.dart';
import 'skp_upload_page.dart';

class SkpListPage extends StatefulWidget {
  const SkpListPage({super.key});

  @override
  State<SkpListPage> createState() => _SkpListPageState();
}

class _SkpListPageState extends State<SkpListPage> with SingleTickerProviderStateMixin {
  late final SkpListController _ctrl;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<SkpListController>();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        _ctrl.onTabChanged(_tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    int? tempMonth = _ctrl.selectedMonth.value;
    String? tempStatus = _ctrl.selectedStatus.value;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final colors = Theme.of(context).extension<AppColors>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Laporan SKP', style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Text('Bulan', style: typography.labelMedium),
                  SizedBox(height: AppSpacing.s8.h),
                  AppDropdown<int?>(
                    value: tempMonth,
                    hint: 'Pilih Bulan',
                    items: List.generate(12, (index) => DropdownMenuItem<int?>(
                      value: index + 1,
                      child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2024, index + 1))),
                    )),
                    onChanged: (val) => setStateModal(() => tempMonth = val),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Text('Status', style: typography.labelMedium),
                  SizedBox(height: AppSpacing.s8.h),
                  AppDropdown<String?>(
                    value: tempStatus,
                    hint: 'Pilih Status',
                    items: const [
                      DropdownMenuItem<String?>(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem<String?>(value: 'disetujui', child: Text('Disetujui')),
                      DropdownMenuItem<String?>(value: 'ditolak', child: Text('Ditolak')),
                    ],
                    onChanged: (val) => setStateModal(() => tempStatus = val),
                  ),
                  SizedBox(height: AppSpacing.s24.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Reset',
                          style: AppButtonStyle.outlined,
                          onPressed: () {
                            _ctrl.applyFilter(month: null, status: null);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: AppSpacing.s16.w),
                      Expanded(
                        child: AppButton(
                          label: 'Terapkan',
                          style: AppButtonStyle.filled,
                          onPressed: () {
                            _ctrl.applyFilter(month: tempMonth, status: tempStatus);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(SkpReportModel report) {
    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(2024, report.periodMonth));
    AppFeedback.showDialog(
      title: 'Hapus Laporan SKP?',
      message: 'Anda akan menghapus laporan SKP periode $monthName ${report.periodYear}.\n\n'
          'Menghapus file ini akan membatalkan status verifikasi dan Anda harus mengunggah file baru untuk diverifikasi kembali oleh atasan.',
      confirmLabel: 'Hapus File',
      cancelLabel: 'Batal',
      onConfirm: () => _ctrl.deleteReport(report.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Laporan SKP',
        variant: AppTopAppBarVariant.standard,
        elevation: 0,
        actions: [
          IconButton(
            icon: Obx(() {
              final hasFilter = _ctrl.selectedMonth.value != null || _ctrl.selectedStatus.value != null;
              return Stack(
                children: [
                  Icon(Icons.filter_list_rounded, color: colors.onSurface),
                  if (hasFilter)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 8.w, minHeight: 8.h),
                      ),
                    ),
                ],
              );
            }),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ColoredBox(
            color: colors.surface,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              labelColor: colors.primary,
              unselectedLabelColor: colors.outline,
              indicatorColor: colors.primary,
              tabs: const [
                Tab(text: 'Laporan Saya'),
                Tab(text: 'Laporan Bawahan'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildReportList(isSubordinate: false, colors: colors, typography: typography),
          _buildReportList(isSubordinate: true, colors: colors, typography: typography),
        ],
      ),
      floatingActionButton: Obx(() {
        if (_ctrl.currentTabIndex.value != 0) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.to(() => const SkpUploadPage()),
          backgroundColor: colors.primary,
          icon: Icon(Icons.upload_file_rounded, color: colors.onPrimary),
          label: Text(
            'Upload Laporan',
            style: typography.labelLarge.copyWith(color: colors.onPrimary, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  Widget _buildReportList({required bool isSubordinate, required AppColors colors, required AppTypography typography}) {
    return Obx(() {
      final isLoading = isSubordinate ? _ctrl.isLoadingSub.value : _ctrl.isLoading.value;
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final reports = isSubordinate ? _ctrl.filteredSubordinateReports : _ctrl.filteredReports;

      if (reports.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_late_outlined, size: 48.sp, color: colors.outline),
                SizedBox(height: AppSpacing.s12.h),
                Text(
                  isSubordinate ? 'Belum ada laporan bawahan.' : 'Belum ada laporan SKP yang diunggah.',
                  style: typography.bodyMedium.copyWith(color: colors.outline),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: isSubordinate ? _ctrl.fetchSubordinateReports : _ctrl.fetchReports,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(AppSpacing.s16.w, AppSpacing.s16.h, AppSpacing.s16.w, 100.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSpacing.s12.h),
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report, isSubordinate, colors, typography);
          },
        ),
      );
    });
  }

  Widget _buildReportCard(SkpReportModel report, bool isSubordinate, AppColors colors, AppTypography typography) {
    Color statusColor;
    switch (report.status.toLowerCase()) {
      case 'disetujui':
        statusColor = colors.success;
        break;
      case 'ditolak':
        statusColor = colors.error;
        break;
      case 'pending':
      default:
        statusColor = colors.warning;
        break;
    }

    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(2024, report.periodMonth));

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: colors.error, size: 24.sp),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSubordinate && report.pegawaiName != null) ...[
                      Text(
                        report.pegawaiName!,
                        style: typography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                    Text(
                      'Periode: $monthName ${report.periodYear}',
                      style: typography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  report.status.toUpperCase(),
                  style: typography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          Text(
            'File: ${report.filename}',
            style: typography.bodySmall.copyWith(color: colors.outline),
          ),
          SizedBox(height: AppSpacing.s8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanggal Upload:',
                style: typography.bodySmall.copyWith(color: colors.outline),
              ),
              Text(
                DateFormat('dd MMM yyyy HH:mm').format(report.uploadDate),
                style: typography.bodySmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Item SKP:',
                style: typography.bodySmall.copyWith(color: colors.outline),
              ),
              Text(
                '${report.items.length} Item',
                style: typography.bodySmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          // Action Buttons
          if (!isSubordinate) ...[
            SizedBox(height: AppSpacing.s12.h),
            const Divider(height: 1),
            SizedBox(height: AppSpacing.s8.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmDelete(report),
                icon: Icon(Icons.delete_outline_rounded, size: 18.sp, color: colors.error),
                label: Text(
                  'Hapus Laporan',
                  style: typography.caption.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s4.h),
                ),
              ),
            ),
          ] else if (isSubordinate && report.status.toLowerCase() == 'pending') ...[
            SizedBox(height: AppSpacing.s12.h),
            const Divider(height: 1),
            SizedBox(height: AppSpacing.s8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Tolak',
                  style: AppButtonStyle.outlined,
                  onPressed: () => _ctrl.approveSubordinateReport(report.id!, false),
                ),
                SizedBox(width: AppSpacing.s8.w),
                AppButton(
                  label: 'Setujui',
                  style: AppButtonStyle.filled,
                  onPressed: () => _ctrl.approveSubordinateReport(report.id!, true),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
