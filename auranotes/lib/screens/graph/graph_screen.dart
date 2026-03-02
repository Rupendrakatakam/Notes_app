import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/note.dart';
import '../../core/services/database_service.dart';
import '../../core/providers/providers.dart';
import 'dart:math';

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen>
    with TickerProviderStateMixin {
  List<Note> _notes = [];
  List<NoteLink> _links = [];
  Map<String, Offset> _positions = {};
  String? _hoveredNodeId;
  bool _loading = true;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final notes = await DatabaseService.getAllNotesForGraph();
    final links = await DatabaseService.getAllLinks();
    if (!mounted) return;

    // Place nodes in a circle + some random spread
    final rng = Random(42);
    final center = const Offset(300, 300);
    final radius = 200.0;
    final Map<String, Offset> pos = {};
    for (int i = 0; i < notes.length; i++) {
      final angle = (2 * pi * i) / max(notes.length, 1);
      final r = radius + rng.nextDouble() * 60;
      pos[notes[i].id] = center + Offset(r * cos(angle), r * sin(angle));
    }

    setState(() {
      _notes = notes;
      _links = links;
      _positions = pos;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Graph View', style: TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No notes yet',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            )
          : InteractiveViewer(
              minScale: 0.4,
              maxScale: 3.0,
              child: SizedBox(
                width: 700,
                height: 700,
                child: Stack(
                  children: [
                    // Draw edges
                    CustomPaint(
                      size: const Size(700, 700),
                      painter: _GraphPainter(
                        notes: _notes,
                        links: _links,
                        positions: _positions,
                        hoveredId: _hoveredNodeId,
                        accent: Theme.of(context).colorScheme.primary,
                        dimColor: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),

                    // Draw nodes
                    ..._notes.map((note) {
                      final pos = _positions[note.id];
                      if (pos == null) return const SizedBox();
                      final isHovered = _hoveredNodeId == note.id;
                      final isConnected = _hoveredNodeId == null
                          ? false
                          : _links.any(
                              (l) =>
                                  (l.fromNoteId == _hoveredNodeId &&
                                      l.toNoteId == note.id) ||
                                  (l.toNoteId == _hoveredNodeId &&
                                      l.fromNoteId == note.id),
                            );

                      return Positioned(
                        left: pos.dx - 20,
                        top: pos.dy - 20,
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(activeNoteIdProvider.notifier)
                                .set(note.id);
                            Navigator.pop(context);
                          },
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => _hoveredNodeId = note.id),
                            onExit: (_) =>
                                setState(() => _hoveredNodeId = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: isHovered ? 48 : 40,
                              height: isHovered ? 48 : 40,
                              margin: isHovered
                                  ? const EdgeInsets.all(0)
                                  : const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : isConnected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.3)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary
                                      .withValues(alpha: isHovered ? 1 : 0.5),
                                  width: isHovered ? 2.5 : 1.5,
                                ),
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  note.emoji ?? '📄',
                                  style: TextStyle(
                                    fontSize: isHovered ? 16 : 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Node labels on hover
                    if (_hoveredNodeId != null)
                      ..._notes.where((n) => n.id == _hoveredNodeId).map((
                        note,
                      ) {
                        final pos = _positions[note.id];
                        if (pos == null) return const SizedBox();
                        return Positioned(
                          left: pos.dx - 60,
                          top: pos.dy + 28,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              note.title,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<Note> notes;
  final List<NoteLink> links;
  final Map<String, Offset> positions;
  final String? hoveredId;
  final Color accent;
  final Color dimColor;

  _GraphPainter({
    required this.notes,
    required this.links,
    required this.positions,
    required this.hoveredId,
    required this.accent,
    required this.dimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final link in links) {
      final from = positions[link.fromNoteId];
      final to = positions[link.toNoteId];
      if (from == null || to == null) continue;

      final isHighlighted =
          hoveredId != null &&
          (link.fromNoteId == hoveredId || link.toNoteId == hoveredId);

      final paint = Paint()
        ..color = isHighlighted ? accent.withValues(alpha: 0.7) : dimColor
        ..strokeWidth = isHighlighted ? 1.5 : 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) =>
      oldDelegate.hoveredId != hoveredId;
}
