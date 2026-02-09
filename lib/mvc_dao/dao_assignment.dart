import '../plantdb/db_helper.dart';
import '../mvc_models/assignment.dart';
import 'package:sqflite/sqflite.dart';

class AssignmentDao {
  final dbHelper = DBHelper();

  Future<int> insertAssignment(Assignment assignment) async {
    final db = await dbHelper.database;
    return await db.insert(
      'assignment',
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertListAssignment(List<Assignment> assignments) async {
    final db = await dbHelper.database;
    int count = 0;

    for (var item in assignments) {
      await db.insert(
        'assignment',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;
    }

    return count; // jumlah data yang berhasil diinsert
  }

  Future<int> insertAssignmentsBatch(List<Assignment> assignments) async {
    final db = await dbHelper.database;

    // Mulai batch
    final batch = db.batch();

    // Tambahkan semua perintah insert ke dalam batch
    for (var item in assignments) {
      batch.insert(
        'assignment',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Eksekusi batch
    await batch.commit(noResult: true);

    // Return jumlah data yang diinsert
    return assignments.length;
  }

  Future<List<Assignment>> getAllAssignment() async {
    final db = await dbHelper.database;
    final res = await db.query('assignment');
    return res.map((e) => Assignment.fromMap(e)).toList();
  }

  Future<Assignment?> getAssignmentById(String id) async {
    final db = await dbHelper.database;
    final res = await db.query('assignment', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return Assignment.fromMap(res.first);
    return null;
  }

  Future<int> updateAssignment(Assignment assignment) async {
    final db = await dbHelper.database;
    return await db.update(
      'assignment',
      assignment.toMap(),
      where: 'id = ?',
      whereArgs: [assignment.id],
    );
  }

  Future<int> deleteAssignment(String id) async {
    final db = await dbHelper.database;
    return await db.delete('assignment', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllAssignments() async {
    final db = await dbHelper.database;

    // Hapus semua data
    return await db.delete('assignment');
  }
}
