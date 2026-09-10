import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart'; // To import Diary model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mydiary.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(diaries)');
      final hasMood = columns.any((column) => column['name'] == 'mood');
      if (!hasMood) {
        await db.execute(
          "ALTER TABLE diaries ADD COLUMN mood TEXT NOT NULL DEFAULT 'เฉยๆ'",
        );
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diaries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        mood TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Diary diary) async {
    Database db = await database;
    return await db.insert('diaries', diary.toMap());
  }

  Future<List<Diary>> getAll() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diaries');
    return List.generate(maps.length, (i) {
      return Diary.fromMap(maps[i]);
    });
  }

  Future<int> update(Diary diary) async {
    Database db = await database;
    return await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }
}
