import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class memomodel {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    detail TEXT,
    created At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'memo.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String? detail) async {
    final db = await memomodel.db();

    final data = {'title': title, 'detail': detail,};
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getmemos() async {
    final db = await memomodel.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getmemo(int id) async {
    final db = await memomodel.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updatememo(int id, String title, String? detail) async {
    final db = await memomodel.db();

    final data = {
      'title': title,
      'detail': detail,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deletememo(int id) async {
    final db = await memomodel.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("項目の削除に何らかの問題が発生しました。");
    }
  }
}