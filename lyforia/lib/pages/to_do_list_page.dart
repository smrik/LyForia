import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final _taskController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({'text': _taskController.text, 'done': false});
        _taskController.clear();
      });
    }
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTaskInput(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildTaskList(),
            ),
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
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _addTask,
          child: const Text('Add Task'),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          leading: Checkbox(
            value: task['done'],
            onChanged: (value) => _toggleDone(index),
          ),
          title: Text(
            task['text'],
            style: TextStyle(
              decoration: task['done'] ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTask(index),
          ),
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
            backgroundColor: Colors.grey[300],
          ),
          Center(
            child: Text(
              '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}