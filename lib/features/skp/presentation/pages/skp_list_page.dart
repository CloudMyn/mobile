import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_dropdown.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
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

class _SkpListPageState extends State<SkpListPage>
    with SingleTickerProviderStateMixin {
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
    int? tempYear = _ctrl.selectedYear.value;
    String? tempStatus = _ctrl.selectedStatus.value;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final colors = Theme.of(context).extension<AppColors>()!;

    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

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
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Laporan SKP',
                        style: typography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bulan', style: typography.labelMedium),
                            SizedBox(height: AppSpacing.s8.h),
                            AppDropdown<int?>(
                              value: tempMonth,
                              hint: 'Semua Bulan',
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Semua Bulan'),
                                ),
                                ...List.generate(
                                  12,
                                  (index) => DropdownMenuItem<int?>(
                                    value: index + 1,
                                    child: Text(
                                      DateFormat('MMMM', 'id_ID').format(
                                        DateTime(2024, index + 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setStateModal(() => tempMonth = val),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12.w),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tahun', style: typography.labelMedium),
                            SizedBox(height: AppSpacing.s8.h),
                            AppDropdown<int?>(
                              value: tempYear,
                              hint: 'Tahun',
                              items: years
                                  .map(
                                    (y) => DropdownMenuItem<int?>(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setStateModal(() => tempYear = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Text('Status', style: typography.labelMedium),
                  SizedBox(height: AppSpacing.s8.h),
                  AppDropdown<String?>(
                    value: tempStatus,
                    hint: 'Semua Status',
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua Status'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'disetujui',
                        child: Text('Disetujui'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'ditolak',
                        child: Text('Ditolak'),
                      ),
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
                            _ctrl.resetFilter();
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
                            _ctrl.applyFilter(
                              month: tempMonth,
                              year: tempYear,
                              status: tempStatus,
                            );
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
    final monthName = DateFormat('MMMM', 'id_ID')
        .format(DateTime(2024, report.periodMonth));
    AppFeedback.showDialog(
      title: 'Hapus Laporan SKP?',
      message:
          'Anda akan menghapus laporan SKP periode $monthName ${report.periodYear}.\n\n'
          'Menghapus file ini akan membatalkan status verifikasi dan Anda harus mengunggah file baru untuk diverifikasi kembali oleh atasan.',
      confirmLabel: 'Hapus File',
      cancelLabel: 'Batal',
      onConfirm: () => _ctrl.deleteReport(report.id),
    );
  }

  void _reUploadAfterRejection(SkpReportModel report) {
    AppFeedback.showDialog(
      title: 'Upload Ulang SKP?',
      message:
          'Laporan sebelumnya yang ditolak akan dihapus terlebih dahulu agar Anda dapat mengunggah berkas perbaikan.',
      confirmLabel: 'Lanjut Upload',
      cancelLabel: 'Batal',
      onConfirm: () async {
        await _ctrl.deleteReport(report.id);
        Get.to(() => const SkpUploadPage());
      },
    );
  }

  void _showRejectionDialog(SkpReportModel report) {
    final noteController = TextEditingController();
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
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tolak Laporan SKP',
                style: typography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.error,
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                'Laporan pegawai: ${report.displayName} (Periode: ${DateFormat('MMMM', 'id_ID').format(DateTime(2024, report.periodMonth))} ${report.periodYear})',
                style: typography.caption.copyWith(color: colors.outline),
              ),
              SizedBox(height: AppSpacing.s16.h),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alasan / Catatan Penolakan *',
                  hintText: 'Tuliskan alasan mengapa laporan ini ditolak...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s24.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      style: AppButtonStyle.outlined,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s12.w),
                  Expanded(
                    child: AppButton(
                      label: 'Kirim Penolakan',
                      style: AppButtonStyle.filled,
                      onPressed: () {
                        final note = noteController.text.trim();
                        if (note.isEmpty) {
                          AppFeedback.showSnackbar(
                            title: 'Peringatan',
                            message: 'Harap isi alasan penolakan.',
                            type: FeedbackType.warning,
                          );
                          return;
                        }
                        Navigator.pop(context);
                        _ctrl.verifySubordinateReport(
                          report.id,
                          status: 'ditolak',
                          rejectionNote: note,
                        );
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
              final hasFilter = _ctrl.selectedMonth.value != null ||
                  _ctrl.selectedStatus.value != null;
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
                        constraints:
                            BoxConstraints(minWidth: 8.w, minHeight: 8.h),
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
          _buildReportList(
            isSubordinate: false,
            colors: colors,
            typography: typography,
          ),
          _buildReportList(
            isSubordinate: true,
            colors: colors,
            typography: typography,
          ),
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
            style: typography.labelLarge.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReportList({
    required bool isSubordinate,
    required AppColors colors,
    required AppTypography typography,
  }) {
    return Obx(() {
      final isLoading =
          isSubordinate ? _ctrl.isLoadingSub.value : _ctrl.isLoading.value;
      final reports = isSubordinate ? _ctrl.subReports : _ctrl.reports;
      final isLoadingMore = isSubordinate
          ? _ctrl.isLoadingMoreSubReports.value
          : _ctrl.isLoadingMoreReports.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (reports.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_late_outlined,
                  size: 48.sp,
                  color: colors.outline,
                ),
                SizedBox(height: AppSpacing.s12.h),
                Text(
                  isSubordinate
                      ? 'Belum ada laporan bawahan.'
                      : 'Belum ada laporan SKP yang diunggah.',
                  style: typography.bodyMedium.copyWith(color: colors.outline),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: isSubordinate
            ? () => _ctrl.fetchSubordinateReports(refresh: true)
            : () => _ctrl.fetchReports(refresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              if (isSubordinate) {
                _ctrl.loadMoreSubordinateReports();
              } else {
                _ctrl.loadMoreReports();
              }
            }
            return false;
          },
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16.w,
              AppSpacing.s16.h,
              AppSpacing.s16.w,
              100.h,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reports.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.s12.h),
            itemBuilder: (context, index) {
              if (index >= reports.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final report = reports[index];
              return _buildReportCard(
                report,
                isSubordinate,
                colors,
                typography,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildReportCard(
    SkpReportModel report,
    bool isSubordinate,
    AppColors colors,
    AppTypography typography,
  ) {
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

    final monthName = DateFormat('MMMM', 'id_ID')
        .format(DateTime(2024, report.periodMonth));

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded,
                  color: colors.error, size: 24.sp),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSubordinate) ...[
                      Text(
                        report.displayName,
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

          // File name
          Text(
            'File: ${report.fileName}',
            style: typography.bodySmall.copyWith(color: colors.outline),
          ),
          SizedBox(height: AppSpacing.s8.h),

          // Predikat & Capaian (from jsonExtractedData)
          if (report.predikatKinerja != null ||
              report.tppPercentage != null) ...[
            Row(
              children: [
                if (report.predikatKinerja != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Predikat: ${report.predikatKinerja}',
                      style: typography.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                ],
                if (report.tppPercentage != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'TPP: ${report.tppPercentage}%',
                      style: typography.caption.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.s8.h),
          ],

          // Upload date
          if (report.createdAt != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal Upload:',
                  style: typography.bodySmall.copyWith(color: colors.outline),
                ),
                Text(
                  DateFormat('dd MMM yyyy HH:mm').format(report.createdAt!),
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s4.h),
          ],

          // Verifier info if approved/rejected
          if (report.verifier != null && report.verifiedAt != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diverifikasi oleh:',
                  style: typography.bodySmall.copyWith(color: colors.outline),
                ),
                Text(
                  report.verifierDisplayName,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s4.h),
          ],

          // Rejection Note (if rejected)
          if (report.isRejected &&
              report.rejectionNote != null &&
              report.rejectionNote!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s8.h),
            Container(
              padding: EdgeInsets.all(AppSpacing.s8.w),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: colors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: colors.error, size: 16.sp),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan Penolakan:',
                          style: typography.labelSmall.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          report.rejectionNote!,
                          style: typography.caption.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          if (!isSubordinate) ...[
            SizedBox(height: AppSpacing.s12.h),
            const Divider(height: 1),
            SizedBox(height: AppSpacing.s8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (report.isRejected) ...[
                  TextButton.icon(
                    onPressed: () => _reUploadAfterRejection(report),
                    icon: Icon(Icons.upload_file_rounded,
                        size: 18.sp, color: colors.primary),
                    label: Text(
                      'Upload Ulang',
                      style: typography.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                ],
                TextButton.icon(
                  onPressed: () => _confirmDelete(report),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: colors.error),
                  label: Text(
                    'Hapus Laporan',
                    style: typography.caption.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s4.h,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isSubordinate && report.isPending) ...[
            SizedBox(height: AppSpacing.s12.h),
            const Divider(height: 1),
            SizedBox(height: AppSpacing.s8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Tolak',
                  style: AppButtonStyle.outlined,
                  onPressed: () => _showRejectionDialog(report),
                ),
                SizedBox(width: AppSpacing.s8.w),
                AppButton(
                  label: 'Setujui',
                  style: AppButtonStyle.filled,
                  onPressed: () => _ctrl.verifySubordinateReport(
                    report.id,
                    status: 'disetujui',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
