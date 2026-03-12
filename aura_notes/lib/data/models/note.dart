import 'package:uuid/uuid.dart';

/// Represents a note in AuraNotes.
class Note {
  final String id;
  final String title;
  final String content; // JSON string from editor
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  Note({
    String? id,
    this.title = 'Untitled',
    this.content = '',
    this.folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    String? folderId,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'folder_id': folderId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled',
      content: map['content'] as String? ?? '',
      folderId: map['folder_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Note && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
