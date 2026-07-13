import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import 'developer_support_page.dart';

class DeveloperAttendanceDetailPage extends StatefulWidget {
  final Map<String, dynamic> record;

  const DeveloperAttendanceDetailPage({super.key, required this.record});

  @override
  State<DeveloperAttendanceDetailPage> createState() => _DeveloperAttendanceDetailPageState();
}

class _DeveloperAttendanceDetailPageState extends State<DeveloperAttendanceDetailPage> {
  late String dayStatus;
  late TextEditingController summaryNoteCtrl;
  late TextEditingController totalLateCtrl;
  late TextEditingController totalEarlyCtrl;
  late TextEditingController totalWorkCtrl;

  @override
  void initState() {
    super.initState();
    dayStatus = widget.record['day_status'] ?? 'present';
    summaryNoteCtrl = TextEditingController(text: widget.record['summary_note'] ?? '');
    totalLateCtrl = TextEditingController(text: (widget.record['total_late_minutes'] ?? 0).toString());
    totalEarlyCtrl = TextEditingController(text: (widget.record['total_early_leave_minutes'] ?? 0).toString());
    totalWorkCtrl = TextEditingController(text: (widget.record['total_work_minutes'] ?? 0).toString());
  }

  @override
  void dispose() {
    summaryNoteCtrl.dispose();
    totalLateCtrl.dispose();
    totalEarlyCtrl.dispose();
    totalWorkCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final controller = Get.find<DeveloperSupportController>();
    
    final data = {
      'day_status': dayStatus,
      'summary_note': summaryNoteCtrl.text,
      'total_late_minutes': int.tryParse(totalLateCtrl.text) ?? 0,
      'total_early_leave_minutes': int.tryParse(totalEarlyCtrl.text) ?? 0,
      'total_work_minutes': int.tryParse(totalWorkCtrl.text) ?? 0,
    };
    
    controller.updateAttendanceStatus(widget.record['id'], data);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    
    final userName = widget.record['user']?['name'] ?? 'Unknown';
    final dateStr = widget.record['work_date'] ?? '';
    final List<dynamic> attendanceRecords = widget.record['records'] ?? [];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Detail Presensi Harian',
        variant: AppTopAppBarVariant.withBack,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header
            Text(userName, style: typography.titleLarge.copyWith(color: colors.onBackground, fontWeight: FontWeight.bold)),
            SizedBox(height: AppSpacing.s4.h),
            Text('Tanggal: $dateStr', style: typography.bodyMedium.copyWith(color: colors.outline)),
            SizedBox(height: AppSpacing.s24.h),
            
            // Edit Form
            Text('Edit Data Harian', style: typography.titleMedium.copyWith(color: colors.onBackground, fontWeight: FontWeight.bold)),
            SizedBox(height: AppSpacing.s12.h),
            
            AppCard(
              padding: EdgeInsets.all(AppSpacing.s16.w),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: dayStatus,
                    items: const [
                      DropdownMenuItem(value: 'present', child: Text('Hadir (Present)')),
                      DropdownMenuItem(value: 'absent', child: Text('Mangkir (Absent)')),
                      DropdownMenuItem(value: 'holiday', child: Text('Libur (Holiday)')),
                      DropdownMenuItem(value: 'leave', child: Text('Cuti (Leave)')),
                      DropdownMenuItem(value: 'sick', child: Text('Sakit (Sick)')),
                      DropdownMenuItem(value: 'permit', child: Text('Izin (Permit)')),
                      DropdownMenuItem(value: 'off', child: Text('Lepas (Off)')),
                      DropdownMenuItem(value: 'workday', child: Text('Hari Kerja (Workday)')),
                      DropdownMenuItem(value: 'partial', child: Text('Parsial (Partial)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => dayStatus = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Status Kehadiran',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: colors.outline),
                    ),
                    dropdownColor: colors.surface,
                    style: typography.bodyLarge.copyWith(color: colors.onSurface),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  TextFormField(
                    controller: totalLateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Terlambat (menit)',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: colors.outline),
                    ),
                    style: typography.bodyLarge.copyWith(color: colors.onSurface),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  TextFormField(
                    controller: totalEarlyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Pulang Cepat (menit)',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: colors.outline),
                    ),
                    style: typography.bodyLarge.copyWith(color: colors.onSurface),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  TextFormField(
                    controller: totalWorkCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Kerja (menit)',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: colors.outline),
                    ),
                    style: typography.bodyLarge.copyWith(color: colors.onSurface),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  TextFormField(
                    controller: summaryNoteCtrl,
                    decoration: InputDecoration(
                      labelText: 'Catatan (Summary Note)',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: colors.outline),
                    ),
                    style: typography.bodyLarge.copyWith(color: colors.onSurface),
                  ),
                  SizedBox(height: AppSpacing.s24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.s32.h),
            
            // Attendance Records List
            Text('Log Presensi (Attendance Records)', style: typography.titleMedium.copyWith(color: colors.onBackground, fontWeight: FontWeight.bold)),
            SizedBox(height: AppSpacing.s12.h),
            
            if (attendanceRecords.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.s16.h),
                child: Text('Tidak ada log presensi.', style: typography.bodyMedium.copyWith(color: colors.outline)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attendanceRecords.length,
                itemBuilder: (context, index) {
                  final rec = attendanceRecords[index];
                  final type = rec['attendance_type']?['name'] ?? 'Unknown Type';
                  final attStatus = rec['status'] ?? 'Unknown';
                  final attendedAt = rec['attended_at'];
                  
                  // Format attended at
                  String timeStr = '-';
                  if (attendedAt != null) {
                    try {
                      final dt = DateTime.parse(attendedAt).toLocal();
                      timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    } catch (_) {}
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
                    child: AppCard(
                      padding: EdgeInsets.all(AppSpacing.s12.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(type, style: typography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold)),
                              SizedBox(height: AppSpacing.s4.h),
                              Text('Waktu: $timeStr', style: typography.bodySmall.copyWith(color: colors.outline)),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s4.h),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.r4),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Text(
                              attStatus.toString().toUpperCase(),
                              style: typography.labelSmall.copyWith(color: colors.outline, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
