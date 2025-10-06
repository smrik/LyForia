import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:lyforia/utils/firebase_refs.dart';
import 'package:lyforia/utils/app_constants.dart';
import 'package:lyforia/utils/error_handler.dart';
import 'package:lyforia/widgets/common_widgets.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> with ErrorHandlerMixin {
  final _taskController = TextEditingController();

  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      showError(AppStrings.signInRequired);
      return;
    }
    try {
      await Fb.firestore.collection('tasks').add({
        'text': text,
        'done': false,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': uid,
      });
      _taskController.clear();
    } catch (e) {
      if (!mounted) return;
      showError('Failed to add task: ${ErrorHandler.formatErrorMessage(e)}');
    }
  }

  Future<void> _toggleDone(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>?;
    final done = (data?['done'] as bool?) ?? false;
    try {
      await doc.reference.update({'done': !done});
    } catch (e) {
      if (!mounted) return;
      showError('Failed to update task: ${ErrorHandler.formatErrorMessage(e)}');
    }
  }

  Future<void> _deleteTask(DocumentSnapshot doc) async {
    try {
      await doc.reference.delete();
    } catch (e) {
      if (!mounted) return;
      showError('Failed to delete task: ${ErrorHandler.formatErrorMessage(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => _showTimerDialog(context),
          ),
        ],
      ),
      body: AppPageWrapper(
        child: Column(
          children: [
            _buildTaskInput(),
            SizedBox(height: AppSpacing.xl),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: 'New Task',
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: _addTask,
          child: const Text('Add Task'),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      return const Center(
        child: Text('Sign in to view your tasks.'),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: Fb.firestore
          .collection('tasks')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }
        if (!snapshot.hasData) {
          return const Center(child: AppLoadingIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.task_outlined,
            title: 'No tasks yet',
            subtitle: 'Add your first task above to get started.',
          );
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>?;
            final text = (data?['text'] as String?) ?? '';
            final done = (data?['done'] as bool?) ?? false;
            return Dismissible(
              key: ValueKey(doc.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
              ),
              onDismissed: (_) => _deleteTask(doc),
              child: ListTile(
                leading: Checkbox(
                  value: done,
                  onChanged: (_) => _toggleDone(doc),
                ),
                title: Text(
                  text,
                  style: TextStyle(
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteTask(doc),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TimerDialog(),
    );
  }
}

class TimerDialog extends StatefulWidget {
  const TimerDialog({super.key});

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  final _workTimeController = TextEditingController(text: '25');
  final _breakTimeController = TextEditingController(text: '5');
  Timer? _timer;
  int _timeLeft = 0;
  bool _isRunning = false;
  bool _isWorkTime = true;

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _timeLeft = (_isWorkTime
              ? int.tryParse(_workTimeController.text) ?? 25
              : int.tryParse(_breakTimeController.text) ?? 5) *
          60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isWorkTime = !_isWorkTime;
          FlutterRingtonePlayer().playNotification();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pomodoro Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeSettings(),
          const SizedBox(height: 20),
          _buildTimerCircle(),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _isRunning ? _stopTimer : _startTimer,
          child: Text(_isRunning ? 'Stop' : 'Start'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ],
    );
  }

  Widget _buildTimeSettings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            controller: _workTimeController,
            decoration: const InputDecoration(
              labelText: 'Work (min)',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _breakTimeController,
            decoration: const InputDecoration(
              labelText: 'Break (min)',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCircle() {
    final totalTime = (_isWorkTime
            ? int.tryParse(_workTimeController.text) ?? 25
            : int.tryParse(_breakTimeController.text) ?? 5) *
        60;
    final progress = totalTime > 0 ? _timeLeft / totalTime : 0.0;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            color: Theme.of(context).colorScheme.primary,
          ),
          Center(
            child: Text(
              "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
