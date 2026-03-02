import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulletList,
  numberedList,
  todo,
  code,
  image,
  divider,
  quote,
  math,
}

class Block {
  final String id;
  final BlockType type;
  String content;
  bool? checked; // for todo blocks
  String? language; // for code blocks
  String? imageUrl; // for image blocks
  int indent;

  Block({
    String? id,
    required this.type,
    this.content = '',
    this.checked,
    this.language,
    this.imageUrl,
    this.indent = 0,
  }) : id = id ?? _uuid.v4();

  Block copyWith({
    String? id,
    BlockType? type,
    String? content,
    bool? checked,
    String? language,
    String? imageUrl,
    int? indent,
  }) {
    return Block(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      checked: checked ?? this.checked,
      language: language ?? this.language,
      imageUrl: imageUrl ?? this.imageUrl,
      indent: indent ?? this.indent,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'content': content,
    'checked': checked == null ? null : (checked! ? 1 : 0),
    'language': language,
    'imageUrl': imageUrl,
    'indent': indent,
  };

  factory Block.fromMap(Map<String, dynamic> map) => Block(
    id: map['id'],
    type: BlockType.values.firstWhere((e) => e.name == map['type'],
        orElse: () => BlockType.paragraph),
    content: map['content'] ?? '',
    checked: map['checked'] == null ? null : map['checked'] == 1,
    language: map['language'],
    imageUrl: map['imageUrl'],
    indent: map['indent'] ?? 0,
  );
}

class NoteLink {
  final String fromNoteId;
  final String toNoteId;
  final String? context;

  NoteLink({
    required this.fromNoteId,
    required this.toNoteId,
    this.context,
  });

  Map<String, dynamic> toMap() => {
    'fromNoteId': fromNoteId,
    'toNoteId': toNoteId,
    'context': context,
  };

  factory NoteLink.fromMap(Map<String, dynamic> map) => NoteLink(
    fromNoteId: map['fromNoteId'],
    toNoteId: map['toNoteId'],
    context: map['context'],
  );
}

class Note {
  final String id;
  String title;
  List<Block> blocks;
  String? parentId;
  List<String> tags;
  Map<String, String> properties;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPlaceholder;
  String? emoji;

  Note({
    String? id,
    this.title = 'Untitled',
    List<Block>? blocks,
    this.parentId,
    List<String>? tags,
    Map<String, String>? properties,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPlaceholder = false,
    this.emoji,
  })  : id = id ?? _uuid.v4(),
        blocks = blocks ?? [Block(type: BlockType.paragraph)],
        tags = tags ?? [],
        properties = properties ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? id,
    String? title,
    List<Block>? blocks,
    String? parentId,
    bool clearParent = false,
    List<String>? tags,
    Map<String, String>? properties,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPlaceholder,
    String? emoji,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      tags: tags ?? this.tags,
      properties: properties ?? this.properties,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'parentId': parentId,
    'tags': tags.join(','),
    'properties': properties.entries.map((e) => '${e.key}=${e.value}').join('\n'),
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'isPlaceholder': isPlaceholder ? 1 : 0,
    'emoji': emoji,
  };

  factory Note.fromMap(Map<String, dynamic> map, List<Block> blocks) {
    final tagsStr = map['tags'] as String? ?? '';
    final propsStr = map['properties'] as String? ?? '';
    final Map<String, String> props = {};
    if (propsStr.isNotEmpty) {
      for (final line in propsStr.split('\n')) {
        final idx = line.indexOf('=');
        if (idx > 0) props[line.substring(0, idx)] = line.substring(idx + 1);
      }
    }
    return Note(
      id: map['id'],
      title: map['title'] ?? 'Untitled',
      blocks: blocks,
      parentId: map['parentId'],
      tags: tagsStr.isEmpty ? [] : tagsStr.split(','),
      properties: props,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isPlaceholder: map['isPlaceholder'] == 1,
      emoji: map['emoji'],
    );
  }

  String get plainText => blocks.map((b) => b.content).join('\n');
}
