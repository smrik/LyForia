import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyforia/utils/firebase_refs.dart';

/// Backfills `dateTime` for documents in `binge_entries` that don't have it yet.
/// Combines `date` (Timestamp at day precision) and `time` (e.g., "13:45").
/// Returns the number of documents updated.
Future<int> backfillBingeEntriesDateTime({int commitEvery = 400}) async {
  final col = Fb.firestore.collection('binge_entries');

  final snap = await col.get();
  int updated = 0;
  int ops = 0;
  WriteBatch batch = Fb.firestore.batch();

  for (final doc in snap.docs) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    if (data['dateTime'] != null) continue; // already set

    final Timestamp? dateTs = data['date'] as Timestamp?;
    final String timeStr = (data['time'] as String?) ?? '0:0';

    DateTime base = (dateTs?.toDate()) ?? DateTime.now();
    final parts = timeStr.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final dt = DateTime(base.year, base.month, base.day, hour, minute);

    batch.update(doc.reference, {
      'dateTime': Timestamp.fromDate(dt),
    });
    updated++;
    ops++;

    if (ops >= commitEvery) {
      await batch.commit();
      batch = Fb.firestore.batch();
      ops = 0;
    }
  }

  if (ops > 0) {
    await batch.commit();
  }

  return updated;
}
