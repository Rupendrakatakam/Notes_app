import 'package:flutter/material.dart';
import '../../core/models/note.dart';

class PropertiesPanel extends StatefulWidget {
  final Note note;
  final void Function(Note) onChanged;

  const PropertiesPanel({
    super.key,
    required this.note,
    required this.onChanged,
  });

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  bool _expanded = false;
  bool _addingTag = false;
  final _tagController = TextEditingController();

  static const _emojis = [
    '📄',
    '📝',
    '💡',
    '📚',
    '🎯',
    '🔥',
    '⭐',
    '🌟',
    '🎨',
    '🛠️',
    '📊',
    '💻',
    '🌿',
    '🎵',
    '🔮',
  ];

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji picker + quick info row
        Row(
          children: [
            GestureDetector(
              onTap: _showEmojiPicker,
              child: Text(
                widget.note.emoji ?? '📄',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.note.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.note.tags
                          .map(
                            (tag) => _TagChip(
                              tag: tag,
                              onRemove: () => _removeTag(tag),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Text(
                    _expanded ? 'Hide' : 'Properties',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Expanded properties
        if (_expanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags section
                _PropertyRow(
                  label: 'Tags',
                  icon: Icons.tag_rounded,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...widget.note.tags.map(
                        (t) => _TagChip(tag: t, onRemove: () => _removeTag(t)),
                      ),
                      if (_addingTag)
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _tagController,
                            autofocus: true,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'tag name',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            onSubmitted: _addTag,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => setState(() => _addingTag = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 12,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Add tag',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Created date
                _PropertyRow(
                  label: 'Created',
                  icon: Icons.calendar_today_rounded,
                  child: Text(
                    _formatDate(widget.note.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Updated date
                _PropertyRow(
                  label: 'Updated',
                  icon: Icons.update_rounded,
                  child: Text(
                    _formatDate(widget.note.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _emojis
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    widget.onChanged(widget.note.copyWith(emoji: e));
                    Navigator.pop(context);
                  },
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.isEmpty) return;
    final tags = List<String>.from(widget.note.tags)..add(tag.trim());
    widget.onChanged(widget.note.copyWith(tags: tags));
    _tagController.clear();
    setState(() => _addingTag = false);
  }

  void _removeTag(String tag) {
    final tags = List<String>.from(widget.note.tags)..remove(tag);
    widget.onChanged(widget.note.copyWith(tags: tags));
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const _TagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _PropertyRow({
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 13,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
