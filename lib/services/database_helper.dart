// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, 'coms_chat.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chats (
        chatId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        selectedModel TEXT DEFAULT 'gemini-2.0-flash-exp',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        chatId TEXT NOT NULL,
        role TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        contentJson TEXT NOT NULL,
        isEdited INTEGER DEFAULT 0,
        FOREIGN KEY (chatId) REFERENCES chats (chatId) ON DELETE CASCADE
      )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE chats ADD COLUMN selectedModel TEXT DEFAULT "gemini-2.0-flash-exp"',
      );
      await db.execute(
        'ALTER TABLE chats ADD COLUMN createdAt TEXT DEFAULT "${DateTime.now().toIso8601String()}"',
      );
      await db.execute(
        'ALTER TABLE chats ADD COLUMN updatedAt TEXT DEFAULT "${DateTime.now().toIso8601String()}"',
      );
      await db.execute(
        'ALTER TABLE messages ADD COLUMN isEdited INTEGER DEFAULT 0',
      );
    }
  }
}
