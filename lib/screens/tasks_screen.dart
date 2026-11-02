import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/app_state.dart';
import '../theme/palette.dart';
import '../widgets/glass.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _controller = TextEditingController();
  int _allocatedMinutes = 0;

  static const _allocOptions = {0: 'None', 15: '15m', 30: '30m', 60: '1h', 120: '2h', 240: '4h'};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<AppState>().addTask(
          name: name,
          allocatedMinutes: _allocatedMinutes == 0 ? null : _allocatedMinutes,
        );
    HapticFeedback.mediumImpact();
    _controller.clear();
    setState(() => _allocatedMinutes = 0);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final active = appState.activeTasks;
    final done = appState.tasks.where((t) => t.isCompleted).toList();
    final full = active.length >= 3;

    return GlassScaffold(
      title: 'Tasks',
      subtitle: Text('${active.length} of 3 in focus'),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CaptureField(
                controller: _controller,
                hint: full ? 'Finish one to add another' : 'What needs doing?',
                onSubmit: _addTask,
              ),
              const SizedBox(height: 14),
              Text(
                'Time budget',
                style: AppText.footnote.copyWith(color: p.secondaryLabel, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SegmentedPicker<int>(
                value: _allocatedMinutes,
                options: _allocOptions,
                onChanged: (v) => setState(() => _allocatedMinutes = v),
              ),
              const SizedBox(height: 14),
              GlassButton(
                label: 'Add task',
                icon: CupertinoIcons.plus,
                expand: true,
                onPressed: full ? null : _addTask,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (active.isEmpty)
          const EmptyState(
            icon: CupertinoIcons.checkmark_circle,
            title: 'Nothing in focus',
            message: 'Add up to three tasks. Give each a time budget to see what it costs.',
          )
        else
          GlassGroup(
            header: 'In focus',
            footer: 'Three at a time keeps working memory clear. Finish or remove one to add more.',
            children: [
              for (final t in active) _TaskRow(task: t),
            ],
          ),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 28),
          GlassGroup(
            header: 'Done',
            children: [
              for (final t in done) _TaskRow(task: t),
            ],
          ),
        ],
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final WorkTask task;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.read<AppState>();
    final calc = context.watch<AppState>().lifeCalculator;
    final alloc = task.allocatedMinutes;

    String? cost;
    if (alloc != null && !task.isCompleted) {
      cost = 'Budget ${formatHm(Duration(minutes: alloc))}';
      if (calc != null) {
        final pct = calc.lifeCostPercentage(alloc);
        cost = '$cost · ${pct.toStringAsFixed(pct < 0.01 ? 4 : 2)}% of your life bank';
      }
    }

    return GlassRow(
      leading: Semantics(
        button: true,
        checked: task.isCompleted,
        label: task.isCompleted ? 'Mark as not done' : 'Mark as done',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.mediumImpact();
            appState.toggleTaskComplete(task.id);
          },
          child: SizedBox(
            width: 30,
            height: 44,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  task.isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                  key: ValueKey(task.isCompleted),
                  size: 26,
                  color: task.isCompleted ? p.success : p.tertiaryLabel,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        task.name,
        style: task.isCompleted
            ? TextStyle(color: p.tertiaryLabel, decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: cost == null ? null : Text(cost),
      trailing: _DeleteButton(onPressed: () {
        HapticFeedback.lightImpact();
        appState.deleteTask(task.id);
      }),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Delete',
      icon: Icon(CupertinoIcons.trash, size: 20, color: p.tertiaryLabel),
    );
  }
}
