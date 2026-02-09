import 'package:sqflite/sqflite.dart';
import '../plantdb/db_helper.dart';
import '../mvc_models/reposisi.dart';

class ReposisiDao {
  final DBHelper _dbHelper = DBHelper();

  // INSERT
  Future<int> insertReposisi(Reposisi data) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'reposisi',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL
  Future<List<Reposisi>> getAllReposisi() async {
    final db = await _dbHelper.database;
    final result = await db.query('reposisi');
    return result.map((e) => Reposisi.fromMap(e)).toList();
  }

  Future<List<Reposisi>> getAllZeroReposisi() async {
    final db = await _dbHelper.database;
    final res = await db.query(
        'reposisi',
        where: 'flag = 0'
    );
    return res.map((e) => Reposisi.fromMap(e)).toList();
  }

  Future<List<Reposisi>> getAllByFlagX() async {
    final db = await _dbHelper.database;
    final res = await db.query(
        'reposisi',
        where: 'flag = 0'
    );
    return res.map((e) => Reposisi.fromMap(e)).toList();
  }

  Future<List<Reposisi>> getTenByFlag() async {
    final db = await _dbHelper.database;
    final res = await db.query('reposisi', where: 'flag = 0', limit: 10,);
    return res.map((e) => Reposisi.fromMap(e)).toList();
  }

  // GET BY PRIMARY KEY
  Future<Reposisi?> getByIdReposisi(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reposisi',
      where: 'idReposisi = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Reposisi.fromMap(result.first);
    }
    return null;
  }

  // GET BY idTanaman
  Future<List<Reposisi>> getByIdTanaman(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reposisi',
      where: 'idTanaman = ?',
      whereArgs: [id],
    );
    return result.map((e) => Reposisi.fromMap(e)).toList();
  }

  Future<int> countUnsyncedReposisi() async {
    final db = await _dbHelper.database;
    // Menggunakan rawQuery untuk mendapatkan jumlah baris secara efisien
    final res = await db.rawQuery('SELECT COUNT(*) FROM reposisi WHERE flag = 0');

    // Mengambil angka pertama dari hasil query
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> updateReposisi(Reposisi reposisi) async {
    final db = await _dbHelper.database;
    return await db.update(
      'reposisi',
      reposisi.toMap(),
      where: 'idReposisi = ?',
      whereArgs: [reposisi.idReposisi],
    );
  }

  Future<void> updateFlag(String idReposisi) async {
    final db = await _dbHelper.database;
    await db.update(
      'reposisi',
      {'flag': 1}, // menandai sudah sync
      where: 'idReposisi = ?',
      whereArgs: [idReposisi],
    );
  }

  // DELETE ALL
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete('reposisi');
  }
}
