import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyforia/models/habit.dart';
import 'package:lyforia/widgets/habit_card_enhanced.dart';
import 'package:lyforia/utils/firebase_refs.dart';
import 'package:lyforia/utils/app_constants.dart';
import 'package:lyforia/utils/error_handler.dart';
import 'package:lyforia/widgets/common_widgets.dart';

abstract class HabitStore {
  Future<List<Habit>> load();
  Future<void> save(List<Habit> items);
  Future<Map<DateTime, bool>> loadCompletionHistory(String habitId, {int days = 7});
  Future<void> saveCompletion(String habitId, DateTime date, bool completed);
}

class InMemoryHabitStore implements HabitStore {
  static final InMemoryHabitStore instance = InMemoryHabitStore._();
  InMemoryHabitStore._();
  static List<Habit> _items = [];
  static Map<String, Map<DateTime, bool>> _completions = {}; // habitId → {date → completed}

  @override
  Future<List<Habit>> load() async => List.unmodifiable(_items);

  @override
  Future<void> save(List<Habit> items) async {
    _items = List.from(items);
  }

  @override
  Future<Map<DateTime, bool>> loadCompletionHistory(String habitId, {int days = 7}) async {
    return _completions[habitId] ?? {};
  }

  @override
  Future<void> saveCompletion(String habitId, DateTime date, bool completed) async {
    _completions.putIfAbsent(habitId, () => {});
    final dateOnly = DateTime(date.year, date.month, date.day);
    _completions[habitId]![dateOnly] = completed;
  }
}

