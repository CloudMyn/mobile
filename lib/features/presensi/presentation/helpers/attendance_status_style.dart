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
    // Cek apakah mode aktif adalah Dark Mode dengan mendeteksi kecerahan background
    final isDark = colors.background.computeLuminance() < 0.5;

    return switch (this) {
      AttendanceDayStatus.workday => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFF90A4AE).withValues(alpha: 0.12) : const Color(0xFF5A636D).withValues(alpha: 0.08),
        borderColor: isDark ? const Color(0xFF90A4AE).withValues(alpha: 0.32) : const Color(0xFF5A636D).withValues(alpha: 0.24),
        foregroundColor: isDark ? const Color(0xFFCFD8DC) : const Color(0xFF455A64),
      ),
      AttendanceDayStatus.offday => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFB0BEC5).withValues(alpha: 0.12) : const Color(0xFF757575).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFB0BEC5).withValues(alpha: 0.32) : const Color(0xFF757575).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFECEFF1) : const Color(0xFF616161),
      ),
      AttendanceDayStatus.holiday => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFB39DDB).withValues(alpha: 0.12) : const Color(0xFF673AB7).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFB39DDB).withValues(alpha: 0.32) : const Color(0xFF673AB7).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFD1C4E9) : const Color(0xFF512DA8),
      ),
      AttendanceDayStatus.exempt => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFF9FA8DA).withValues(alpha: 0.12) : const Color(0xFF3F51B5).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFF9FA8DA).withValues(alpha: 0.32) : const Color(0xFF3F51B5).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFC5CAE9) : const Color(0xFF303F9F),
      ),
      AttendanceDayStatus.leave => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFF90CAF9).withValues(alpha: 0.12) : const Color(0xFF1976D2).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFF90CAF9).withValues(alpha: 0.32) : const Color(0xFF1976D2).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFBBDEFB) : const Color(0xFF0D47A1),
      ),
      AttendanceDayStatus.permit => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFFFB74D).withValues(alpha: 0.12) : const Color(0xFFE65100).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFFFB74D).withValues(alpha: 0.32) : const Color(0xFFE65100).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFFFE0B2) : const Color(0xFFE65100),
      ),
      AttendanceDayStatus.sick => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFFF8A65).withValues(alpha: 0.12) : const Color(0xFFD84315).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFFF8A65).withValues(alpha: 0.32) : const Color(0xFFD84315).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFFFCCBC) : const Color(0xFFBF360C),
      ),
      AttendanceDayStatus.wfh => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFF80CBC4).withValues(alpha: 0.12) : const Color(0xFF00796B).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFF80CBC4).withValues(alpha: 0.32) : const Color(0xFF00796B).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFE0F2F1) : const Color(0xFF004D40),
      ),
      AttendanceDayStatus.wfa => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFF80DEEA).withValues(alpha: 0.12) : const Color(0xFF00838F).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFF80DEEA).withValues(alpha: 0.32) : const Color(0xFF00838F).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFE0F7FA) : const Color(0xFF006064),
      ),
      AttendanceDayStatus.outsideDuty => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFD7CCC8).withValues(alpha: 0.12) : const Color(0xFF8D6E63).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFD7CCC8).withValues(alpha: 0.32) : const Color(0xFF8D6E63).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFEFEBE9) : const Color(0xFF4E342E),
      ),
      AttendanceDayStatus.present => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFF81C784).withValues(alpha: 0.12) : const Color(0xFF2E7D32).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFF81C784).withValues(alpha: 0.32) : const Color(0xFF2E7D32).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFE8F5E9) : const Color(0xFF1B5E20),
      ),
      AttendanceDayStatus.partial => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFAED581).withValues(alpha: 0.12) : const Color(0xFF558B2F).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFAED581).withValues(alpha: 0.32) : const Color(0xFF558B2F).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFF1F8E9) : const Color(0xFF33691E),
      ),
      AttendanceDayStatus.absent => AttendanceStatusStyle(
        backgroundColor: isDark ? const Color(0xFFEF9A9A).withValues(alpha: 0.12) : const Color(0xFFC62828).withValues(alpha: 0.10),
        borderColor: isDark ? const Color(0xFFEF9A9A).withValues(alpha: 0.32) : const Color(0xFFC62828).withValues(alpha: 0.30),
        foregroundColor: isDark ? const Color(0xFFFFEBEE) : const Color(0xFFB71C1C),
      ),
    };
  }
}
