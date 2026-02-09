import '../plantdb/db_helper.dart';
import '../mvc_models/kesehatan.dart';
import 'package:sqflite/sqflite.dart';

class KesehatanDao {
  final dbHelper = DBHelper();

  Future<int> insertKesehatan(Kesehatan kesehatan) async {
    final db = await dbHelper.database;
    return await db.insert(
      'kesehatan',
      kesehatan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertListKesehatan(List<Kesehatan> kesehatans) async {
    final db = await dbHelper.database;
    int count = 0;

    for (var item in kesehatans) {
      await db.insert(
        'kesehatan',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;
    }
    return count; // jumlah data yang berhasil diinsert
  }

  Future<int> insertKesehatanBatch(List<Kesehatan> kesehatans) async {
    final db = await dbHelper.database;

    // Mulai batch
    final batch = db.batch();

    // Tambahkan semua perintah insert ke dalam batch
    for (var item in kesehatans) {
      batch.insert(
        'kesehatan',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Eksekusi batch
    await batch.commit(noResult: true);

    // Return jumlah data yang diinsert
    return kesehatans.length;
  }

  Future<List<Kesehatan>> getAllKesehatan() async {
    final db = await dbHelper.database;
    final res = await db.query('kesehatan');
    return res.map((e) => Kesehatan.fromMap(e)).toList();
  }

  Future<List<Kesehatan>> getAllZeroKesehatan() async {
    final db = await dbHelper.database;
    final res = await db.query('kesehatan', where: 'flag = 0');
    return res.map((e) => Kesehatan.fromMap(e)).toList();
  }

  Future<List<Kesehatan>> getAllByFlag() async {
    final db = await dbHelper.database;
    final res = await db.query('kesehatan', where: 'flag = 0' , limit: 10,);
    return res.map((e) => Kesehatan.fromMap(e)).toList();
  }

  Future<Kesehatan?> getKesehatanById(String idKesehatan) async {
    final db = await dbHelper.database;
    final res = await db.query(
      'kesehatan',
      where: 'idKesehatan = ?',
      whereArgs: [idKesehatan],
    );
    if (res.isNotEmpty) return Kesehatan.fromMap(res.first);
    return null;
  }

  Future<int> updateKesehatan(Kesehatan kesehatan) async {
    final db = await dbHelper.database;
    return await db.update(
      'kesehatan',
      kesehatan.toMap(),
      where: 'id = ?',
      whereArgs: [kesehatan.idKesehatan],
    );
  }

  Future<void> updateFlag(String idKesehatan) async {
    // contoh: update flag=1 untuk record tertentu
    final db = await dbHelper.database;
    await db.update(
      'kesehatan',
      {'flag': 1}, // menandai sudah sync
      where: 'idKesehatan = ?',
      whereArgs: [idKesehatan],
    );
  }

  Future<int> deleteKesehatan(String idKesehatan) async {
    final db = await dbHelper.database;
    return await db.delete(
      'kesehatan',
      where: 'idKesehatan = ?',
      whereArgs: [idKesehatan],
    );
  }

  Future<int> deleteAllAssignments() async {
    final db = await dbHelper.database;

    // Hapus semua data
    return await db.delete('kesehatan');
  }
}
