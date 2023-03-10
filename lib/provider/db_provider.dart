import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import '../model/todo_model.dart';

class DBProvider {
  static Database? _database;

  Future<Database?> get database async {
    // If database exists, return database
    if (_database != null) return _database!;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  initDB() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'Todos.db');
    var db = await openDatabase(path, version: 1, onCreate: _createDatabase);
    return db;
  }

  _createDatabase(Database database, int version) async {
    await database.execute(
        "CREATE TABLE mytodos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, completed INTEGER NOT NULL);");
  }

  Future<TodoModel> insertTodo(TodoModel todoModel) async {
    var dbClient = await database;
    await dbClient?.insert('mytodos', todoModel.toMap());
    return todoModel;
  }

  Future<List<TodoModel>> getTodoList() async {
    var dbClient = await database;
    List<Map<String, Object?>> queryResult =
        await dbClient!.rawQuery('SELECT * FROM mytodos');

    return queryResult.map((e) => TodoModel.fromMap(e)).toList();
  }

  Future<int> deleteTodo(int id) async {
    var dbClient = await database;
    return await dbClient!.delete('mytodos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'Todos.db');
    databaseFactory.deleteDatabase(path);
  }

  Future<int> updateTodo(TodoModel todoModel) async {
    var dbClient = await database;
    return await dbClient!.update('mytodos', todoModel.toMap(),
        where: 'id = ?', whereArgs: [todoModel.id]);
  }
}
