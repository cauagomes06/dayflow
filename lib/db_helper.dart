import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'routine_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // ALTEREI PARA V5 PARA FORÇAR A CRIAÇÃO DO BANCO CORRETO
    _database = await _initDB('dayflow_v5.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabela de Rotinas (Com os nomes NOVOS: activity_name, activity_category)
    await db.execute('''
    CREATE TABLE routines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      activity_name TEXT NOT NULL,
      activity_category TEXT NOT NULL,
      days TEXT NOT NULL,
      time TEXT NOT NULL,
      duration TEXT NOT NULL,
      notes TEXT
    )
    ''');

    // 2. Tabela de Exceções (Para apagar dias específicos)
    await db.execute('''
    CREATE TABLE routine_exceptions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      routine_id INTEGER NOT NULL,
      date TEXT NOT NULL
    )
    ''');
  }

  // --- CRUD ROTINAS ---
  Future<int> create(Routine routine) async {
    final db = await instance.database;
    return await db.insert('routines', routine.toMap());
  }

  Future<List<Routine>> readAllRoutines() async {
    final db = await instance.database;
    final result = await db.query('routines', orderBy: 'time ASC');
    return result.map((json) => Routine.fromMap(json)).toList();
  }

  Future<int> update(Routine routine) async {
    final db = await instance.database;
    return await db.update(
      'routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD EXCEÇÕES ---
  Future<int> addException(int routineId, DateTime date) async {
    final db = await instance.database;
    // Formata a data para YYYY-MM-DD
    String dateString = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
    
    return await db.insert('routine_exceptions', {
      'routine_id': routineId,
      'date': dateString,
    });
  }

  Future<List<Map<String, dynamic>>> getExceptions() async {
    final db = await instance.database;
    return await db.query('routine_exceptions');
  }
}