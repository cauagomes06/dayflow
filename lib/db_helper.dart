import 'dart:io'; 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; 
import 'routine_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // ATUALIZADO: V7 para criar a nova tabela de conclusões limpa
    _database = await _initDB('dayflow_v7.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;

    if (Platform.isWindows || Platform.isLinux) {
      final documentsDirectory = await getApplicationSupportDirectory();
      path = join(documentsDirectory.path, filePath);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }
    
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabela de Rotinas
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

    // 2. Tabela de Exceções
    await db.execute('''
    CREATE TABLE routine_exceptions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      routine_id INTEGER NOT NULL,
      date TEXT NOT NULL
    )
    ''');

    // 3. NOVA TABELA: Conclusões (Check-ins)
    await db.execute('''
    CREATE TABLE routine_completions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      routine_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      completed_at TEXT NOT NULL
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

  // --- GERENCIAMENTO DE EXCEÇÕES ---
  Future<int> addException(int routineId, DateTime date) async {
    final db = await instance.database;
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

  // --- NOVAS FUNÇÕES: CHECK-IN / CONCLUSÃO ---

  // Marcar atividade como feita
  Future<int> completeRoutine(int routineId, DateTime date) async {
    final db = await instance.database;
    String dateString = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
    
    return await db.insert('routine_completions', {
      'routine_id': routineId,
      'date': dateString,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  // Desmarcar atividade (remover o check)
  Future<int> uncompleteRoutine(int routineId, DateTime date) async {
    final db = await instance.database;
    String dateString = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
    
    return await db.delete(
      'routine_completions',
      where: 'routine_id = ? AND date = ?',
      whereArgs: [routineId, dateString],
    );
  }

  // Buscar todas as conclusões (para saber o que pintar de verde)
  Future<List<Map<String, dynamic>>> getCompletions() async {
    final db = await instance.database;
    return await db.query('routine_completions');
  }
}