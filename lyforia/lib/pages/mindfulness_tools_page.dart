import 'package:flutter/material.dart';

class MindfulnessToolsPage extends StatelessWidget {
  const MindfulnessToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness Tools'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Breathing Exercises'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Anxiety Grounding Tool'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Daily Mindfulness Prompts'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}