import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../services/database_service.dart';

// ── Theme Provider ─────────────────────────────────────────────
class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true; // dark mode default
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('darkMode') ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', state);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  () => ThemeNotifier(),
);

// ── Notes Provider ─────────────────────────────────────────────
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => DatabaseService.getAllNotes();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => DatabaseService.getAllNotes());
  }

  Future<Note> createNote({String? parentId, String? title}) async {
    final note = Note(
      title: title ?? 'Untitled',
      parentId: parentId,
      blocks: [Block(type: BlockType.paragraph)],
    );
    await DatabaseService.saveNote(note);
    await refresh();
    return note;
  }

  Future<void> saveNote(Note note) async {
    await DatabaseService.saveNote(note.copyWith());
    await refresh();
  }

  Future<void> deleteNote(String id) async {
    await DatabaseService.deleteNote(id);
    await refresh();
  }

  Future<void> renameNote(String id, String newTitle) async {
    final note = await DatabaseService.getNote(id);
    if (note != null) {
      await DatabaseService.saveNote(note.copyWith(title: newTitle));
      await refresh();
    }
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  () => NotesNotifier(),
);

// ── Active Note Provider ────────────────────────────────────────
class ActiveNoteIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final activeNoteIdProvider = NotifierProvider<ActiveNoteIdNotifier, String?>(
  () => ActiveNoteIdNotifier(),
);

final activeNoteProvider = FutureProvider<Note?>((ref) async {
  final id = ref.watch(activeNoteIdProvider);
  if (id == null) return null;
  return DatabaseService.getNote(id);
});

// ── Search Provider ─────────────────────────────────────────────
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

final searchResultsProvider = FutureProvider<List<Note>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return DatabaseService.searchNotes(query);
});

// ── Sidebar Providers ───────────────────────────────────────────
class BoolNotifier extends Notifier<bool> {
  final bool _initial;
  BoolNotifier(this._initial);
  @override
  bool build() => _initial;
  void set(bool v) => state = v;
  void toggle() => state = !state;
}

final sidebarExpandedProvider = NotifierProvider<BoolNotifier, bool>(
  () => BoolNotifier(true),
);

final commandPaletteVisibleProvider = NotifierProvider<BoolNotifier, bool>(
  () => BoolNotifier(false),
);
