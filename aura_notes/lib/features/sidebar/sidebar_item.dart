import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_notes/core/theme/app_colors.dart';
import 'package:aura_notes/data/models/note.dart';
import 'package:aura_notes/data/models/folder.dart';
import 'package:aura_notes/providers/note_provider.dart';
import 'package:aura_notes/providers/folder_provider.dart';

/// Sidebar item widget for a note in the navigation tree.
class SidebarNoteItem extends ConsumerWidget {
  final Note note;
  final int depth;

  const SidebarNoteItem({
    super.key,
    required this.note,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentNoteId = ref.watch(currentNoteIdProvider);
    final isSelected = currentNoteId == note.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(currentNoteIdProvider.notifier).state = note.id;
      },
      onLongPress: () => _showContextMenu(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(left: depth * 16.0 + 8, right: 8, top: 1, bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSelected : AppColors.lightSelected)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              note.isPinned ? Icons.push_pin_rounded : Icons.description_outlined,
              size: 16,
              color: isSelected
                  ? AppColors.accent
                  : (isDark ? AppColors.darkIcon : AppColors.lightIcon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                size: 20,
              ),
              title: Text(note.isPinned ? 'Unpin' : 'Pin to top'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(noteActionsProvider.notifier).togglePin(note.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${note.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(noteActionsProvider.notifier).deleteNote(note.id);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Sidebar folder item with expand/collapse and nested children.
class SidebarFolderItem extends ConsumerWidget {
  final Folder folder;
  final List<Folder> allFolders;
  final List<Note> allNotes;
  final int depth;

  const SidebarFolderItem({
    super.key,
    required this.folder,
    required this.allFolders,
    required this.allNotes,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedFolders = ref.watch(expandedFoldersProvider);
    final isExpanded = expandedFolders.contains(folder.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final childFolders = allFolders.where((f) => f.parentId == folder.id).toList();
    final childNotes = allNotes.where((n) => n.folderId == folder.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final expanded = Set<String>.from(expandedFolders);
            if (isExpanded) {
              expanded.remove(folder.id);
            } else {
              expanded.add(folder.id);
            }
            ref.read(expandedFoldersProvider.notifier).state = expanded;
          },
          onLongPress: () => _showContextMenu(context, ref),
          child: Container(
            margin: EdgeInsets.only(left: depth * 16.0 + 8, right: 8, top: 1, bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
                  size: 16,
                  color: AppColors.accent.withAlpha(180),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    folder.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Children
        if (isExpanded) ...[
          ...childFolders.map((cf) => SidebarFolderItem(
                folder: cf,
                allFolders: allFolders,
                allNotes: allNotes,
                depth: depth + 1,
              )),
          ...childNotes.map((cn) => SidebarNoteItem(note: cn, depth: depth + 1)),
        ],
      ],
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined, size: 20),
              title: const Text('New Note Here'),
              onTap: () async {
                Navigator.pop(ctx);
                final note = await ref
                    .read(noteActionsProvider.notifier)
                    .createNote(folderId: folder.id);
                ref.read(currentNoteIdProvider.notifier).state = note.id;
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined, size: 20),
              title: const Text('New Subfolder'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, ref, isNew: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, size: 20),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, ref, isNew: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, {required bool isNew}) {
    final controller = TextEditingController(text: isNew ? '' : folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'New Subfolder' : 'Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: isNew ? 'Folder name' : folder.name),
          onSubmitted: (value) {
            Navigator.pop(ctx);
            if (value.trim().isNotEmpty) {
              if (isNew) {
                ref.read(folderActionsProvider.notifier).createFolder(
                      parentId: folder.id,
                      name: value.trim(),
                    );
              } else {
                ref.read(folderActionsProvider.notifier).renameFolder(folder.id, value.trim());
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                if (isNew) {
                  ref.read(folderActionsProvider.notifier).createFolder(
                        parentId: folder.id,
                        name: value,
                      );
                } else {
                  ref.read(folderActionsProvider.notifier).renameFolder(folder.id, value);
                }
              }
            },
            child: Text(isNew ? 'Create' : 'Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Delete "${folder.name}"? Notes inside will be moved to the root. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(folderActionsProvider.notifier).deleteFolder(folder.id);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
