import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/note_provider.dart';
import '../../providers/folder_provider.dart';
import '../../providers/theme_provider.dart';
import 'sidebar_item.dart';

/// The collapsible sidebar navigation panel.
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesAsync = ref.watch(notesListProvider);
    final foldersAsync = ref.watch(foldersListProvider);

    return Container(
      color: isDark ? AppColors.darkSidebar : AppColors.lightSidebar,
      child: Column(
        children: [
          // ── Header ──
          _buildHeader(context, ref, isDark),
          const Divider(),

          // ── Content ──
          Expanded(
            child: notesAsync.when(
              data: (notes) => foldersAsync.when(
                data: (folders) => _buildTree(context, ref, folders, notes, isDark),
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // ── Footer ──
          _buildFooter(context, ref, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AuraNotes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          _iconButton(
            icon: Icons.search_rounded,
            isDark: isDark,
            tooltip: 'Search notes',
            onTap: () => _openSearch(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTree(
    BuildContext context,
    WidgetRef ref,
    List folders,
    List notes,
    bool isDark,
  ) {
    final rootFolders = folders.where((f) => f.parentId == null).toList();
    final rootNotes = notes.where((n) => n.folderId == null).toList();

    if (rootFolders.isEmpty && rootNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to create one',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        ...rootFolders.map((f) => SidebarFolderItem(
              folder: f,
              allFolders: List.from(folders),
              allNotes: List.from(notes),
            )),
        ...rootNotes.map((n) => SidebarNoteItem(note: n)),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // New Note
          Expanded(
            child: _actionButton(
              context: context,
              ref: ref,
              isDark: isDark,
              icon: Icons.add_rounded,
              label: 'New Note',
              onTap: () async {
                final note = await ref.read(noteActionsProvider.notifier).createNote();
                ref.read(currentNoteIdProvider.notifier).state = note.id;
              },
            ),
          ),
          const SizedBox(width: 8),
          // New Folder
          Expanded(
            child: _actionButton(
              context: context,
              ref: ref,
              isDark: isDark,
              icon: Icons.create_new_folder_outlined,
              label: 'Folder',
              onTap: () => _showNewFolderDialog(context, ref),
            ),
          ),
          const SizedBox(width: 8),
          // Theme toggle
          _iconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            isDark: isDark,
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onTap: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isDark ? AppColors.darkIcon : AppColors.lightIcon),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required bool isDark,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
            ),
          ),
        ),
      ),
    );
  }

  void _openSearch(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _SearchDialog(),
    );
  }

  void _showNewFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
          onSubmitted: (value) {
            Navigator.pop(ctx);
            if (value.trim().isNotEmpty) {
              ref.read(folderActionsProvider.notifier).createFolder(name: value.trim());
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                ref.read(folderActionsProvider.notifier).createFolder(name: value);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

/// Quick search dialog (command palette style).
class _SearchDialog extends ConsumerStatefulWidget {
  const _SearchDialog();

  @override
  ConsumerState<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<_SearchDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = ref.watch(noteSearchResultsProvider);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search_rounded, size: 20,
                    color: isDark ? AppColors.darkIcon : AppColors.lightIcon),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              onChanged: (value) {
                ref.read(noteSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Divider(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            height: 1,
          ),
          // Results
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: results.when(
              data: (notes) {
                if (_controller.text.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Type to search...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                    ),
                  );
                }
                if (notes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No results found',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: notes.length,
                  itemBuilder: (ctx, index) {
                    final note = notes[index];
                    return ListTile(
                      leading: Icon(Icons.description_outlined, size: 18,
                          color: isDark ? AppColors.darkIcon : AppColors.lightIcon),
                      title: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      dense: true,
                      onTap: () {
                        ref.read(currentNoteIdProvider.notifier).state = note.id;
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
