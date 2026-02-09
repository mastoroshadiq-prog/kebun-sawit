import 'package:sqflite/sqflite.dart';
import '../plantdb/db_helper.dart';

class DaoManager {
  final DBHelper _dbHelper = DBHelper();
  //late Database _database;
  static final DaoManager _instance = DaoManager._internal();

  factory DaoManager() {
    return _instance;
  }

  DaoManager._internal();

  /// Mendapatkan daftar semua nama tabel
  Future<List<String>> getAllTableNames() async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      return result.map((row) => row['name'] as String).toList();
    } catch (e) {
      //print('Error getting table names: $e');
      return [];
    }
  }

  /// Query semua data dari tabel tertentu
  Future<List<Map<String, dynamic>>> queryTable(String tableName) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.query(tableName);
      return result;
    } catch (e) {
      //print('Error querying table $tableName: $e');
      return [];
    }
  }

  /// Query dengan kondisi WHERE
  Future<List<Map<String, dynamic>>> queryTableWhere(
    String tableName,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
      );
      return result;
    } catch (e) {
      //print('Error querying table $tableName with where: $e');
      return [];
    }
  }

  /// Query dengan limit dan offset untuk pagination
  Future<List<Map<String, dynamic>>> queryTablePaginated(
    String tableName, {
    int limit = 20,
    int offset = 0,
    String? orderBy,
  }) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.query(
        tableName,
        limit: limit,
        offset: offset,
        orderBy: orderBy,
      );
      return result;
    } catch (e) {
      //print('Error querying table $tableName with pagination: $e');
      return [];
    }
  }

  /// Menghitung total baris dalam tabel
  Future<int> countRecords(String tableName) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      //print('Error counting records in $tableName: $e');
      return 0;
    }
  }

  /// Insert data ke tabel
  Future<int> insertRecord(String tableName, Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final id = await db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      //print('Error inserting into $tableName: $e');
      throw Exception('Gagal menambahkan data: $e');
    }
  }

  /// Update data di tabel
  Future<int> updateRecord(String tableName, Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final id = data['id'];
      if (id == null) {
        throw Exception('ID tidak ditemukan dalam data');
      }

      final count = await db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count;
    } catch (e) {
      //print('Error updating $tableName: $e');
      throw Exception('Gagal mengupdate data: $e');
    }
  }

  /// Update data dengan kondisi custom
  Future<int> updateRecordWhere(
    String tableName,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final count = await db.update(
        tableName,
        data,
        where: where,
        whereArgs: whereArgs,
      );
      return count;
    } catch (e) {
      //print('Error updating $tableName with where: $e');
      throw Exception('Gagal mengupdate data: $e');
    }
  }

  /// Delete data dari tabel
  Future<int> deleteRecord(
    String tableName,
    Map<String, dynamic> record,
  ) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final id = record['id'];
      if (id == null) {
        throw Exception('ID tidak ditemukan dalam data');
      }

      final count = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count;
    } catch (e) {
      //print('Error deleting from $tableName: $e');
      throw Exception('Gagal menghapus data: $e');
    }
  }

  /// Delete data dengan kondisi custom
  Future<int> deleteRecordWhere(
    String tableName,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final count = await db.delete(
        tableName,
        where: where,
        whereArgs: whereArgs,
      );
      return count;
    } catch (e) {
      //print('Error deleting from $tableName with where: $e');
      throw Exception('Gagal menghapus data: $e');
    }
  }

  /// Delete semua data dari tabel
  Future<int> deleteAllRecords(String tableName) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final count = await db.delete(tableName);
      return count;
    } catch (e) {
      //print('Error deleting all from $tableName: $e');
      throw Exception('Gagal menghapus semua data: $e');
    }
  }

  /// Raw query untuk query kompleks
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.rawQuery(sql, arguments);
      return result;
    } catch (e) {
      //print('Error executing raw query: $e');
      throw Exception('Gagal menjalankan query: $e');
    }
  }

  /// Raw insert/update/delete
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    //final db = await _dbHelper.database;
    //final db = await database;
    try {
      //await db.rawExecute(sql, arguments);
      return 1;
    } catch (e) {
      //print('Error executing raw: $e');
      throw Exception('Gagal menjalankan perintah: $e');
    }
  }

  /// Batch operations
  Future<List<Object?>> batch(List<DatabaseOperation> operations) async {
    final db = await _dbHelper.database;
    //final db = await database;
    final batch = db.batch();
    try {
      for (var op in operations) {
        switch (op.type) {
          case OperationType.insert:
            batch.insert(
              op.table,
              op.data!,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            break;
          case OperationType.update:
            batch.update(
              op.table,
              op.data!,
              where: op.where,
              whereArgs: op.whereArgs,
            );
            break;
          case OperationType.delete:
            batch.delete(op.table, where: op.where, whereArgs: op.whereArgs);
            break;
        }
      }
      return await batch.commit();
    } catch (e) {
      //print('Error executing batch: $e');
      throw Exception('Gagal menjalankan batch operation: $e');
    }
  }

  /// Transaction
  Future<T> transaction<T>(Future<T> Function() action) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      return await db.transaction((txn) async {
        return await action();
      });
    } catch (e) {
      //print('Error in transaction: $e');
      throw Exception('Gagal menjalankan transaksi: $e');
    }
  }

  /// Get schema (struktur) tabel
  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.rawQuery('PRAGMA table_info($tableName)');
      return result;
    } catch (e) {
      //print('Error getting table schema: $e');
      return [];
    }
  }

  /// Cek apakah tabel ada
  Future<bool> tableExists(String tableName) async {
    final db = await _dbHelper.database;
    //final db = await database;
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      //print('Error checking table existence: $e');
      return false;
    }
  }

  /// Close database
  /*
  Future<void> closeDatabase() async {
    if (_isInitialized) {
      await _database.close();
      _isInitialized = false;
    }
  }
  */
}

// Model untuk batch operations
class DatabaseOperation {
  final String table;
  final OperationType type;
  final Map<String, dynamic>? data;
  final String? where;
  final List<dynamic>? whereArgs;

  DatabaseOperation({
    required this.table,
    required this.type,
    this.data,
    this.where,
    this.whereArgs,
  });
}

enum OperationType { insert, update, delete }
