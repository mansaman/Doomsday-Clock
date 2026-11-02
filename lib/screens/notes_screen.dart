import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/app_state.dart';
import '../theme/palette.dart';
import '../widgets/flash_interval_picker.dart';
import '../widgets/glass.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  int? _selectedFlashInterval;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    context.read<AppState>().addNote(
          content: text,
          flashIntervalMinutes: _selectedFlashInterval,
        );
    _controller.clear();
    setState(() => _selectedFlashInterval = null);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final pinned = appState.pinnedNotes;
    final others = appState.notes;

    return GlassScaffold(
      title: 'Notes',
      subtitle: const Text('Get it out of your head'),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CaptureField(
                controller: _controller,
                hint: 'A thought, an idea, a reminder',
                onSubmit: _addNote,
                maxLines: 4,
                maxLength: 300,
              ),
              const SizedBox(height: 14),
              Text(
                'Resurface every',
                style: AppText.footnote.copyWith(color: p.secondaryLabel, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FlashIntervalPicker(
                value: _selectedFlashInterval,
                onChanged: (v) => setState(() => _selectedFlashInterval = v),
              ),
              const SizedBox(height: 14),
              GlassButton(
                label: 'Save note',
                icon: CupertinoIcons.plus,
                expand: true,
                onPressed: _addNote,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (pinned.isEmpty && others.isEmpty)
          const EmptyState(
            icon: CupertinoIcons.lightbulb,
            title: 'No notes yet',
            message: 'Dump thoughts here before they slip away. Pin one with an interval and it pops up on your home screen.',
          ),
        if (pinned.isNotEmpty)
          GlassGroup(
            header: 'Pinned',
            children: [for (final n in pinned) _NoteRow(note: n)],
          ),
        if (pinned.isNotEmpty && others.isNotEmpty) const SizedBox(height: 28),
        if (others.isNotEmpty)
          GlassGroup(
            header: 'All notes',
            children: [for (final n in others) _NoteRow(note: n)],
          ),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note});

  final QuickNote note;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.read<AppState>();
    final interval = note.flashIntervalMinutes;

    return GlassRow(
      title: Text(note.content),
      subtitle: interval == null
          ? null
          : Row(
              children: [
                Icon(CupertinoIcons.bolt_fill, size: 12, color: p.warning),
                const SizedBox(width: 4),
                Text('Every ${interval >= 60 ? '${interval ~/ 60}h' : '${interval}m'}'),
              ],
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: note.isPinned ? 'Unpin' : 'Pin',
            onPressed: () {
              HapticFeedback.selectionClick();
              appState.togglePin(note.id);
            },
            icon: Icon(
              note.isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
              size: 20,
              color: note.isPinned ? p.accent : p.tertiaryLabel,
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () {
              HapticFeedback.lightImpact();
              appState.deleteNote(note.id);
            },
            icon: Icon(CupertinoIcons.trash, size: 20, color: p.tertiaryLabel),
          ),
        ],
      ),
    );
  }
}
