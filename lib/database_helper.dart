import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/diary.dart'; // To import Diary model
import 'api_service.dart'; // To import Pokedek model

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
      version: 3,
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
    if (oldVersion < 3) {
      final columns = await db.rawQuery('PRAGMA table_info(diaries)');
      final hasQuote = columns.any((column) => column['name'] == 'quote');
      if (!hasQuote) {
        await db.execute(
          "ALTER TABLE diaries ADD COLUMN quote TEXT NOT NULL DEFAULT ''",
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
        mood TEXT NOT NULL,
        quote TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE pokedeks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  height TEXT NOT NULL,
  weight TEXT NOT NULL,
  image TEXT NOT NULL,
  type TEXT NOT NULL
        
      )
    ''');
  }

  Future<int> insert(Diary diary) async {
    Database db = await database;
    return await db.insert('diaries', diary.toMap());
  }

  Future<int> insertPokemon(Pokedek pokedek) async {
    Database db = await database;
    return await db.insert('pokedeks', pokedek.toMap());
  }

  Future<List<Diary>> getAll() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diaries');
    return List.generate(maps.length, (i) {
      return Diary.fromMap(maps[i]);
    });
  }

  Future<List<Pokedek>> getAllPokemon() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pokedeks');
    return List.generate(maps.length, (i) {
      return Pokedek.fromMap(maps[i]);
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

  Future<int> updatePokemon(Pokedek pokedek) async {
    Database db = await database;
    return await db.update(
      'pokedeks',
      pokedek.toMap(),
      where: 'id = ?',
      whereArgs: [pokedek.id],
    );
  }

  Future<int> deletePokemon(int id) async {
    Database db = await database;
    return await db.delete('pokedeks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }
}
