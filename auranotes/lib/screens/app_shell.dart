import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/providers.dart';
import '../core/models/note.dart';

import 'editor/editor_screen.dart';
import 'graph/graph_screen.dart';
import 'widgets/command_palette.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with TickerProviderStateMixin {
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnim;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _sidebarAnim = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    final expanded = ref.read(sidebarExpandedProvider);
    ref.read(sidebarExpandedProvider.notifier).set(!expanded);
    if (expanded) {
      _sidebarController.reverse();
    } else {
      _sidebarController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeNoteId = ref.watch(activeNoteIdProvider);
    final commandVisible = ref.watch(commandPaletteVisibleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                // Left Sidebar
                SizeTransition(
                  sizeFactor: _sidebarAnim,
                  axis: Axis.horizontal,
                  child: _Sidebar(onClose: _toggleSidebar),
                ),

                // Divider
                if (_sidebarAnim.value > 0.01)
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),

                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(onToggleSidebar: _toggleSidebar),
                      Expanded(
                        child: activeNoteId == null
                            ? const _EmptyState()
                            : EditorScreen(noteId: activeNoteId),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Command Palette overlay
            if (commandVisible) const CommandPalette(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final VoidCallback onToggleSidebar;
  const _TopBar({required this.onToggleSidebar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(activeNoteProvider);
    final isDark = ref.watch(themeProvider);

    return Container(
      height: 44,
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _IconBtn(
            icon: Icons.menu_rounded,
            tooltip: 'Toggle sidebar',
            onTap: onToggleSidebar,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: noteAsync.when(
              data: (note) => Text(
                note?.title ?? 'AuraNotes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),
          ),
          _IconBtn(
            icon: Icons.search_rounded,
            tooltip: 'Search (Ctrl+K)',
            onTap: () =>
                ref.read(commandPaletteVisibleProvider.notifier).set(true),
          ),
          _IconBtn(
            icon: Icons.account_tree_outlined,
            tooltip: 'Graph view',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GraphScreen())),
          ),
          _IconBtn(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: 'Toggle theme',
            onTap: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const _Sidebar({required this.onClose});

  @override
  ConsumerState<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<_Sidebar> {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final activeId = ref.watch(activeNoteIdProvider);

    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          // Sidebar header
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AuraNotes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                _NewNoteBtn(),
              ],
            ),
          ),

          const Divider(height: 1),

          // Notes tree
          Expanded(
            child: notesAsync.when(
              data: (notes) => _NoteTree(
                notes: notes,
                activeId: activeId,
                expanded: _expanded,
                onToggle: (id) =>
                    setState(() => _expanded[id] = !(_expanded[id] ?? false)),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          const Divider(height: 1),

          // Bottom actions
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _NewNoteBtn extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'New note',
      child: InkWell(
        onTap: () async {
          final note = await ref.read(notesProvider.notifier).createNote();
          ref.read(activeNoteIdProvider.notifier).set(note.id);
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            Icons.add_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _NoteTree extends ConsumerWidget {
  final List<Note> notes;
  final String? activeId;
  final Map<String, bool> expanded;
  final void Function(String) onToggle;

  const _NoteTree({
    required this.notes,
    required this.activeId,
    required this.expanded,
    required this.onToggle,
  });

  List<Note> _childrenOf(String? parentId) =>
      notes.where((n) => n.parentId == parentId).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roots = _childrenOf(null);
    if (roots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No notes yet.\nTap + to create one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: roots.map((n) => _buildNoteItem(context, ref, n, 0)).toList(),
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    WidgetRef ref,
    Note note,
    int depth,
  ) {
    final children = _childrenOf(note.id);
    final isExpanded = expanded[note.id] ?? false;
    final isActive = note.id == activeId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NoteItem(
          note: note,
          depth: depth,
          isActive: isActive,
          hasChildren: children.isNotEmpty,
          isExpanded: isExpanded,
          onTap: () => ref.read(activeNoteIdProvider.notifier).set(note.id),
          onToggle: () => onToggle(note.id),
          onNewChild: () async {
            final newNote = await ref
                .read(notesProvider.notifier)
                .createNote(parentId: note.id);
            ref.read(activeNoteIdProvider.notifier).set(newNote.id);
          },
          onDelete: () => ref.read(notesProvider.notifier).deleteNote(note.id),
        ),
        if (isExpanded)
          ...children.map((c) => _buildNoteItem(context, ref, c, depth + 1)),
      ],
    );
  }
}

class _NoteItem extends StatefulWidget {
  final Note note;
  final int depth;
  final bool isActive;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onNewChild;
  final VoidCallback onDelete;

  const _NoteItem({
    required this.note,
    required this.depth,
    required this.isActive,
    required this.hasChildren,
    required this.isExpanded,
    required this.onTap,
    required this.onToggle,
    required this.onNewChild,
    required this.onDelete,
  });

  @override
  State<_NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<_NoteItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bg = widget.isActive
        ? Theme.of(context).colorScheme.secondary
        : _hovered
        ? Theme.of(context).highlightColor
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          margin: EdgeInsets.only(
            left: 8.0 + widget.depth * 14.0,
            right: 6,
            top: 1,
            bottom: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Row(
            children: [
              // Expand toggle
              if (widget.hasChildren)
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedRotation(
                    turns: widget.isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.arrow_right_rounded,
                      size: 16,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                )
              else
                const SizedBox(width: 16),

              const SizedBox(width: 4),

              // Emoji / icon
              Text(
                widget.note.emoji ?? '📄',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 6),

              // Title
              Expanded(
                child: Text(
                  widget.note.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isActive
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: widget.isActive
                        ? accent
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Hover actions
              if (_hovered || widget.isActive) ...[
                GestureDetector(
                  onTap: widget.onNewChild,
                  child: Icon(
                    Icons.add_rounded,
                    size: 14,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 14,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 6),
          Text(
            'Local-first • Private',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'AuraNotes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a note or create a new one',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
