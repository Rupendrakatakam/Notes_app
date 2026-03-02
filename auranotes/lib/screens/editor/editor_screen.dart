import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/note.dart';
import '../../core/providers/providers.dart';

import 'block_widget.dart';
import 'slash_menu.dart';
import 'properties_panel.dart';
import 'backlinks_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String noteId;
  const EditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  Note? _note;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool _showSlashMenu = false;
  int _activeBlockIndex = 0;
  bool _showRightPanel = false;
  late TextEditingController _titleController;
  bool _loading = true;
  String _slashQuery = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await ref.read(activeNoteProvider.future);
    if (!mounted) return;
    setState(() {
      _note = note;
      _loading = false;
      if (note != null) {
        _titleController.text = note.title;
        _initControllers(note.blocks);
      }
    });
  }

  void _initControllers(List<Block> blocks) {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
    for (final block in blocks) {
      final c = TextEditingController(text: block.content);
      final f = FocusNode();
      _controllers.add(c);
      _focusNodes.add(f);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteId != widget.noteId) {
      setState(() => _loading = true);
      _loadNote();
    }
  }

  Future<void> _save() async {
    if (_note == null) return;
    final updatedBlocks = List.generate(
      _note!.blocks.length,
      (i) => _note!.blocks[i].copyWith(
        content: i < _controllers.length ? _controllers[i].text : '',
      ),
    );
    final updated = _note!.copyWith(
      title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
      blocks: updatedBlocks,
    );
    _note = updated;
    await ref.read(notesProvider.notifier).saveNote(updated);
  }

  void _onBlockChanged(int index, String value) {
    if (_note == null) return;
    // Check for slash command
    if (value.contains('/') && !_showSlashMenu) {
      final slashIdx = value.lastIndexOf('/');
      _slashQuery = value.substring(slashIdx + 1);
      setState(() {
        _showSlashMenu = true;
        _activeBlockIndex = index;
      });
    } else if (_showSlashMenu) {
      final slashIdx = _controllers[index].text.lastIndexOf('/');
      if (slashIdx >= 0) {
        setState(
          () => _slashQuery = _controllers[index].text.substring(slashIdx + 1),
        );
      } else {
        setState(() => _showSlashMenu = false);
      }
    }
    // Auto-markdown: detect heading prefix
    _applyMarkdownShortcuts(index, value);
  }

  void _applyMarkdownShortcuts(int index, String value) {
    if (_note == null) return;
    BlockType? newType;
    String? newContent;

    if (value == '# ') {
      newType = BlockType.heading1;
      newContent = '';
    } else if (value == '## ') {
      newType = BlockType.heading2;
      newContent = '';
    } else if (value == '### ') {
      newType = BlockType.heading3;
      newContent = '';
    } else if (value == '- ' || value == '* ') {
      newType = BlockType.bulletList;
      newContent = '';
    } else if (value == '1. ') {
      newType = BlockType.numberedList;
      newContent = '';
    } else if (value == '[] ' || value == '[ ] ') {
      newType = BlockType.todo;
      newContent = '';
    } else if (value == '> ') {
      newType = BlockType.quote;
      newContent = '';
    } else if (value == '---') {
      newType = BlockType.divider;
      newContent = '';
    }

    if (newType != null) {
      final blocks = List<Block>.from(_note!.blocks);
      blocks[index] = blocks[index].copyWith(
        type: newType,
        content: newContent ?? '',
      );
      _controllers[index].text = newContent ?? '';
      setState(() => _note = _note!.copyWith(blocks: blocks));
    }
  }

  void _onEnterPressed(int index) {
    if (_showSlashMenu) {
      setState(() => _showSlashMenu = false);
      return;
    }
    final blocks = List<Block>.from(_note!.blocks);
    final newBlock = Block(type: BlockType.paragraph);
    blocks.insert(index + 1, newBlock);
    final c = TextEditingController();
    final f = FocusNode();
    _controllers.insert(index + 1, c);
    _focusNodes.insert(index + 1, f);
    setState(() => _note = _note!.copyWith(blocks: blocks));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index + 1 < _focusNodes.length) {
        _focusNodes[index + 1].requestFocus();
      }
    });
    _save();
  }

  void _onBackspaceAtStart(int index) {
    if (index == 0) return;
    final blocks = List<Block>.from(_note!.blocks);
    // If block is not paragraph, convert to paragraph first
    if (blocks[index].type != BlockType.paragraph) {
      blocks[index] = blocks[index].copyWith(type: BlockType.paragraph);
      setState(() => _note = _note!.copyWith(blocks: blocks));
      return;
    }
    if (blocks.length <= 1) return;
    final prevContent = blocks[index - 1].content;
    final curContent = _controllers[index].text;
    blocks[index - 1] = blocks[index - 1].copyWith(
      content: prevContent + curContent,
    );
    _controllers[index - 1].text = prevContent + curContent;
    _controllers[index - 1].selection = TextSelection.collapsed(
      offset: prevContent.length,
    );
    blocks.removeAt(index);
    _controllers[index].dispose();
    _focusNodes[index].dispose();
    _controllers.removeAt(index);
    _focusNodes.removeAt(index);
    setState(() => _note = _note!.copyWith(blocks: blocks));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index - 1 < _focusNodes.length) {
        _focusNodes[index - 1].requestFocus();
      }
    });
    _save();
  }

  void _insertBlockAt(int index, BlockType type) {
    final blocks = List<Block>.from(_note!.blocks);
    // Replace current slashed block
    blocks[index] = blocks[index].copyWith(type: type, content: '');
    _controllers[index].text = '';
    setState(() {
      _note = _note!.copyWith(blocks: blocks);
      _showSlashMenu = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index < _focusNodes.length) _focusNodes[index].requestFocus();
    });
    _save();
  }

  void _toggleTodo(int index) {
    final blocks = List<Block>.from(_note!.blocks);
    blocks[index] = blocks[index].copyWith(
      checked: !(blocks[index].checked ?? false),
    );
    setState(() => _note = _note!.copyWith(blocks: blocks));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_note == null) {
      return const Center(child: Text('Note not found'));
    }

    return Stack(
      children: [
        Row(
          children: [
            // Main editor
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_showSlashMenu) setState(() => _showSlashMenu = false);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Properties panel (tags, emoji, etc.)
                          PropertiesPanel(
                            note: _note!,
                            onChanged: (updated) {
                              setState(() => _note = updated);
                              _save();
                            },
                          ),
                          const SizedBox(height: 8),

                          // Title
                          TextField(
                            controller: _titleController,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Untitled',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.2),
                              ),
                            ),
                            onChanged: (_) => _save(),
                            maxLines: null,
                          ),
                          const SizedBox(height: 16),

                          // Blocks
                          ...List.generate(_note!.blocks.length, (i) {
                            return BlockWidget(
                              key: ValueKey(_note!.blocks[i].id),
                              block: _note!.blocks[i],
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              onChanged: (v) => _onBlockChanged(i, v),
                              onEnter: () => _onEnterPressed(i),
                              onBackspaceAtStart: () => _onBackspaceAtStart(i),
                              onToggleTodo: () => _toggleTodo(i),
                              allNotes: ref.watch(notesProvider).value ?? [],
                            );
                          }),

                          const SizedBox(height: 32),

                          // Backlinks
                          BacklinksPanel(noteId: _note!.id),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right panel toggle
            if (_showRightPanel)
              _RightPanel(
                note: _note!,
                onClose: () => setState(() => _showRightPanel = false),
              ),
          ],
        ),

        // Slash command menu
        if (_showSlashMenu)
          SlashMenu(
            query: _slashQuery,
            onSelect: (type) => _insertBlockAt(_activeBlockIndex, type),
            onDismiss: () => setState(() => _showSlashMenu = false),
          ),

        // Right panel button
        Positioned(
          right: 12,
          top: 50,
          child: AnimatedOpacity(
            opacity: 0.6,
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              onTap: () => setState(() => _showRightPanel = !_showRightPanel),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  _showRightPanel
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RightPanel extends StatelessWidget {
  final Note note;
  final VoidCallback onClose;

  const _RightPanel({required this.note, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          left: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close_rounded, size: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: BacklinksPanel(noteId: note.id),
            ),
          ),
        ],
      ),
    );
  }
}
