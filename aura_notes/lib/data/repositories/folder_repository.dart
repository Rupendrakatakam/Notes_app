import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/folder.dart';

/// Repository for Folder CRUD operations.
class FolderRepository {
  final DatabaseHelper _dbHelper;

  FolderRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  /// Create a new folder.
  Future<Folder> createFolder({String? parentId, String name = 'New Folder'}) async {
    final folder = Folder(parentId: parentId, name: name);
    final db = await _db;
    await db.insert('folders', folder.toMap());
    return folder;
  }

  /// Get a folder by ID.
  Future<Folder?> getFolder(String id) async {
    final db = await _db;
    final maps = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Folder.fromMap(maps.first);
  }

  /// Get all root-level folders (no parent).
  Future<List<Folder>> getRootFolders() async {
    final db = await _db;
    final maps = await db.query(
      'folders',
      where: 'parent_id IS NULL',
      orderBy: 'sort_order ASC, name ASC',
    );
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  /// Get child folders of a parent.
  Future<List<Folder>> getChildFolders(String parentId) async {
    final db = await _db;
    final maps = await db.query(
      'folders',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'sort_order ASC, name ASC',
    );
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  /// Get all folders.
  Future<List<Folder>> getAllFolders() async {
    final db = await _db;
    final maps = await db.query('folders', orderBy: 'sort_order ASC, name ASC');
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  /// Update a folder.
  Future<void> updateFolder(Folder folder) async {
    final db = await _db;
    await db.update('folders', folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }

  /// Rename a folder.
  Future<void> renameFolder(String id, String newName) async {
    final db = await _db;
    await db.update('folders', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete a folder and optionally its contents.
  /// Notes in the folder will have their folder_id set to null (orphaned to root).
  Future<void> deleteFolder(String id) async {
    final db = await _db;
    // Move child folders to parent of deleted folder
    final folder = await getFolder(id);
    if (folder != null) {
      await db.update(
        'folders',
        {'parent_id': folder.parentId},
        where: 'parent_id = ?',
        whereArgs: [id],
      );
    }
    // Orphan notes to root
    await db.update(
      'notes',
      {'folder_id': null},
      where: 'folder_id = ?',
      whereArgs: [id],
    );
    // Delete the folder
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
}
