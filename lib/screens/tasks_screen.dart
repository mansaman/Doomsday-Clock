import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _controller = TextEditingController();
  int? _allocatedMinutes;

  static const _allocOptions = <(int, String)>[
    (15, '15m'),
    (30, '30m'),
    (60, '1h'),
    (120, '2h'),
    (240, '4h'),
  ];

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
          allocatedMinutes: _allocatedMinutes,
        );
    _controller.clear();
    setState(() => _allocatedMinutes = null);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final active = appState.activeTasks;
    final done = appState.tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TASKS'),
        actions: [
          if (active.length < 3)
            IconButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const _FocusLimitDialog(),
              ),
              icon: const Icon(Icons.info_outline, color: AppColors.textMuted),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${active.length}/3',
                style: const TextStyle(
                  color: AppColors.dangerBright,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (active.isEmpty) const _EmptyTasks(),
                ...active.map((task) => _TaskCard(
                      task: task,
                      onComplete: () => appState.toggleTaskComplete(task.id),
                      onDelete: () => appState.deleteTask(task.id),
                    )),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...done.map((task) => _TaskCard(
                        task: task,
                        onComplete: () => appState.toggleTaskComplete(task.id),
                        onDelete: () => appState.deleteTask(task.id),
                      )),
                ],
              ],
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
            decoration: const InputDecoration(
              hintText: 'What must get done?',
              prefixIcon: Icon(Icons.task_alt, color: AppColors.textMuted, size: 20),
            ),
            onSubmitted: (_) => _addTask(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'LIFE COST:',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              ..._allocOptions.map((option) {
                final selected = _allocatedMinutes == option.$1;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(option.$2),
                    selected: selected,
                    onSelected: (_) => setState(() => _allocatedMinutes = option.$1),
                    selectedColor: AppColors.danger,
                    backgroundColor: AppColors.cardHighlight,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addTask,
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  final dynamic task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final alloc = task.allocatedMinutes;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted ? AppColors.border : AppColors.danger.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: task.isCompleted ? AppColors.success : AppColors.dangerBright,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
              ),
            ],
          ),
          if (alloc != null && !task.isCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.hourglass_bottom, color: AppColors.warning, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _lifeCostText(context, alloc),
                    style: const TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _lifeCostText(BuildContext context, int minutes) {
    final calc = context.watch<AppState>().lifeCalculator;
    String extra = '$minutes min of life';
    if (calc != null) {
      final pct = calc.lifeCostPercentage(minutes);
      extra = '$extra = ${pct.toStringAsFixed(pct < 0.01 ? 3 : 2)}% of your life bank';
    }
    return 'This task drains $extra';
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.checklist, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            'No active tasks.\nAdd a task and assign its life cost.\nKeep it to 3 so you can focus.',
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

class _FocusLimitDialog extends StatelessWidget {
  const _FocusLimitDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('WHY 3 TASKS?'),
      content: const Text(
        'ADHD brains get overwhelmed by too many options.\n\n'
        'Reality check: your working memory holds only 1-3 things at once.\n\n'
        'Only 3 active tasks at a time. Complete or delete one to add another.',
        textAlign: TextAlign.center,
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('GOT IT'),
        ),
      ],
    );
  }
}
