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
    return AttendanceHistoryItem.getLabelForStatus(this);
  }

  AttendanceStatusStyle resolveStyle(AppColors colors) {
    return switch (this) {
      AttendanceDayStatus.workday => AttendanceStatusStyle(
        backgroundColor: colors.outline.withValues(alpha: 0.04),
        borderColor: colors.outline.withValues(alpha: 0.18),
        foregroundColor: colors.outline,
      ),
      AttendanceDayStatus.offday => AttendanceStatusStyle(
        backgroundColor: colors.outline.withValues(alpha: 0.08),
        borderColor: colors.outline.withValues(alpha: 0.28),
        foregroundColor: colors.onSurface.withValues(alpha: 0.70),
      ),
      AttendanceDayStatus.holiday => AttendanceStatusStyle(
        backgroundColor: colors.secondary.withValues(alpha: 0.12),
        borderColor: colors.secondary.withValues(alpha: 0.32),
        foregroundColor: colors.secondary,
      ),
      AttendanceDayStatus.exempt => AttendanceStatusStyle(
        backgroundColor: colors.outline.withValues(alpha: 0.12),
        borderColor: colors.outline.withValues(alpha: 0.38),
        foregroundColor: colors.onSurface,
      ),
      AttendanceDayStatus.leave => AttendanceStatusStyle(
        backgroundColor: colors.primary.withValues(alpha: 0.10),
        borderColor: colors.primary.withValues(alpha: 0.30),
        foregroundColor: colors.primary,
      ),
      AttendanceDayStatus.permit => AttendanceStatusStyle(
        backgroundColor: colors.warning.withValues(alpha: 0.12),
        borderColor: colors.warning.withValues(alpha: 0.32),
        foregroundColor: colors.warning,
      ),
      AttendanceDayStatus.sick => AttendanceStatusStyle(
        backgroundColor: colors.warning.withValues(alpha: 0.18),
        borderColor: colors.warning.withValues(alpha: 0.42),
        foregroundColor: colors.warning,
      ),
      AttendanceDayStatus.wfh => AttendanceStatusStyle(
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        borderColor: colors.primary.withValues(alpha: 0.32),
        foregroundColor: colors.primary,
      ),
      AttendanceDayStatus.wfa => AttendanceStatusStyle(
        backgroundColor: colors.primary.withValues(alpha: 0.10),
        borderColor: colors.primary.withValues(alpha: 0.28),
        foregroundColor: colors.primary,
      ),
      AttendanceDayStatus.outsideDuty => AttendanceStatusStyle(
        backgroundColor: colors.secondary.withValues(alpha: 0.10),
        borderColor: colors.secondary.withValues(alpha: 0.28),
        foregroundColor: colors.secondary,
      ),
      AttendanceDayStatus.present => AttendanceStatusStyle(
        backgroundColor: colors.success.withValues(alpha: 0.12),
        borderColor: colors.success.withValues(alpha: 0.38),
        foregroundColor: colors.success,
      ),
      AttendanceDayStatus.partial => AttendanceStatusStyle(
        backgroundColor: colors.success.withValues(alpha: 0.08),
        borderColor: colors.success.withValues(alpha: 0.28),
        foregroundColor: colors.success,
      ),
      AttendanceDayStatus.absent => AttendanceStatusStyle(
        backgroundColor: colors.error.withValues(alpha: 0.10),
        borderColor: colors.error.withValues(alpha: 0.32),
        foregroundColor: colors.error,
      ),
    };
  }
}
