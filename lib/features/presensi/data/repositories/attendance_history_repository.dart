import '../models/attendance_history_item.dart';
import '../models/attendance_history_summary.dart';

abstract class AttendanceHistoryRepository {
  Future<List<AttendanceHistoryItem>> fetchMonthlyHistory({
    required int month,
    required int year,
  });

  Future<AttendanceHistorySummary> fetchMonthlySummary({
    required int month,
    required int year,
  });
}

class MockAttendanceHistoryRepository implements AttendanceHistoryRepository {
  static const _delay = Duration(milliseconds: 700);

  static const Map<int, Set<int>> _holidaysByMonth = {
    1: {1},
    3: {29},
    4: {3, 10},
    5: {1, 14, 29},
    6: {1},
    8: {17},
    12: {25},
  };

  static const Map<int, Set<int>> _noScheduleByMonth = {
    1: {22},
    2: {14},
    3: {12},
    4: {17},
    5: {9, 21},
    6: {18},
    7: {11},
    8: {13},
    9: {16},
    10: {15},
    11: {20},
    12: {19},
  };

  static const Map<int, Set<int>> _permissionByMonth = {
    1: {8},
    2: {10},
    3: {5},
    4: {15},
    5: {6, 19},
    6: {23},
    7: {9},
    8: {26},
    9: {4},
    10: {7},
    11: {12},
    12: {3},
  };

  static const Map<int, Set<int>> _leaveByMonth = {
    1: {16},
    2: {20},
    3: {21},
    4: {24},
    5: {15},
    6: {6},
    7: {18},
    8: {22},
    9: {25},
    10: {28},
    11: {14},
    12: {11},
  };

  static const Map<int, Set<int>> _absentByMonth = {
    1: {27},
    2: {27},
    3: {26},
    4: {29},
    5: {23},
    6: {25},
    7: {30},
    8: {27},
    9: {24},
    10: {30},
    11: {26},
    12: {29},
  };

  @override
  Future<List<AttendanceHistoryItem>> fetchMonthlyHistory({
    required int month,
    required int year,
  }) async {
    await Future.delayed(_delay);
    return _buildMonthItems(month: month, year: year);
  }

  @override
  Future<AttendanceHistorySummary> fetchMonthlySummary({
    required int month,
    required int year,
  }) async {
    await Future.delayed(_delay);

    final totals = <AttendanceDayStatus, int>{
      for (final status in AttendanceDayStatus.values) status: 0,
    };

    for (final item in _buildMonthItems(month: month, year: year)) {
      totals[item.status] = (totals[item.status] ?? 0) + 1;
    }

    return AttendanceHistorySummary(
      month: month,
      year: year,
      totals: totals,
    );
  }

  List<AttendanceHistoryItem> _buildMonthItems({
    required int month,
    required int year,
  }) {
    final lastDay = DateTime(year, month + 1, 0).day;

    return List<AttendanceHistoryItem>.generate(lastDay, (index) {
      final date = DateTime(year, month, index + 1);
      final status = _resolveStatus(date);

      return AttendanceHistoryItem(
        date: date,
        status: status,
        label: _labelOf(status),
        checkInTime: status == AttendanceDayStatus.present ? '07:30' : null,
        checkOutTime: status == AttendanceDayStatus.present ? '16:00' : null,
        note: _noteOf(date, status),
      );
    });
  }

  AttendanceDayStatus _resolveStatus(DateTime date) {
    final month = date.month;
    final day = date.day;

    if (_holidaysByMonth[month]?.contains(day) ?? false) {
      return AttendanceDayStatus.holiday;
    }

    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return AttendanceDayStatus.weekend;
    }

    if (_noScheduleByMonth[month]?.contains(day) ?? false) {
      return AttendanceDayStatus.noSchedule;
    }

    if (_permissionByMonth[month]?.contains(day) ?? false) {
      return AttendanceDayStatus.permission;
    }

    if (_leaveByMonth[month]?.contains(day) ?? false) {
      return AttendanceDayStatus.leave;
    }

    if (_absentByMonth[month]?.contains(day) ?? false) {
      return AttendanceDayStatus.absent;
    }

    return AttendanceDayStatus.present;
  }

  String _labelOf(AttendanceDayStatus status) {
    return switch (status) {
      AttendanceDayStatus.present => 'Hadir',
      AttendanceDayStatus.absent => 'Alpha',
      AttendanceDayStatus.weekend => 'Weekend',
      AttendanceDayStatus.holiday => 'Libur',
      AttendanceDayStatus.noSchedule => 'Tidak Ada Jadwal',
      AttendanceDayStatus.permission => 'Izin',
      AttendanceDayStatus.leave => 'Cuti',
    };
  }

  String? _noteOf(DateTime date, AttendanceDayStatus status) {
    return switch (status) {
      AttendanceDayStatus.present => 'Masuk sesuai jadwal',
      AttendanceDayStatus.absent => 'Tidak ada presensi masuk',
      AttendanceDayStatus.weekend => 'Hari libur akhir pekan',
      AttendanceDayStatus.holiday => 'Libur instansi ${date.day}/${date.month}',
      AttendanceDayStatus.noSchedule => 'Tidak ada jadwal shift',
      AttendanceDayStatus.permission => 'Izin terverifikasi',
      AttendanceDayStatus.leave => 'Cuti disetujui',
    };
  }
}
