import '../plantdb/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../mvc_models/riwayat.dart';

class RiwayatDao {
  final dbHelper = DBHelper();

  // INSERT
  Future<int> insertRiwayat(Riwayat riwayat) async {
    final db = await dbHelper.database;
    return await db.insert(
      'riwayat',
      riwayat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL RIWAYAT
  Future<List<Riwayat>> getAllRiwayat() async {
    final db = await dbHelper.database;
    final res = await db.query('riwayat');
    return res.map((e) => Riwayat.fromMap(e)).toList();
  }

  // GET RIWAYAT BY POHON
  Future<List<Riwayat>> getRiwayatByObjectId(String objectId) async {
    final db = await dbHelper.database;
    final res = await db.query(
      'riwayat',
      where: 'objectId = ?',
      whereArgs: [objectId],
    );
    return res.map((e) => Riwayat.fromMap(e)).toList();
  }

  // UPDATE
  Future<int> updateRiwayat(Riwayat riwayat) async {
    final db = await dbHelper.database;
    return await db.update(
      'riwayat',
      riwayat.toMap(),
      where: 'id = ?',
      whereArgs: [riwayat.id],
    );
  }

  // DELETE
  Future<int> deleteRiwayat(String id) async {
    final db = await dbHelper.database;
    return await db.delete('riwayat', where: 'id = ?', whereArgs: [id]);
  }
}
