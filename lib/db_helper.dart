import 'dart:io'; // <--- IMPORTANTE: Para saber se é Windows ou Android
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // <--- IMPORTANTE: A nova biblioteca
import 'routine_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // V6 para garantir que cria um arquivo limpo e novo no lugar certo
    _database = await _initDB('dayflow_v6.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;

    // --- A MÁGICA ACONTECE AQUI ---
    if (Platform.isWindows || Platform.isLinux) {
      // Se for Computador: Salva na pasta de documentos/suporte do usuário (PERSISTENTE)
      final documentsDirectory = await getApplicationSupportDirectory();
      path = join(documentsDirectory.path, filePath);
    } else {
      // Se for Celular (Android/iOS): Usa o padrão que já funciona
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
  }

  // --- CRUD (Mantido igual) ---
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
}