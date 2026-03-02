import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/note.dart';
import '../../core/theme/app_theme.dart';

class BlockWidget extends StatelessWidget {
  final Block block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onEnter;
  final VoidCallback onBackspaceAtStart;
  final VoidCallback onToggleTodo;
  final List<dynamic> allNotes;

  const BlockWidget({
    super.key,
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onEnter,
    required this.onBackspaceAtStart,
    required this.onToggleTodo,
    required this.allNotes,
  });

  @override
  Widget build(BuildContext context) {
    if (block.type == BlockType.divider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1, color: Theme.of(context).colorScheme.outline),
      );
    }

    if (block.type == BlockType.code) {
      return _CodeBlock(
        block: block,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
      );
    }

    if (block.type == BlockType.todo) {
      return _TodoBlock(
        block: block,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onEnter: onEnter,
        onBackspaceAtStart: onBackspaceAtStart,
        onToggle: onToggleTodo,
      );
    }

    return _TextBlock(
      block: block,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onEnter: onEnter,
      onBackspaceAtStart: onBackspaceAtStart,
    );
  }
}

class _TextBlock extends StatelessWidget {
  final Block block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onEnter;
  final VoidCallback onBackspaceAtStart;

  const _TextBlock({
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onEnter,
    required this.onBackspaceAtStart,
  });

  TextStyle _style(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (block.type) {
      case BlockType.heading1:
        return TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: cs.onSurface,
        );
      case BlockType.heading2:
        return TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: cs.onSurface,
        );
      case BlockType.heading3:
        return TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: cs.onSurface,
        );
      case BlockType.quote:
        return TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          height: 1.65,
          color: cs.onSurface.withOpacity(0.7),
        );
      case BlockType.bulletList:
      case BlockType.numberedList:
        return TextStyle(fontSize: 15, height: 1.65, color: cs.onSurface);
      default:
        return TextStyle(fontSize: 15, height: 1.65, color: cs.onSurface);
    }
  }

  String? _hintText() {
    switch (block.type) {
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      case BlockType.quote:
        return 'Quote...';
      default:
        return "Type '/' for commands";
    }
  }

  Widget? _prefixWidget(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    switch (block.type) {
      case BlockType.bulletList:
        return Padding(
          padding: const EdgeInsets.only(right: 8, top: 6),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      case BlockType.quote:
        return Container(
          width: 3,
          height: 36,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: block.type == BlockType.heading1 ? 16 : 2,
        bottom: 2,
        left: block.indent * 24.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_prefixWidget(context) != null) _prefixWidget(context)!,
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    onEnter();
                  } else if (event.logicalKey == LogicalKeyboardKey.backspace &&
                      controller.text.isEmpty) {
                    onBackspaceAtStart();
                  }
                }
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: _style(context),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: _hintText(),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoBlock extends StatelessWidget {
  final Block block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onEnter;
  final VoidCallback onBackspaceAtStart;
  final VoidCallback onToggle;

  const _TodoBlock({
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onEnter,
    required this.onBackspaceAtStart,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final checked = block.checked ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: checked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: checked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: checked
                  ? Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    onEnter();
                  } else if (event.logicalKey == LogicalKeyboardKey.backspace &&
                      controller.text.isEmpty)
                    onBackspaceAtStart();
                }
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(checked ? 0.4 : 1.0),
                ),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'To-do',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final Block block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;

  const _CodeBlock({
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: Text(
              block.language ?? 'plain text',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: AppTextStyles.mono.copyWith(color: Colors.white70),
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '// code here...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