class FirestoreHabitStore implements HabitStore {
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      Fb.firestore.collection('habits').withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
            toFirestore: (data, _) => data,
          );

  @override
  Future<List<Habit>> load() async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) return [];
    final q = await _col(uid)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return q.docs.map((d) {
      final data = d.data();
      return Habit(
        id: d.id,
        userId: (data['userId'] as String?) ?? (data['uid'] as String?) ?? uid,
        title: (data['title'] as String?) ?? '',
        description: data['description'] as String?,
        emoji: data['emoji'] as String?,
        color: (data['color'] as num?)?.toInt(),
        weeklyDays: (data['weeklyDays'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [1, 2, 3, 4, 5, 6, 7],
        archived: (data['archived'] as bool?) ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate().toUtc() ??
            DateTime.now().toUtc(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate().toUtc() ??
            DateTime.now().toUtc(),
        lastCheckedAt: (data['lastCheckedAt'] as Timestamp?)?.toDate().toUtc(),
        streakCount: (data['streakCount'] as num?)?.toInt() ?? 0,
        bestStreak: (data['bestStreak'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> save(List<Habit> items) async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) return;
    final batch = Fb.firestore.batch();
    for (final h in items) {
      final ref = Fb.firestore.collection('habits').doc(h.id);
      batch.set(
          ref,
          {
            'uid': uid,
            'userId': h.userId,
            'title': h.title,
            'description': h.description,
            'emoji': h.emoji,
            'color': h.color,
            'weeklyDays': h.weeklyDays,
            'archived': h.archived,
            'createdAt': Timestamp.fromDate(h.createdAt),
            'updatedAt': Timestamp.fromDate(h.updatedAt),
            'lastCheckedAt': h.lastCheckedAt != null
                ? Timestamp.fromDate(h.lastCheckedAt!)
                : null,
            'streakCount': h.streakCount,
            'bestStreak': h.bestStreak,
          },
          SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<Map<DateTime, bool>> loadCompletionHistory(String habitId, {int days = 7}) async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) return {};

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    // Query habit_completions subcollection
    final q = await Fb.firestore
        .collection('habits')
        .doc(habitId)
        .collection('completions')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    final Map<DateTime, bool> history = {};
    for (final doc in q.docs) {
      final data = doc.data();
      final ts = data['date'] as Timestamp?;
      if (ts != null) {
        final date = ts.toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        history[dateOnly] = (data['completed'] as bool?) ?? true;
      }
    }

    return history;
  }

  @override
  Future<void> saveCompletion(String habitId, DateTime date, bool completed) async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) return;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final docId = '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

    await Fb.firestore
        .collection('habits')
        .doc(habitId)
        .collection('completions')
        .doc(docId)
        .set({
      'uid': uid,
      'date': Timestamp.fromDate(dateOnly),
      'completed': completed,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class HabitController extends ChangeNotifier {
  HabitController({required this.store, required this.userId});
  final HabitStore store;
  final String userId;
  List<Habit> habits = [];
  Map<String, Map<DateTime, bool>> _completionHistories = {}; // habitId → history
  _UndoState? _lastUndo;
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    habits = await store.load();
    _loaded = true;
    notifyListeners();

    // Load completion histories for all habits
    for (final habit in habits) {
      _completionHistories[habit.id] = await store.loadCompletionHistory(habit.id);
    }
    notifyListeners();
  }

  Future<void> addHabit(String title, {String? emoji}) async {
    final now = DateTime.now().toUtc();
    final h = Habit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      emoji: emoji,
      createdAt: now,
      updatedAt: now,
    );
    habits = [h, ...habits];
    await store.save(habits);
    _completionHistories[h.id] = {};
    notifyListeners();
  }

  bool isCheckedToday(Habit h) {
    if (h.lastCheckedAt == null) return false;
    final local = h.lastCheckedAt!.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  Map<DateTime, bool> getCompletionHistory(Habit h) {
    return _completionHistories[h.id] ?? {};
  }

  Future<void> checkIn(Habit h) async {
    if (isCheckedToday(h)) return; // already checked today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate new streak
    int newStreak = 1;
    if (h.lastCheckedAt != null) {
      final last = h.lastCheckedAt!.toLocal();
      final lastDay = DateTime(last.year, last.month, last.day);
      if (today.difference(lastDay).inDays == 1) {
        newStreak = h.streakCount + 1;
      }
    }

    // Save undo state
    final idx = habits.indexWhere((e) => e.id == h.id);
    _lastUndo = _UndoState(habits[idx], _completionHistories[h.id]?[today]);

    // Update habit
    final updated = h.copyWith(
      lastCheckedAt: now.toUtc(),
      streakCount: newStreak,
      bestStreak: (newStreak > h.bestStreak) ? newStreak : h.bestStreak,
      updatedAt: DateTime.now().toUtc(),
    );
    habits = [...habits]..[idx] = updated;

    // Save completion to subcollection
    await store.saveCompletion(h.id, today, true);

    // Update local history
    _completionHistories[h.id] = await store.loadCompletionHistory(h.id);

    await store.save(habits);
    notifyListeners();
  }

  Future<void> undo() async {
    if (_lastUndo == null) return;
    final prev = _lastUndo!;
    final idx = habits.indexWhere((e) => e.id == prev.habit.id);
    if (idx == -1) return;

    // Restore habit state
    habits = [...habits]..[idx] = prev.habit;

    // Restore completion state (remove today's completion)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (prev.wasCompleted != null) {
      await store.saveCompletion(prev.habit.id, today, prev.wasCompleted!);
    } else {
      // Remove the completion
      await store.saveCompletion(prev.habit.id, today, false);
    }

    // Reload history
    _completionHistories[prev.habit.id] = await store.loadCompletionHistory(prev.habit.id);

    _lastUndo = null;
    await store.save(habits);
    notifyListeners();
  }
}

class _UndoState {
  final Habit habit;
  final bool? wasCompleted; // previous completion state for today

  _UndoState(this.habit, this.wasCompleted);
}

class HabitTrackerPage extends StatefulWidget {
  HabitTrackerPage({super.key, HabitStore? store, String? userId})
      : store = store ?? FirestoreHabitStore(),
        userId = userId ?? 'local';
  final HabitStore store;
  final String userId;

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage>
    with ErrorHandlerMixin {
  late final HabitController controller;

  @override
  void initState() {
    super.initState();
    controller = HabitController(store: widget.store, userId: widget.userId);
    controller.addListener(_onChange);
    controller.load();
  }

  @override
  void dispose() {
    controller.removeListener(_onChange);
    controller.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: AppPageWrapper(
        child: _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add habit',
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!controller.loaded) {
      return const Center(
          child: AppLoadingIndicator(message: 'Loading habits...'));
    }
    if (controller.habits.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.separated(
      itemCount: controller.habits.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final h = controller.habits[index];
        final checked = controller.isCheckedToday(h);
        final history = controller.getCompletionHistory(h);

        return HabitCardEnhanced(
          habit: h,
          checkedToday: checked,
          completionHistory: history,
          onCheck: () async {
            await controller.checkIn(h);
            if (!mounted) return;
            ErrorHandler.showSuccessSnackBar(
              context,
              'Checked in successfully!',
              action: SnackBarAction(
                label: 'Undo',
                onPressed: controller.undo,
              ),
            );
          },
          onUndo: () async {
            await controller.undo();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppEmptyState(
            icon: Icons.checklist_rounded,
            title: 'No habits yet',
            subtitle: 'Add a habit you care about and check in daily.',
            action: ElevatedButton.icon(
              onPressed: _showAddSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add habit'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSheet() async {
    final res = await showModalBottomSheet<_NewHabitResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _HabitEditorSheet(),
    );
    if (res != null && res.title.trim().isNotEmpty) {
      await controller.addHabit(res.title.trim(),
          emoji: res.emoji?.trim().isEmpty == true ? null : res.emoji);
    }
  }
}

class _HabitEditorSheet extends StatefulWidget {
  const _HabitEditorSheet({this.initialTitle, this.initialEmoji});
  final String? initialTitle;
  final String? initialEmoji;

  @override
  State<_HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<_HabitEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _emoji;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle ?? '');
    _emoji = TextEditingController(text: widget.initialEmoji ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _emoji.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.lg + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Habit', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('habitTitleField'),
            controller: _title,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('habitEmojiField'),
            controller: _emoji,
            decoration: const InputDecoration(labelText: 'Emoji (optional)'),
          ),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(onPressed: _submit, child: const Text('Create')),
        ],
      ),
    );
  }

  void _submit() {
    Navigator.pop(context, _NewHabitResult(_title.text, _emoji.text));
  }
}

class _NewHabitResult {
  final String title;
  final String? emoji;
  _NewHabitResult(this.title, this.emoji);
}
