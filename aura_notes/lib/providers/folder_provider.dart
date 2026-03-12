import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/folder.dart';
import '../data/repositories/folder_repository.dart';

/// Provides the FolderRepository instance.
final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository();
});

/// Provides all folders, refreshable.
final foldersListProvider = FutureProvider<List<Folder>>((ref) async {
  final repo = ref.read(folderRepositoryProvider);
  return repo.getAllFolders();
});

/// Track which folders are expanded in the sidebar.
final expandedFoldersProvider = StateProvider<Set<String>>((ref) => {});

/// Notifier for folder operations.
class FolderActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final FolderRepository _repo;
  final Ref _ref;

  FolderActionsNotifier(this._repo, this._ref) : super(const AsyncData(null));

  Future<Folder> createFolder({String? parentId, String name = 'New Folder'}) async {
    final folder = await _repo.createFolder(parentId: parentId, name: name);
    _ref.invalidate(foldersListProvider);
    // Auto-expand parent
    if (parentId != null) {
      final expanded = Set<String>.from(_ref.read(expandedFoldersProvider));
      expanded.add(parentId);
      _ref.read(expandedFoldersProvider.notifier).state = expanded;
    }
    return folder;
  }

  Future<void> renameFolder(String id, String newName) async {
    await _repo.renameFolder(id, newName);
    _ref.invalidate(foldersListProvider);
  }

  Future<void> deleteFolder(String id) async {
    await _repo.deleteFolder(id);
    _ref.invalidate(foldersListProvider);
  }
}

final folderActionsProvider =
    StateNotifierProvider<FolderActionsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.read(folderRepositoryProvider);
  return FolderActionsNotifier(repo, ref);
});
