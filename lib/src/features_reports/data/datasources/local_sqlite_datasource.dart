import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // 🛠️ IMPORTACIÓN CLAVE: Para usar kIsWeb

class LocalSqliteDataSource {
  Database? _database;

  Future<Database?> get database async {
    // 🛠️ Si estamos en la Web, evitamos inicializar la base de datos nativa por completo
    if (kIsWeb) return null;

    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'asistente_vial.db');

    return await openDatabase(
      pathString,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE traffic_reports (
            id TEXT PRIMARY KEY,
            titulo TEXT,
            resumen_ia TEXT,
            nivel_gravedad TEXT
          )
        ''');
      },
    );
  }

  Future<void> cacheReport(Map<String, dynamic> cleanJson) async {
    // 🛠️ Validamos si la base de datos es nula (como en Web) para que no tire error
    final db = await database;
    if (db == null) {
      print("⚠️ Almacenamiento local SQLite omitido: Entorno Web detectado.");
      return;
    }

    await db.insert('traffic_reports', {
      'id': cleanJson['id']?.toString(),
      'titulo': cleanJson['titulo'],
      'resumen_ia': cleanJson['resumen_ia'],
      'nivel_gravedad': cleanJson['nivel_gravedad'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCachedReports() async {
    // 🛠️ Validamos si la base de datos es nula (como en Web) y retornamos una lista vacía de forma segura
    final db = await database;
    if (db == null) {
      print("⚠️ Lectura local SQLite omitida: Entorno Web detectado.");
      return [];
    }

    return await db.query('traffic_reports');
  }
}
