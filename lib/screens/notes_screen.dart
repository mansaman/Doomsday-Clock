import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/flash_interval_picker.dart';

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
    final appState = context.watch<AppState>();
    final allNotes = [...appState.pinnedNotes, ...appState.notes];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUICK NOTES'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${allNotes.length}',
                style: const TextStyle(
                  color: AppColors.dangerBright,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInputBar(),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: allNotes.isEmpty
                ? const _EmptyNotes()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allNotes.length,
                    itemBuilder: (context, index) {
                      final note = allNotes[index];
                      return _NoteCard(
                        note: note,
                        onDelete: () => appState.deleteNote(note.id),
                        onTogglePin: () => appState.togglePin(note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: "Quick thought or reminder...",
              counterText: '',
            ),
            onSubmitted: (_) => _addNote(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FlashIntervalPicker(
                  value: _selectedFlashInterval,
                  onChanged: (v) => setState(() => _selectedFlashInterval = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add),
                label: const Text('ADD'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onDelete,
    required this.onTogglePin,
  });

  final dynamic note;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final isPinned = note.isPinned;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPinned ? AppColors.danger.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPinned) ...[
                const Icon(Icons.push_pin, color: AppColors.dangerBright, size: 16),
                const SizedBox(width: 6),
              ],
              if (note.flashIntervalMinutes != null) ...[
                Icon(Icons.bolt, color: AppColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(
                  'flash ${note.flashIntervalMinutes}min',
                  style: const TextStyle(color: AppColors.warning, fontSize: 11),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onTogglePin,
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: isPinned ? AppColors.dangerBright : AppColors.textMuted,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note.content,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            'Your brain is full of thoughts.\nDump them here before you forget.\n\nPin a note and set a flash interval\nto keep it on your face.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
