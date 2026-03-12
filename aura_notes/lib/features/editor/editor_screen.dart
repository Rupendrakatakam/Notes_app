import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/note.dart';
import '../../providers/note_provider.dart';

/// The main editor screen using AppFlowy Editor.
class EditorScreen extends ConsumerStatefulWidget {
  final Note note;

  const EditorScreen({super.key, required this.note});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late EditorState _editorState;
  late TextEditingController _titleController;
  Timer? _autoSaveTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title == 'Untitled' ? '' : widget.note.title);
    _initEditor();
  }

  void _initEditor() {
    Document document;
    if (widget.note.content.isNotEmpty) {
      try {
        final json = jsonDecode(widget.note.content);
        document = Document.fromJson(json as Map<String, dynamic>);
      } catch (_) {
        document = Document.blank();
      }
    } else {
      document = Document.blank();
    }

    _editorState = EditorState(document: document);

    // Listen for changes to trigger auto-save
    _editorState.transactionStream.listen((_) {
      _scheduleAutoSave();
    });
  }

  @override
  void didUpdateWidget(EditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _autoSaveTimer?.cancel();
      // Save the old note first
      _saveNote(oldWidget.note);
      // Reinitialize for new note
      _titleController.text = widget.note.title == 'Untitled' ? '' : widget.note.title;
      _initEditor();
      setState(() {});
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(
      const Duration(milliseconds: AppConstants.autoSaveDelayMs),
      () {
        if (!_isDisposed) {
          _saveNote(widget.note);
        }
      },
    );
  }

  Future<void> _saveNote(Note note) async {
    final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim();
    final content = jsonEncode(_editorState.document.toJson());
    final updated = note.copyWith(title: title, content: content);
    await ref.read(noteActionsProvider.notifier).updateNote(updated);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSaveTimer?.cancel();
    _saveNote(widget.note);
    _titleController.dispose();
    _editorState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Title Field ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: TextField(
            controller: _titleController,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            decoration: InputDecoration(
              hintText: 'Untitled',
              hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => _scheduleAutoSave(),
          ),
        ),

        // ── Metadata line ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 12,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(widget.note.updatedAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
              ),
            ],
          ),
        ),

        // ── Editor ──
        Expanded(
          child: _buildEditor(isDark),
        ),
      ],
    );
  }

  Widget _buildEditor(bool isDark) {
    // Build toolbar items for mobile
    final toolbarItems = [
      textDecorationMobileToolbarItem,
      headingMobileToolbarItem,
      listMobileToolbarItem,
      linkMobileToolbarItem,
      quoteMobileToolbarItem,
      todoListMobileToolbarItem,
      codeMobileToolbarItem,
      dividerMobileToolbarItem,
      buildTextAndBackgroundColorMobileToolbarItem(),
    ];

    return Column(
      children: [
        // Floating toolbar for mobile
        MobileToolbar(
          editorState: _editorState,
          toolbarItems: toolbarItems,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          tabbarSelectedBackgroundColor: AppColors.accent,
          tabbarSelectedForegroundColor: Colors.white,
        ),
        Expanded(
          child: AppFlowyEditor(
            editorState: _editorState,
            editorStyle: _buildEditorStyle(isDark),
            header: const SizedBox(height: 0),
            footer: const SizedBox(height: 100),
          ),
        ),
      ],
    );
  }

  EditorStyle _buildEditorStyle(bool isDark) {
    return EditorStyle.mobile(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      cursorColor: AppColors.accent,
      selectionColor: AppColors.accentSubtle,
      defaultTextDirection: 'ltr',
      textStyleConfiguration: TextStyleConfiguration(
        text: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontFamily: 'Inter',
        ),
        bold: const TextStyle(fontWeight: FontWeight.w600),
        italic: const TextStyle(fontStyle: FontStyle.italic),
        underline: const TextStyle(decoration: TextDecoration.underline),
        strikethrough: const TextStyle(decoration: TextDecoration.lineThrough),
        href: TextStyle(
          color: AppColors.accent,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accent.withAlpha(100),
        ),
        code: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          color: isDark ? AppColors.accentLight : AppColors.accentDark,
          backgroundColor: isDark ? AppColors.codeBackgroundDark : AppColors.codeBackgroundLight,
        ),
      ),
      textSpanDecorator: null,
      mobileDragHandleBallSize: const Size(12, 12),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
