import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auranotes.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        parentId TEXT,
        tags TEXT,
        properties TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        isPlaceholder INTEGER DEFAULT 0,
        emoji TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE blocks (
        id TEXT PRIMARY KEY,
        noteId TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT DEFAULT '',
        checked INTEGER,
        language TEXT,
        imageUrl TEXT,
        indent INTEGER DEFAULT 0,
        position INTEGER DEFAULT 0,
        FOREIGN KEY(noteId) REFERENCES notes(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE note_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromNoteId TEXT NOT NULL,
        toNoteId TEXT NOT NULL,
        context TEXT,
        FOREIGN KEY(fromNoteId) REFERENCES notes(id) ON DELETE CASCADE,
        FOREIGN KEY(toNoteId) REFERENCES notes(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Notes ──────────────────────────────────────────────────
  static Future<void> saveNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _saveBlocks(db, note);
    await _saveLinks(db, note);
  }

  static Future<void> _saveBlocks(Database db, Note note) async {
    await db.delete('blocks', where: 'noteId = ?', whereArgs: [note.id]);
    for (int i = 0; i < note.blocks.length; i++) {
      final b = note.blocks[i];
      await db.insert('blocks', {
        ...b.toMap(),
        'noteId': note.id,
        'position': i,
      });
    }
  }

  static Future<void> _saveLinks(Database db, Note note) async {
    await db.delete(
      'note_links',
      where: 'fromNoteId = ?',
      whereArgs: [note.id],
    );
    // Extract [[links]] from content
    final linkRegex = RegExp(r'\[\[([^\]]+)\]\]');
    for (final block in note.blocks) {
      for (final match in linkRegex.allMatches(block.content)) {
        final targetTitle = match.group(1)!;
        final targets = await db.query(
          'notes',
          where: 'title = ?',
          whereArgs: [targetTitle],
        );
        if (targets.isNotEmpty) {
          await db.insert('note_links', {
            'fromNoteId': note.id,
            'toNoteId': targets.first['id'],
            'context': block.content,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
  }

  static Future<Note?> getNote(String id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final blocks = await _getBlocks(db, id);
    return Note.fromMap(maps.first, blocks);
  }

  static Future<List<Block>> _getBlocks(Database db, String noteId) async {
    final maps = await db.query(
      'blocks',
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'position ASC',
    );
    return maps.map((m) => Block.fromMap(m)).toList();
  }

  static Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'updatedAt DESC');
    final List<Note> notes = [];
    for (final map in maps) {
      final blocks = await _getBlocks(db, map['id'] as String);
      notes.add(Note.fromMap(map, blocks));
    }
    return notes;
  }

  static Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    final List<Note> results = [];
    for (final map in maps) {
      final blocks = await _getBlocks(db, map['id'] as String);
      results.add(Note.fromMap(map, blocks));
    }
    return results;
  }

  // ── Links ──────────────────────────────────────────────────
  static Future<List<NoteLink>> getBacklinks(String noteId) async {
    final db = await database;
    final maps = await db.query(
      'note_links',
      where: 'toNoteId = ?',
      whereArgs: [noteId],
    );
    return maps.map((m) => NoteLink.fromMap(m)).toList();
  }

  static Future<List<Note>> getAllNotesForGraph() async {
    return getAllNotes();
  }

  static Future<List<NoteLink>> getAllLinks() async {
    final db = await database;
    final maps = await db.query('note_links');
    return maps.map((m) => NoteLink.fromMap(m)).toList();
  }
}
