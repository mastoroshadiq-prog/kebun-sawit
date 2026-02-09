import 'package:sqflite/sqflite.dart';
import '../plantdb/db_helper.dart';
import '../mvc_models/spr_log.dart';

class SPRLogDao {
  final DBHelper _dbHelper = DBHelper();

  // INSERT / UPDATE
  Future<int> insertSPR(SPRLog data) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'spr_log',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL
  Future<List<SPRLog>> getAllSPRLog() async {
    final db = await _dbHelper.database;
    final result = await db.query('spr_log');
    return result.map((e) => SPRLog.fromMap(e)).toList();
  }

  Future<List<SPRLog>> getAllZeroSPRLog() async {
    final db = await _dbHelper.database;
    final res = await db.query(
        'spr_log',
        where: 'flag = 0'
    );
    return res.map((e) => SPRLog.fromMap(e)).toList();
  }

  Future<List<SPRLog>> getAllByFlagX() async {
    final db = await _dbHelper.database;
    final res = await db.query(
        'spr_log',
        where: 'flag = 0'
    );
    return res.map((e) => SPRLog.fromMap(e)).toList();
  }

  Future<List<SPRLog>> getTenByFlag() async {
    final db = await _dbHelper.database;
    final res = await db.query('spr_log', where: 'flag = 0', limit: 10,);
    return res.map((e) => SPRLog.fromMap(e)).toList();
  }

  // GET BY PRIMARY KEY
  Future<SPRLog?> getByIdSPRLog(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'spr_log',
      where: 'idLog = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return SPRLog.fromMap(result.first);
    }
    return null;
  }

  // GET BY idTanaman
  Future<List<SPRLog>> getByIdLog(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'spr_log',
      where: 'idLog = ?',
      whereArgs: [id],
    );
    return result.map((e) => SPRLog.fromMap(e)).toList();
  }

  Future<int> countUnsyncedSPRLog() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) FROM spr_log WHERE flag = 0');

    // Mengambil angka pertama dari hasil query
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> updateSPR(SPRLog spr) async {
    final db = await _dbHelper.database;
    return await db.update(
      'spr_log',
      spr.toMap(),
      where: 'idLog = ?',
      whereArgs: [spr.idLog],
    );
  }

  Future<void> updateFlagByBlokNBaris(String blok, String nbaris) async {
    final db = await _dbHelper.database;
    await db.update(
      'spr_log',
      {'flag': 1}, // menandai sudah sync
      where: 'blok = ? AND baris = ?',
      whereArgs: [blok, nbaris],
    );
  }

  Future<void> updateFlag(String idLog) async {
    final db = await _dbHelper.database;
    await db.update(
      'spr_log',
      {'flag': 1}, // menandai sudah sync
      where: 'idLog = ?',
      whereArgs: [idLog],
    );
  }

  // DELETE ALL
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('spr_log');
  }

}