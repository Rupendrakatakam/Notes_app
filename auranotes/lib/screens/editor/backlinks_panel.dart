import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/note.dart';
import '../../core/services/database_service.dart';
import '../../core/providers/providers.dart';

class BacklinksPanel extends ConsumerWidget {
  final String noteId;
  const BacklinksPanel({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<NoteLink>>(
      future: DatabaseService.getBacklinks(noteId),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox();
        final links = snap.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'LINKED MENTIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${links.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...links.map((link) => _BacklinkItem(link: link)),
          ],
        );
      },
    );
  }
}

class _BacklinkItem extends ConsumerWidget {
  final NoteLink link;
  const _BacklinkItem({required this.link});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Note?>(
      future: DatabaseService.getNote(link.fromNoteId),
      builder: (context, snap) {
        final note = snap.data;
        if (note == null) return const SizedBox();

        return GestureDetector(
          onTap: () => ref.read(activeNoteIdProvider.notifier).set(note.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note.emoji ?? '📄',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (link.context != null && link.context!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    link.context!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
