import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/note.dart';

/// Repository for Note CRUD operations.
class NoteRepository {
  final DatabaseHelper _dbHelper;

  NoteRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  /// Create a new note.
  Future<Note> createNote({String? folderId}) async {
    final note = Note(folderId: folderId);
    final db = await _db;
    await db.insert('notes', note.toMap());
    return note;
  }

  /// Get a note by ID.
  Future<Note?> getNote(String id) async {
    final db = await _db;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Get all notes, ordered by updated_at descending.
  Future<List<Note>> getAllNotes() async {
    final db = await _db;
    final maps = await db.query('notes', orderBy: 'is_pinned DESC, updated_at DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Get notes in a specific folder.
  Future<List<Note>> getNotesByFolder(String? folderId) async {
    final db = await _db;
    final maps = await db.query(
      'notes',
      where: folderId != null ? 'folder_id = ?' : 'folder_id IS NULL',
      whereArgs: folderId != null ? [folderId] : null,
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Update a note.
  Future<void> updateNote(Note note) async {
    final db = await _db;
    final updated = note.copyWith(updatedAt: DateTime.now());
    await db.update('notes', updated.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  /// Delete a note.
  Future<void> deleteNote(String id) async {
    final db = await _db;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Search notes by title or content.
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) return [];
    final db = await _db;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Move a note to a different folder.
  Future<void> moveNote(String noteId, String? newFolderId) async {
    final db = await _db;
    await db.update(
      'notes',
      {'folder_id': newFolderId, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  /// Toggle pin status.
  Future<void> togglePin(String noteId) async {
    final db = await _db;
    final note = await getNote(noteId);
    if (note == null) return;
    await db.update(
      'notes',
      {'is_pinned': note.isPinned ? 0 : 1},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}
