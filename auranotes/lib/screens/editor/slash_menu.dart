import 'package:flutter/material.dart';
import '../../core/models/note.dart';

class SlashMenu extends StatefulWidget {
  final String query;
  final void Function(BlockType) onSelect;
  final VoidCallback onDismiss;

  const SlashMenu({
    super.key,
    required this.query,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  State<SlashMenu> createState() => _SlashMenuState();
}

class _SlashMenuState extends State<SlashMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  int _selectedIndex = 0;

  static const List<_SlashItem> _allItems = [
    _SlashItem(BlockType.heading1, 'Heading 1', Icons.title_rounded, 'H1', [
      'heading1',
      'h1',
      '#',
    ]),
    _SlashItem(BlockType.heading2, 'Heading 2', Icons.title_rounded, 'H2', [
      'heading2',
      'h2',
      '##',
    ]),
    _SlashItem(BlockType.heading3, 'Heading 3', Icons.title_rounded, 'H3', [
      'heading3',
      'h3',
      '###',
    ]),
    _SlashItem(
      BlockType.bulletList,
      'Bullet List',
      Icons.format_list_bulleted_rounded,
      '•',
      ['bullet', 'list', '-', '*'],
    ),
    _SlashItem(
      BlockType.numberedList,
      'Numbered List',
      Icons.format_list_numbered_rounded,
      '1.',
      ['number', 'ordered', '1.'],
    ),
    _SlashItem(
      BlockType.todo,
      'To-do',
      Icons.check_box_outline_blank_rounded,
      '☑',
      ['todo', 'task', 'check', '[]'],
    ),
    _SlashItem(BlockType.code, 'Code Block', Icons.code_rounded, '</>', [
      'code',
      'snippet',
      '```',
    ]),
    _SlashItem(BlockType.quote, 'Quote', Icons.format_quote_rounded, '"', [
      'quote',
      'blockquote',
      '>',
    ]),
    _SlashItem(
      BlockType.divider,
      'Divider',
      Icons.horizontal_rule_rounded,
      '—',
      ['divider', 'rule', '---'],
    ),
  ];

  List<_SlashItem> get _filtered {
    if (widget.query.isEmpty) return _allItems;
    final q = widget.query.toLowerCase();
    return _allItems
        .where(
          (item) =>
              item.label.toLowerCase().contains(q) ||
              item.keywords.any((k) => k.contains(q)),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_anim);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Positioned(
      left: 60,
      bottom: 0,
      top: 0,
      child: Align(
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 260,
                constraints: const BoxConstraints(maxHeight: 360),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                      child: Text(
                        'BLOCKS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Flexible(
                      child: items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No results for "${widget.query}"',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 6),
                              itemCount: items.length,
                              itemBuilder: (ctx, i) => _SlashMenuItem(
                                item: items[i],
                                isSelected: i == _selectedIndex,
                                onTap: () => widget.onSelect(items[i].type),
                                onHover: (v) {
                                  if (v) setState(() => _selectedIndex = i);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlashMenuItem extends StatelessWidget {
  final _SlashItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(bool) onHover;

  const _SlashMenuItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    item.badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlashItem {
  final BlockType type;
  final String label;
  final IconData icon;
  final String badge;
  final List<String> keywords;

  const _SlashItem(this.type, this.label, this.icon, this.badge, this.keywords);
}
