import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'request_log_entry.dart';

/// SQLite database helper untuk menyimpan request/response logs.
///
/// - Auto-creates table on first open.
/// - Auto-prunes entries older than [_maxAgeDays] or exceeding [_maxEntries].
/// - Mendukung in-memory fallback otomatis jika plugin SQLite tidak tersedia/error (misal di Web atau saat platform channel error).
class RequestLogDb {
  RequestLogDb._();
  static final RequestLogDb instance = RequestLogDb._();

  static const _dbName = 'request_logs.db';
  static const _dbVersion = 1;
  static const _tableName = 'request_logs';
  static const _maxEntries = 5000;
  static const _maxAgeDays = 7;

  Database? _database;
  bool _useInMemoryFallback = false;
  final List<RequestLogEntry> _inMemoryLogs = [];
  int _nextInMemoryId = 1;

  /// Getter database utama. Mengembalikan null jika in-memory fallback aktif.
  Future<Database?> get database async {
    if (_useInMemoryFallback) return null;
    try {
      _database ??= await _initDb();
      return _database;
    } catch (e) {
      _useInMemoryFallback = true;
      debugPrint('RequestLogDb: SQLite initialization failed, falling back to in-memory mode. Error: $e');
      return null;
    }
  }

  Future<Database> _initDb() async {
    // Inisialisasi FFI untuk desktop platforms (Windows / Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT NOT NULL,
            url TEXT NOT NULL,
            request_headers TEXT,
            request_body TEXT,
            request_size INTEGER DEFAULT 0,
            status_code INTEGER,
            response_body TEXT,
            response_size INTEGER DEFAULT 0,
            duration_ms INTEGER DEFAULT 0,
            timestamp TEXT NOT NULL,
            is_error INTEGER DEFAULT 0
          )
        ''');
        // Index untuk query yang sering dipakai
        await db.execute(
          'CREATE INDEX idx_timestamp ON $_tableName (timestamp DESC)',
        );
        await db.execute(
          'CREATE INDEX idx_method ON $_tableName (method)',
        );
        await db.execute(
          'CREATE INDEX idx_is_error ON $_tableName (is_error)',
        );
      },
    );
  }

  /// Insert log entry baru dan jalankan auto-prune.
  Future<int> insertLog(RequestLogEntry entry) async {
    try {
      final db = await database;
      if (db != null) {
        final id = await db.insert(_tableName, entry.toMap());
        // Auto-prune di database secara background
        _pruneOldLogs(db);
        return id;
      }
    } catch (e) {
      _useInMemoryFallback = true;
      debugPrint('RequestLogDb: insertLog failed, falling back to in-memory mode. Error: $e');
    }

    // In-memory fallback
    final id = _nextInMemoryId++;
    final fallbackEntry = entry.copyWith(id: id);
    _inMemoryLogs.add(fallbackEntry);
    
    // Auto-prune in-memory
    _pruneInMemoryLogs();
    
    return id;
  }

  /// Query logs dengan filter opsional.
  Future<List<RequestLogEntry>> getLogs({
    String? method,
    bool? isError,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final db = await database;
      if (db != null) {
        final where = <String>[];
        final whereArgs = <dynamic>[];

        if (method != null && method.isNotEmpty) {
          where.add('method = ?');
          whereArgs.add(method);
        }

        if (isError != null) {
          where.add('is_error = ?');
          whereArgs.add(isError ? 1 : 0);
        }

        if (search != null && search.isNotEmpty) {
          where.add('url LIKE ?');
          whereArgs.add('%$search%');
        }

        if (startDate != null) {
          where.add('timestamp >= ?');
          whereArgs.add(startDate.toIso8601String());
        }

        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day + 1);
          where.add('timestamp < ?');
          whereArgs.add(endOfDay.toIso8601String());
        }

        final rows = await db.query(
          _tableName,
          where: where.isNotEmpty ? where.join(' AND ') : null,
          whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
          orderBy: 'timestamp DESC',
          limit: limit,
          offset: offset,
        );

        return rows.map(RequestLogEntry.fromMap).toList();
      }
    } catch (e) {
      _useInMemoryFallback = true;
      debugPrint('RequestLogDb: getLogs failed, falling back to in-memory mode. Error: $e');
    }

    // In-memory fallback
    Iterable<RequestLogEntry> filtered = _inMemoryLogs;

    if (method != null && method.isNotEmpty) {
      filtered = filtered.where((entry) => entry.method.toUpperCase() == method.toUpperCase());
    }

    if (isError != null) {
      filtered = filtered.where((entry) => entry.isError == isError);
    }

    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filtered = filtered.where((entry) => entry.url.toLowerCase().contains(searchLower));
    }

    if (startDate != null) {
      filtered = filtered.where((entry) => entry.timestamp.isAfter(startDate) || entry.timestamp.isAtSameMomentAs(startDate));
    }

    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day + 1);
      filtered = filtered.where((entry) => entry.timestamp.isBefore(endOfDay));
    }

    // Sort by timestamp DESC
    final sorted = filtered.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Paginate
    if (offset >= sorted.length) return [];
    final end = (offset + limit < sorted.length) ? offset + limit : sorted.length;
    return sorted.sublist(offset, end);
  }

  /// Ambil satu log entry berdasarkan ID.
  Future<RequestLogEntry?> getLogById(int id) async {
    try {
      final db = await database;
      if (db != null) {
        final rows = await db.query(
          _tableName,
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (rows.isEmpty) return null;
        return RequestLogEntry.fromMap(rows.first);
      }
    } catch (e) {
      _useInMemoryFallback = true;
      debugPrint('RequestLogDb: getLogById failed, falling back to in-memory mode. Error: $e');
    }

    // In-memory fallback
    try {
      return _inMemoryLogs.firstWhere((entry) => entry.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Hitung total log entries (dengan filter opsional).
  Future<int> getCount({
    String? method,
    bool? isError,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await database;
      if (db != null) {
        final where = <String>[];
        final whereArgs = <dynamic>[];

        if (method != null && method.isNotEmpty) {
          where.add('method = ?');
          whereArgs.add(method);
        }

        if (isError != null) {
          where.add('is_error = ?');
          whereArgs.add(isError ? 1 : 0);
        }

        if (search != null && search.isNotEmpty) {
          where.add('url LIKE ?');
          whereArgs.add('%$search%');
        }

        if (startDate != null) {
          where.add('timestamp >= ?');
          whereArgs.add(startDate.toIso8601String());
        }

        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day + 1);
          where.add('timestamp < ?');
          whereArgs.add(endOfDay.toIso8601String());
        }

        final result = await db.rawQuery(
          'SELECT COUNT(*) as cnt FROM $_tableName'
          '${where.isNotEmpty ? ' WHERE ${where.join(' AND ')}' : ''}',
          whereArgs.isNotEmpty ? whereArgs : null,
        );
        return Sqflite.firstIntValue(result) ?? 0;
      }
    } catch (e) {
      _useInMemoryFallback = true;
      debugPrint('RequestLogDb: getCount failed, falling back to in-memory mode. Error: $e');
    }

    // In-memory fallback
    Iterable<RequestLogEntry> filtered = _inMemoryLogs;

    if (method != null && method.isNotEmpty) {
      filtered = filtered.where((entry) => entry.method.toUpperCase() == method.toUpperCase());
    }

    if (isError != null) {
      filtered = filtered.where((entry) => entry.isError == isError);
    }

    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filtered = filtered.where((entry) => entry.url.toLowerCase().contains(searchLower));
    }

    if (startDate != null) {
      filtered = filtered.where((entry) => entry.timestamp.isAfter(startDate) || entry.timestamp.isAtSameMomentAs(startDate));
    }

    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day + 1);
      filtered = filtered.where((entry) => entry.timestamp.isBefore(endOfDay));
    }

    return filtered.length;
  }

  /// Hapus semua log entries.
  Future<void> clearAll() async {
    try {
      final db = await database;
      if (db != null) {
        await db.delete(_tableName);
        return;
      }
    } catch (e) {
      _useInMemoryFallback = true;
      debugPrint('RequestLogDb: clearAll failed, falling back to in-memory mode. Error: $e');
    }

    // In-memory fallback
    _inMemoryLogs.clear();
  }

  /// Hapus log yang melebihi batas umur atau jumlah.
  Future<void> _pruneOldLogs(Database db) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: _maxAgeDays));
      await db.delete(
        _tableName,
        where: 'timestamp < ?',
        whereArgs: [cutoff.toIso8601String()],
      );

      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
      ) ?? 0;

      if (count > _maxEntries) {
        await db.rawDelete('''
          DELETE FROM $_tableName
          WHERE id NOT IN (
            SELECT id FROM $_tableName
            ORDER BY timestamp DESC
            LIMIT $_maxEntries
          )
        ''');
      }
    } catch (e) {
      debugPrint('RequestLogDb: _pruneOldLogs failed. Error: $e');
    }
  }

  /// Hapus log yang melebihi batas umur atau jumlah (in-memory fallback).
  void _pruneInMemoryLogs() {
    final cutoff = DateTime.now().subtract(const Duration(days: _maxAgeDays));
    _inMemoryLogs.removeWhere((entry) => entry.timestamp.isBefore(cutoff));

    if (_inMemoryLogs.length > _maxEntries) {
      _inMemoryLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _inMemoryLogs.removeRange(_maxEntries, _inMemoryLogs.length);
    }
  }

  /// Tutup database connection.
  Future<void> close() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
      }
    } catch (e) {
      debugPrint('RequestLogDb: close failed. Error: $e');
    }
  }
}
