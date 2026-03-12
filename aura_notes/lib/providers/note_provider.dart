import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';

/// Provides the NoteRepository instance.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

/// Provides all notes, refreshable.
final notesListProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.read(noteRepositoryProvider);
  return repo.getAllNotes();
});

/// Provides the currently selected note ID.
final currentNoteIdProvider = StateProvider<String?>((ref) => null);

/// Provides the currently selected note.
final currentNoteProvider = FutureProvider<Note?>((ref) async {
  final noteId = ref.watch(currentNoteIdProvider);
  if (noteId == null) return null;
  final repo = ref.read(noteRepositoryProvider);
  return repo.getNote(noteId);
});

/// Search query state.
final noteSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provides search results.
final noteSearchResultsProvider = FutureProvider<List<Note>>((ref) async {
  final query = ref.watch(noteSearchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.read(noteRepositoryProvider);
  return repo.searchNotes(query);
});

/// Notifier for note operations (create, update, delete).
class NoteActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final NoteRepository _repo;
  final Ref _ref;

  NoteActionsNotifier(this._repo, this._ref) : super(const AsyncData(null));

  Future<Note> createNote({String? folderId}) async {
    final note = await _repo.createNote(folderId: folderId);
    _ref.invalidate(notesListProvider);
    return note;
  }

  Future<void> updateNote(Note note) async {
    await _repo.updateNote(note);
    _ref.invalidate(notesListProvider);
    _ref.invalidate(currentNoteProvider);
  }

  Future<void> deleteNote(String id) async {
    await _repo.deleteNote(id);
    // If the deleted note was selected, deselect
    if (_ref.read(currentNoteIdProvider) == id) {
      _ref.read(currentNoteIdProvider.notifier).state = null;
    }
    _ref.invalidate(notesListProvider);
  }

  Future<void> togglePin(String id) async {
    await _repo.togglePin(id);
    _ref.invalidate(notesListProvider);
    _ref.invalidate(currentNoteProvider);
  }

  Future<void> moveNote(String noteId, String? folderId) async {
    await _repo.moveNote(noteId, folderId);
    _ref.invalidate(notesListProvider);
  }
}

final noteActionsProvider =
    StateNotifierProvider<NoteActionsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.read(noteRepositoryProvider);
  return NoteActionsNotifier(repo, ref);
});
