import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants.dart';

/// SQLite database helper for AuraNotes.
/// Manages the local database lifecycle and provides raw access.
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Folders table
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT 'New Folder',
        parent_id TEXT,
        created_at TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        FOREIGN KEY (parent_id) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL DEFAULT 'Untitled',
        content TEXT DEFAULT '',
        folder_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_pinned INTEGER DEFAULT 0,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

    // Index for quick lookups
    await db.execute('CREATE INDEX idx_notes_folder ON notes(folder_id)');
    await db.execute('CREATE INDEX idx_notes_updated ON notes(updated_at DESC)');
    await db.execute('CREATE INDEX idx_folders_parent ON folders(parent_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
