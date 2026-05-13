import 'package:flutter/material.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../data/models/attendance_history_item.dart';

class AttendanceStatusStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  const AttendanceStatusStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
  });
}

extension AttendanceDayStatusPresentation on AttendanceDayStatus {
  String get label {
    return switch (this) {
      AttendanceDayStatus.present => 'Hadir',
      AttendanceDayStatus.absent => 'Alpha',
      AttendanceDayStatus.weekend => 'Weekend',
      AttendanceDayStatus.holiday => 'Libur',
      AttendanceDayStatus.noSchedule => 'Tidak Ada Jadwal',
      AttendanceDayStatus.permission => 'Izin',
      AttendanceDayStatus.leave => 'Cuti',
    };
  }

  AttendanceStatusStyle resolveStyle(AppColors colors) {
    return switch (this) {
      AttendanceDayStatus.present => AttendanceStatusStyle(
        backgroundColor: colors.success.withValues(alpha: 0.12),
        borderColor: colors.success.withValues(alpha: 0.38),
        foregroundColor: colors.success,
      ),
      AttendanceDayStatus.absent => AttendanceStatusStyle(
        backgroundColor: colors.error.withValues(alpha: 0.10),
        borderColor: colors.error.withValues(alpha: 0.32),
        foregroundColor: colors.error,
      ),
      AttendanceDayStatus.weekend => AttendanceStatusStyle(
        backgroundColor: colors.outline.withValues(alpha: 0.08),
        borderColor: colors.outline.withValues(alpha: 0.28),
        foregroundColor: colors.onSurface.withValues(alpha: 0.70),
      ),
      AttendanceDayStatus.holiday => AttendanceStatusStyle(
        backgroundColor: colors.secondary.withValues(alpha: 0.12),
        borderColor: colors.secondary.withValues(alpha: 0.32),
        foregroundColor: colors.secondary,
      ),
      AttendanceDayStatus.noSchedule => AttendanceStatusStyle(
        backgroundColor: colors.outline.withValues(alpha: 0.04),
        borderColor: colors.outline.withValues(alpha: 0.18),
        foregroundColor: colors.outline,
      ),
      AttendanceDayStatus.permission => AttendanceStatusStyle(
        backgroundColor: colors.warning.withValues(alpha: 0.12),
        borderColor: colors.warning.withValues(alpha: 0.32),
        foregroundColor: colors.warning,
      ),
      AttendanceDayStatus.leave => AttendanceStatusStyle(
        backgroundColor: colors.primary.withValues(alpha: 0.10),
        borderColor: colors.primary.withValues(alpha: 0.30),
        foregroundColor: colors.primary,
      ),
    };
  }
}
