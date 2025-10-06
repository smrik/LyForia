import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyforia/utils/firebase_refs.dart';
import 'package:lyforia/utils/app_constants.dart';
import 'package:lyforia/utils/error_handler.dart';
import 'package:lyforia/widgets/common_widgets.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> with ErrorHandlerMixin {
  double _moodValue = 3.0;
  final _notesController = TextEditingController();
  final _diaryController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    _diaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonChild = _saving
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
            ),
          )
        : const Text('Save Check-in');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
      ),
      body: AppPageWrapper(
        child: ListView(
          children: [
            Text('How are you feeling today?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildMoodSlider(),
            const SizedBox(height: 16),
            Text('Quick notes (optional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildNotesField(),
            const SizedBox(height: 16),
            Text('Diary (optional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDiaryField(),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _saving ? null : _saveCheckIn,
              icon: const Icon(Icons.save),
              label: buttonChild,
            ),
            SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: 8),
            Text('Recent check-ins',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildRecentList(),
            SizedBox(height: AppSpacing.xl),
            Text('Mood Trend (Last 7 Days)',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm),
            // TODO(human): Implement _buildMoodChart() method here
            Container(
              height: 100,
              child: Text('Chart will go here'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider() {
    return Column(
      children: [
        Slider(
          value: _moodValue,
          min: 1,
          max: 5,
          divisions: 4,
          label: _moodValue.round().toString(),
          onChanged: (value) {
            setState(() => _moodValue = value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('😔'),
            Text('😕'),
            Text('😐'),
            Text('🙂'),
            Text('😄')
          ],
        )
      ],
    );
  }

  Widget _buildNotesField() {
    return TextField(
      key: const Key('notesField'),
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Optional notes',
      ),
      maxLines: 3,
    );
  }

  Widget _buildDiaryField() {
    return TextField(
      key: const Key('diaryField'),
      controller: _diaryController,
      decoration: const InputDecoration(
        labelText: 'What happened? (optional)',
        alignLabelWithHint: true,
      ),
      maxLines: 6,
    );
  }

  Future<void> _saveCheckIn() async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      showError(AppStrings.signInRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      await Fb.firestore.collection('check_ins').add({
        'uid': uid,
        'mood': _moodValue.round(),
        'notes': _notesController.text.trim(),
        'diaryText': _diaryController.text.trim(),
        'dateTime': FieldValue.serverTimestamp(),
        'day': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      });
      if (!mounted) return;
      _notesController.clear();
      _diaryController.clear();
      showSuccess('Check-in saved successfully');
    } catch (e) {
      if (!mounted) return;
      showError(ErrorHandler.formatErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildRecentList() {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      return const Text('Sign in to view your recent check-ins.');
    }
    return StreamBuilder<QuerySnapshot>(
      stream: Fb.firestore
          .collection('check_ins')
          .where('uid', isEqualTo: uid)
          .orderBy('dateTime', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading check-ins');
        }
        if (!snapshot.hasData) {
          return const Center(child: AppLoadingIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.favorite_outline,
            title: 'No check-ins yet',
            subtitle: 'Start tracking your daily mood and thoughts.',
          );
        }
        final theme = Theme.of(context);
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = docs[index].data() as Map<String, dynamic>?;
            final mood = (d?['mood'] as num?)?.toInt() ?? 0;
            final notes = (d?['notes'] as String?) ?? '';
            final diary = (d?['diaryText'] as String?) ?? '';
            final details =
                [notes, diary].where((s) => s.trim().isNotEmpty).join('\n');
            return ListTile(
              tileColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Mood: $mood', style: theme.textTheme.titleSmall),
              subtitle: details.isEmpty
                  ? null
                  : Text(details, style: theme.textTheme.bodySmall),
            );
          },
        );
      },
    );
  }
}
