import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../plantdb/db_helper.dart';
import '../mvc_models/audit_log.dart';
import '../mvc_models/petugas.dart';
import 'dao_petugas.dart';

class AuditLogDao {
  final DBHelper _dbHelper = DBHelper();
  final uuid = Uuid().v4();

  // INSERT
  Future<int> insertAuditLog(AuditLog data) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'auditlog',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL
  Future<List<AuditLog>> getAllAuditLog() async {
    final db = await _dbHelper.database;
    final result = await db.query('auditlog');
    return result.map((e) => AuditLog.fromMap(e)).toList();
  }

  Future<List<AuditLog>> getAllZeroAuditLog() async {
    final db = await _dbHelper.database;
    final res = await db.query('auditlog', where: 'flag = 0',);
    return res.map((e) => AuditLog.fromMap(e)).toList();
  }

  Future<List<AuditLog>> getAllByFlag() async {
    final db = await _dbHelper.database;
    final res = await db.query('auditlog', where: 'flag = 0', limit: 10,);
    return res.map((e) => AuditLog.fromMap(e)).toList();
  }

  Future<int> countUnsyncedAuditLog() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM auditlog WHERE flag = 0');

    // Mengambil angka pertama dari hasil query
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> updateFlag(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'auditlog',
      {'flag': 1},
      where: 'id_audit = ?',
      whereArgs: [id],
    );
  }

  Future<void> createLog(String action, String detail) async {
    Petugas? p = await PetugasDao().getPetugas();
    final deviceName = await getDeviceName();
    final logDate = DateTime.now().toIso8601String();

    final log = AuditLog(
      idAudit: uuid.toUpperCase(),
      userId: p!.akun,
      action: action,
      detail: detail,
      logDate: logDate,
      device: deviceName,
      flag: 0,
    );

    await insertAuditLog(log);
  }

  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    } else {
      return "Unknown Device";
    }
  }
}
