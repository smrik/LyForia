import 'package:flutter/material.dart';

class TaskSplitterPage extends StatefulWidget {
  const TaskSplitterPage({super.key});

  @override
  State<TaskSplitterPage> createState() => _TaskSplitterPageState();
}

class _TaskSplitterPageState extends State<TaskSplitterPage> {
  final _mainTaskController = TextEditingController();
  final List<Map<String, dynamic>> _subtasks = [];

  void _addStep() {
    setState(() {
      _subtasks.add({'text': '', 'done': false});
    });
  }

  void _saveSteps() {
    // Save logic to be implemented
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Splitter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _mainTaskController,
              decoration: const InputDecoration(
                labelText: 'Main Task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Subtasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._buildSubtaskList(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addStep,
              child: const Text('Add Step'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSteps,
              child: const Text('Save Steps'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSubtaskList() {
    return _subtasks.asMap().entries.map((entry) {
      int index = entry.key;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Checkbox(
              value: entry.value['done'],
              onChanged: (value) {
                setState(() {
                  entry.value['done'] = value!;
                });
              },
            ),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  entry.value['text'] = value;
                },
                decoration: InputDecoration(
                  labelText: 'Subtask ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}