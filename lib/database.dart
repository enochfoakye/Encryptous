import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EncryptousHelper {
  static final EncryptousHelper instance = EncryptousHelper._init();

  static Database? _database;

  EncryptousHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('Encryptous.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY,
        card_number TEXT,
        expiry_date TEXT,
        card_holder_name TEXT,
        cvv_code TEXT
      )
    ''');
  }

  Future<int> insertCard(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('cards', row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    return await db.query('cards');
  }
}
