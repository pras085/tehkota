import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.model.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  // Default table and column names
  static const userTable = 'users';
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
    // Create default table
    await db.execute('''
          CREATE TABLE $userTable (
            $columnId TEXT PRIMARY KEY,
            $columnUser TEXT NOT NULL,
            $columnModelData TEXT NOT NULL
          )
          ''');
  }

  // Method to create a new table dynamically
  Future<void> createTable(String tableName, Map<String, String> columns) async {
    Database db = await instance.database;
    String columnDefs = columns.entries.map((e) => '${e.key} ${e.value}').join(', ');
    await db.execute('''
          CREATE TABLE $tableName (
            $columnDefs
          )
          ''');
  }

  Future<int> insert(User user) async {
    Database db = await instance.database;
    return await db.insert(userTable, user.toMap());
  }

  Future<int> update(User user) async {
    Database db = await instance.database;
    return await db.update(userTable, user.toMap(), where: '$columnId = ?', whereArgs: [user.userName]);
  }

  Future<List<User>> queryAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(userTable);
    return users.map((u) => User.fromMap(u)).toList();
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(userTable);
  }

  Future<int> deleteSelectedUser(String userID) async {
    try {
      Database db = await instance.database;
      return await db.delete(userTable, where: '$columnId = ?', whereArgs: [userID]);
    } catch (e) {
      // Handle the error
      print("Error while deleting user: $e");
      return 0; // or return another value according to your app needs
    }
  }

  // Dynamic operations
  Future<int> insertDynamic(String tableName, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  Future<int> updateDynamic(String tableName, Map<String, dynamic> row, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.update(tableName, row, where: whereClause, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    try {
      Database db = await instance.database;
      return await db.query(tableName);
    } catch (e) {}
    return [];
  }

  Future<void> deleteAllRows(String tableName) async {
    Database db = await instance.database;
    return await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<int> deleteSelectedRow(String tableName, String whereClause, List<dynamic> whereArgs) async {
    try {
      Database db = await instance.database;
      return await db.delete(tableName, where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      // Handle the error
      print("Error while deleting row: $e");
      return 0; // or return another value according to your app needs
    }
  }
}
