
import 'package:flutter/material.dart';
import 'package:lyforia/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:lyforia/pages/account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Crisis Support'),
            subtitle: const Text('If you are in immediate danger, call local emergency services.'),
            leading: const Icon(Icons.support_agent),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Crisis Resources'),
                  content: const Text(
                    'If you are experiencing a crisis or thinking about harming yourself, please seek immediate help.\n\n'
                    '• US: Call or text 988 (Suicide & Crisis Lifeline)\n'
                    '• UK & ROI: Samaritans 116 123\n'
                    '• AU: Lifeline 13 11 14\n\n'
                    'If outside these regions, please contact your local emergency number.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Account'),
            leading: const Icon(Icons.account_circle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                title: const Text('Dark Mode'),
                leading: const Icon(Icons.color_lens),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Data Export/Import'),
            leading: const Icon(Icons.storage),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
