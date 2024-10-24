import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //PRUEBAS:
  // Método para debuggear la base de datos
  Future<void> debugDatabase() async {
    final db = await database;

    // Obtener todas las tablas
    final tables = await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

    developer.log('Tablas en la base de datos:');
    for (var table in tables) {
      developer.log('Tabla: ${table['name']}');

      if (table['name'] != 'android_metadata' &&
          table['name'] != 'sqlite_sequence') {
        final rows = await db.query(table['name'].toString());
        developer.log('Número de registros: ${rows.length}');

        for (var row in rows) {
          developer.log('Registro: $row');
        }
      }
    }
  }

  // Método para obtener la ruta de la base de datos
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    developer.log('Ruta de la base de datos: $path');
    return path;
  }
}
