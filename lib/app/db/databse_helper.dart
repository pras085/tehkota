import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.model.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'users';
  static const columnId = 'userID';
  static const columnUser = 'user';
  static const columnModelData = 'model_data';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId TEXT PRIMARY KEY,
            $columnUser TEXT NOT NULL,
            $columnModelData TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(User user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<int> update(User user) async {
    Database db = await instance.database;
    return await db.update(table, user.toMap(), where: '$columnId = ?', whereArgs: [user.userName]);
  }

  Future<List<User>> queryAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(table);
    return users.map((u) => User.fromMap(u)).toList();
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<int> deleteSelectedUser(String userID) async {
    try {
      Database db = await instance.database;
      return await db.delete(table, where: '$columnId = ?', whereArgs: [userID]);
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print("Error while deleting user: $e");
      return 0; // atau kembalikan nilai lain sesuai kebutuhan aplikasi Anda
    }
  }
}
