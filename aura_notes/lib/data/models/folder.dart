import 'package:uuid/uuid.dart';

/// Represents a folder/page in the sidebar hierarchy.
class Folder {
  final String id;
  final String name;
  final String? parentId; // null = root level
  final DateTime createdAt;
  final int sortOrder;

  Folder({
    String? id,
    this.name = 'New Folder',
    this.parentId,
    DateTime? createdAt,
    this.sortOrder = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Folder copyWith({
    String? name,
    String? parentId,
    int? sortOrder,
  }) {
    return Folder(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'New Folder',
      parentId: map['parent_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Folder && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
