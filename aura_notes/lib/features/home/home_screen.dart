import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/note_provider.dart';
import '../sidebar/sidebar.dart';
import '../editor/editor_screen.dart';

/// Provider for sidebar visibility.
final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

/// Main home screen: sidebar + editor canvas.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return _buildMobileLayout(context, ref, isDark);
    }
    return _buildTabletLayout(context, ref, isDark);
  }

  /// Mobile: sidebar as a drawer, editor full screen.
  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, bool isDark) {
    final currentNoteAsync = ref.watch(currentNoteProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: SizedBox(
        width: AppConstants.sidebarWidth,
        child: Drawer(
          backgroundColor: isDark ? AppColors.darkSidebar : AppColors.lightSidebar,
          shape: const RoundedRectangleBorder(),
          child: SafeArea(
            child: GestureDetector(
              onTap: () {},
              child: const Sidebar(),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              size: 22,
              color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: currentNoteAsync.when(
          data: (note) => note != null
              ? Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: Theme.of(context).textTheme.titleSmall,
                )
              : const SizedBox(),
          loading: () => const SizedBox(),
          error: (_, _) => const SizedBox(),
        ),
        actions: [
          if (currentNoteAsync.value != null)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
              ),
              onSelected: (value) => _handleMenuAction(value, ref),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'pin', child: Text('Pin / Unpin')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
        ],
      ),
      body: _buildEditorArea(context, ref, isDark),
    );
  }

  /// Tablet/Desktop: side-by-side layout.
  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, bool isDark) {
    final showSidebar = ref.watch(sidebarVisibleProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: AppConstants.sidebarAnimationMs),
              curve: Curves.easeInOut,
              width: showSidebar ? AppConstants.sidebarWidth : 0,
              child: showSidebar
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: const Sidebar(),
                    )
                  : null,
            ),
            // Editor
            Expanded(
              child: Column(
                children: [
                  // Mini toolbar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            showSidebar ? Icons.menu_open_rounded : Icons.menu_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                          ),
                          onPressed: () {
                            ref.read(sidebarVisibleProvider.notifier).state = !showSidebar;
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildEditorArea(context, ref, isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorArea(BuildContext context, WidgetRef ref, bool isDark) {
    final currentNoteAsync = ref.watch(currentNoteProvider);

    return currentNoteAsync.when(
      data: (note) {
        if (note == null) {
          return _buildEmptyState(context, ref, isDark);
        }
        return EditorScreen(key: ValueKey(note.id), note: note);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withAlpha(50),
                  AppColors.accentLight.withAlpha(30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: 36,
              color: AppColors.accent.withAlpha(180),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a note or create a new one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () async {
              final note = await ref.read(noteActionsProvider.notifier).createNote();
              ref.read(currentNoteIdProvider.notifier).state = note.id;
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Note'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.accent.withAlpha(80)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, WidgetRef ref) {
    final noteId = ref.read(currentNoteIdProvider);
    if (noteId == null) return;

    switch (action) {
      case 'pin':
        ref.read(noteActionsProvider.notifier).togglePin(noteId);
        break;
      case 'delete':
        ref.read(noteActionsProvider.notifier).deleteNote(noteId);
        break;
    }
  }
}
