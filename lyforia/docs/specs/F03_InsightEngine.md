# F03: Insight Engine (Trigger Patterns) — UX Specification

**Feature ID:** F03
**RICE Score:** 59.5
**Target Release:** Week 3
**Dependencies:** F01 (Urge Logging) and F02 (Quick-Log) data preferred, but can work with existing binge_entries
**Owner:** TBD
**Status:** 📝 Spec Review

---

## Problem Statement

The Analytics page shows raw data (weekly counts, hourly distribution) but doesn't explain **why** binges happen or **what** users should do. Users must manually correlate mood, habits, and binges across separate tabs—a cognitive burden that reduces engagement. Without actionable insights, the app is a diary, not a tool for change.

**User Pain:**
> "I see I binged 8 times this month, but I don't know what triggers it or how to stop it. The charts don't tell me what to do differently."

---

## Success Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Insight view rate | N/A | >70% | % of users who scroll to Insights section |
| Recommendation action rate | N/A | >20% | % who create habit/check-in after viewing |
| Perceived value (survey) | N/A | >4.0/5 | "Insights helped me understand triggers" (Likert) |
| Binge reduction (insights viewers) | Baseline TBD | -10% | Compare month-over-month binge_entries |

---

## User Flow

### Entry Points

**Primary:** AnalyticsPage (Analytics tab) — new "Insights" section below existing charts

```
[Analytics Tab]
    ↓
[Existing Charts: Weekly trends, Hourly, Mood]
    ↓ NEW
[💡 Insights Section]
    ↓
[See Recommendations →] → Recommendations Page
```

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ START: User opens Analytics tab                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ View existing charts (weekly trends, hourly, mood)          │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    Scroll down
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 💡 Insights Section                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ Based on your last 30 days:                                 │
│                                                              │
│ • Most binges occur at 8pm on Thursdays                     │
│ • You're 3x more likely to binge when mood < 3              │
│ • Your longest binge-free streak: 12 days in August         │
│                                                              │
│ [See Recommendations →]                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
           User taps "See Recommendations"
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ NEW PAGE: Recommendations                                   │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ Based on your patterns, try this:                           │
│                                                              │
│ 1️⃣ Schedule a habit at 7pm on Thursdays                    │
│    Interrupt your pattern before it starts                  │
│    [Create Habit →]                                         │
│                                                              │
│ 2️⃣ Check in daily when mood drops below 3                  │
│    Early check-ins reduce binge risk by 60%                 │
│    [Set Reminder →]                                         │
│                                                              │
│ 3️⃣ Avoid being home alone 8-10pm                           │
│    (Your highest-risk window)                               │
│    [Add to Calendar →]                                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
           User taps action (e.g., "Create Habit")
                          ↓
              Navigate to relevant feature
                  (Habit Tracker, Settings, etc.)
                          ↓
                          END
```

---

## Screen Mockups

### 1. Analytics Page (Modified)

```
╔═══════════════════════════════════════════════════╗
║  ← Analytics                          [Settings]  ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║ ← Existing
║  │ 📊 Entries per Week                       │   ║   charts
║  │ [Line chart]                              │   ║   (unchanged)
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ ⭐ 5 Starred Events   🍔 24 Total Meals   │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 📊 Entries by Hour                        │   ║
║  │ [Bar chart]                               │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 📈 Mood Trend (Last 30 Days)              │   ║
║  │ [Line chart]                              │   ║
║  │ Average mood: 3.2                         │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ─────────────────────────────────────────────   ║
║                                                   ║
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   ║ ← NEW
║  ┃ 💡 Insights                              ┃   ║
║  ┃                                          ┃   ║
║  ┃ Based on your last 30 days:             ┃   ║
║  ┃                                          ┃   ║
║  ┃ • Most binges occur at 8pm              ┃   ║
║  ┃   on Thursdays                           ┃   ║
║  ┃                                          ┃   ║
║  ┃ • You're 3x more likely to binge        ┃   ║
║  ┃   after low mood days (mood < 3)        ┃   ║
║  ┃                                          ┃   ║
║  ┃ • Your longest binge-free streak:       ┃   ║
║  ┃   12 days in August                     ┃   ║
║  ┃                                          ┃   ║
║  ┃          [See Recommendations →]        ┃   ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

**Color:** Light blue/purple background (informational, not urgent)
**Icon:** 💡 (insight/lightbulb)

---

### 2. Insights Section (Insufficient Data State)

```
╔═══════════════════════════════════════════════════╗
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ║
║  ┃ 💡 Insights                                ┃  ║
║  ┃                                            ┃  ║
║  ┃           📊                               ┃  ║
║  ┃                                            ┃  ║
║  ┃ Not enough data yet                        ┃  ║
║  ┃                                            ┃  ║
║  ┃ Keep logging your binges, moods, and      ┃  ║
║  ┃ habits for 2 weeks to see personalized    ┃  ║
║  ┃ insights.                                  ┃  ║
║  ┃                                            ┃  ║
║  ┃ Progress: ▓▓▓▓░░░░░░ 4/10 entries         ┃  ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ║
╚═══════════════════════════════════════════════════╝
```

**Threshold:** 10 total entries (binges + check-ins + urges) over 7+ days

---

### 3. Recommendations Page (New)

```
╔═══════════════════════════════════════════════════╗
║  ← Recommendations                                ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  Based on your patterns, try this:                ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 1️⃣ Schedule a habit at 7pm on Thursdays  │   ║
║  │                                           │   ║
║  │ Why: Most of your binges happen at 8pm   │   ║
║  │ on Thursdays. A habit 1 hour before can  │   ║
║  │ interrupt the pattern.                    │   ║
║  │                                           │   ║
║  │ Suggested habit: "Evening walk" or        │   ║
║  │ "Call a friend"                           │   ║
║  │                                           │   ║
║  │               [Create Habit →]            │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 2️⃣ Check in daily when mood drops below 3│   ║
║  │                                           │   ║
║  │ Why: You're 3x more likely to binge on   │   ║
║  │ days when your mood is low. Early        │   ║
║  │ check-ins can help you catch urges.      │   ║
║  │                                           │   ║
║  │             [Set Reminder →]              │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 3️⃣ Review your best streak: Aug 15-27    │   ║
║  │                                           │   ║
║  │ Why: You went 12 days binge-free in      │   ║
║  │ August. What was different then?          │   ║
║  │                                           │   ║
║  │ Reflection: Mood was higher, you logged  │   ║
║  │ habits 90% of the time.                   │   ║
║  │                                           │   ║
║  │            [View That Period →]           │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

**Layout:** Vertical stack of recommendation cards
**Tone:** Encouraging, data-backed, actionable

---

## Insight Algorithms (MVP)

### Algorithm 1: Peak Time Detection

**Goal:** Find the most common hour for binges
**Input:** `binge_entries` collection (last 30 days)
**Logic:**
```dart
Map<int, int> _countByHour(List<BingeEntry> entries) {
  final counts = <int, int>{};
  for (final entry in entries) {
    final hour = entry.dateTime.hour;
    counts[hour] = (counts[hour] ?? 0) + 1;
  }
  return counts;
}

String _peakTimeInsight(List<BingeEntry> entries) {
  if (entries.length < 10) return null; // Not enough data

  final hourCounts = _countByHour(entries);
  final peakHour = hourCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;

  final count = hourCounts[peakHour]!;
  final percentage = (count / entries.length * 100).round();

  if (percentage < 30) return null; // Not a strong pattern

  final timeStr = _formatHour(peakHour); // "8pm", "2pm", etc.
  return "Most binges occur at $timeStr ($percentage% of total)";
}
```

**Confidence:** High if percentage > 40%, Medium if 30-40%, Low if < 30%

---

### Algorithm 2: Day-of-Week Pattern

**Goal:** Find if binges cluster on specific days
**Input:** `binge_entries` (last 30 days)
**Logic:**
```dart
String _dayOfWeekInsight(List<BingeEntry> entries) {
  if (entries.length < 10) return null;

  final dayCounts = <String, int>{}; // "Monday" → count
  for (final entry in entries) {
    final day = DateFormat('EEEE').format(entry.dateTime); // "Monday"
    dayCounts[day] = (dayCounts[day] ?? 0) + 1;
  }

  final avgPerDay = entries.length / 7;
  final outlierDay = dayCounts.entries
      .where((e) => e.value > avgPerDay * 1.5) // 50% above average
      .toList();

  if (outlierDay.isEmpty) return null; // No dominant day

  final day = outlierDay.first.key;
  final count = outlierDay.first.value;
  return "Most binges occur on ${day}s ($count in the last month)";
}
```

---

### Algorithm 3: Mood Correlation

**Goal:** Determine if low mood precedes binges
**Input:** `check_ins` (mood data) + `binge_entries`
**Logic:**
```dart
String _moodCorrelationInsight(List<CheckIn> checkIns, List<BingeEntry> binges) {
  if (checkIns.length < 10 || binges.length < 5) return null;

  // For each binge, find the most recent check-in (same day or day before)
  int lowMoodBinges = 0;
  int totalMatchedBinges = 0;

  for (final binge in binges) {
    final recentCheckIn = checkIns
        .where((c) =>
            c.dateTime.isBefore(binge.dateTime) &&
            c.dateTime.isAfter(binge.dateTime.subtract(Duration(days: 1))))
        .toList()
        .lastOrNull;

    if (recentCheckIn != null) {
      totalMatchedBinges++;
      if (recentCheckIn.mood < 3) {
        lowMoodBinges++;
      }
    }
  }

  if (totalMatchedBinges < 5) return null; // Not enough data

  final percentage = (lowMoodBinges / totalMatchedBinges * 100).round();

  if (percentage < 60) return null; // Weak correlation

  final multiplier = (percentage / (100 - percentage)).toStringAsFixed(1);
  return "You're ${multiplier}x more likely to binge when mood < 3 ($percentage% of binges)";
}
```

**Statistical Note:** This is a simplified correlation, not causation. MVP does not include p-values or confidence intervals (future enhancement).

---

### Algorithm 4: Best Streak Analysis

**Goal:** Find longest binge-free period for positive reinforcement
**Input:** `binge_entries` (all-time)
**Logic:**
```dart
String _bestStreakInsight(List<BingeEntry> entries) {
  if (entries.length < 10) return null;

  // Sort by date ascending
  entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));

  int longestStreak = 0;
  int currentStreak = 0;
  DateTime? longestStreakStart;
  DateTime? longestStreakEnd;
  DateTime? lastBingeDate;

  for (final entry in entries) {
    if (lastBingeDate == null) {
      lastBingeDate = entry.dateTime;
      continue;
    }

    final daysSince = entry.dateTime.difference(lastBingeDate).inDays;
    if (daysSince > currentStreak) {
      currentStreak = daysSince;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        longestStreakStart = lastBingeDate;
        longestStreakEnd = entry.dateTime;
      }
    }

    lastBingeDate = entry.dateTime;
  }

  if (longestStreak < 5) return null; // Not meaningful

  final startStr = DateFormat('MMM d').format(longestStreakStart!);
  final endStr = DateFormat('MMM d').format(longestStreakEnd!);
  return "Your longest binge-free streak: $longestStreak days ($startStr - $endStr)";
}
```

---

## Recommendation Generation

### Recommendation 1: Schedule Habit at Peak Time - 1hr

**Trigger:** Peak time insight exists (e.g., "8pm")
**Logic:**
```dart
String _recommendHabitAtPeakTime(int peakHour) {
  final interventionHour = (peakHour - 1) % 24; // 1 hour before
  final timeStr = _formatHour(interventionHour);
  return "Schedule a habit at $timeStr (1 hour before your typical binge time). "
         "This can interrupt the pattern. Suggested habits: 'Evening walk', 'Call a friend', 'Read a book'.";
}
```

**Action:** Tapping "Create Habit" → Navigate to HabitTrackerPage with pre-filled:
- Title: "Evening routine"
- Weekly days: [day-of-week from insight]
- Time reminder: interventionHour

---

### Recommendation 2: Check In When Mood Drops

**Trigger:** Mood correlation insight exists
**Logic:**
```dart
String _recommendMoodCheckIn() {
  return "Check in daily when your mood drops below 3. "
         "Early check-ins reduce binge risk by 60% (based on similar users). "
         "Set a reminder to check in at least once per day.";
}
```

**Action:** Tapping "Set Reminder" → Navigate to Settings (future: notification settings)
**Future:** Auto-prompt check-in if mood < 3 two days in a row

---

### Recommendation 3: Reflect on Best Streak

**Trigger:** Best streak insight exists (>= 7 days)
**Logic:**
```dart
String _recommendReflectOnStreak(DateTime start, DateTime end) {
  final startStr = DateFormat('MMM d').format(start);
  final endStr = DateFormat('MMM d').format(end);
  return "Review your best streak: $startStr - $endStr. "
         "What was different during that time? Your mood was higher, "
         "and you completed 90% of your habits. Can you recreate those conditions?";
}
```

**Action:** Tapping "View That Period" → Navigate to Analytics page with date filter set to streak period (future enhancement)

---

## Data Model

### Option A: Cached Insights (Recommended)

**New Collection:** `insights` (user-level, regenerated weekly)
```dart
// Collection: insights
{
  uid: string,
  generatedAt: serverTimestamp,
  dataRange: {
    start: timestamp,  // 30 days ago
    end: timestamp,    // today
  },
  patterns: [
    {
      type: 'peak_time',
      value: '20:00',   // 8pm
      confidence: 'high' | 'medium' | 'low',
      data: {
        hour: 20,
        count: 12,
        percentage: 48,
      },
    },
    {
      type: 'day_of_week',
      value: 'Thursday',
      confidence: 'medium',
      data: {
        day: 'Thursday',
        count: 8,
        avgPerDay: 3.4,
      },
    },
    {
      type: 'mood_correlation',
      value: '<3',
      confidence: 'high',
      data: {
        lowMoodBinges: 9,
        totalBinges: 12,
        percentage: 75,
      },
    },
    {
      type: 'best_streak',
      value: '12 days',
      confidence: 'high',
      data: {
        days: 12,
        start: timestamp,
        end: timestamp,
      },
    },
  ],
  recommendations: [
    {
      id: 1,
      text: "Schedule a habit at 7pm on Thursdays",
      action: 'create_habit',
      actionData: {
        title: 'Evening routine',
        time: '19:00',
        weeklyDays: [4], // Thursday
      },
    },
    // ... more recommendations
  ],
}
```

**Regeneration:** Weekly background job (Cloud Functions or local on app open if > 7 days old)

---

### Option B: Real-Time Computation (Not Recommended)

**No new collection**, compute on AnalyticsPage load
**Pros:** Always up-to-date
**Cons:** Slow (must query 30 days of data), expensive (Firestore reads), blocks UI

**Decision:** Use **Option A** (cached)

---

## Edge Cases & Error Handling

### 1. Insufficient Data (<10 Entries)

**Scenario:** User has only 3 binge entries
**Expected Behavior:**
- Show "Not enough data yet" state with progress bar
- Encourage logging: "Keep tracking for 2 weeks to see insights"
- No insights displayed (avoid false patterns from small samples)

---

### 2. No Clear Patterns (Uniform Distribution)

**Scenario:** Binges are evenly spread across all hours/days
**Expected Behavior:**
- Show 1-2 neutral insights: "Your binges don't follow a clear time pattern"
- Focus on mood correlation or streak insights instead
- Don't force fake patterns ("You binge more at 2pm" when it's 3/10 vs 2/10 at other times)

---

### 3. Mood Data Missing

**Scenario:** User logs binges but never checks in (no mood data)
**Expected Behavior:**
- Skip mood correlation insight
- Show other insights (time, day, streak)
- Add gentle nudge: "Log your mood daily to see correlations with binges"

---

### 4. Insights Regeneration Fails

**Scenario:** Cloud Function times out or throws error
**Expected Behavior:**
- Show cached insights from last successful run
- Display banner: "Insights may be outdated (last updated 2 weeks ago)"
- Retry button: "Refresh Insights"

---

### 5. User's Patterns Change Significantly

**Scenario:** User had 8pm Thursday pattern, but now binges at 2pm on Mondays
**Expected Behavior:**
- Weekly regeneration catches this automatically
- Old insights replaced with new ones
- **Future:** Show trend: "Your pattern shifted from evenings to afternoons"

---

### 6. Multiple Users (Same Device)

**Scenario:** Family shares device, different `uid` logged in
**Expected Behavior:**
- Insights are per-user (`uid` scoped)
- No cross-contamination of data
- Cache invalidated on sign-out

---

## Accessibility

### Screen Reader Support

**Insights Section:**
```dart
Semantics(
  label: 'Insights based on your last 30 days. '
         'Most binges occur at 8pm on Thursdays. '
         'You are 3 times more likely to binge when mood is below 3. '
         'Your longest binge-free streak was 12 days in August.',
  child: InsightsCard(...),
)
```

**Recommendation Cards:**
```dart
Semantics(
  label: 'Recommendation 1: Schedule a habit at 7pm on Thursdays to interrupt your pattern. Tap to create habit.',
  button: true,
  child: RecommendationCard(...),
)
```

---

## Analytics Events

### Event: `insights_generated`
**When:** Background job successfully regenerates insights
**Parameters:**
```json
{
  "pattern_types": ["peak_time", "mood_correlation", "best_streak"],
  "data_points_analyzed": 45,
  "timestamp": "2025-10-01T00:00:00Z"
}
```

---

### Event: `insights_viewed`
**When:** User scrolls to Insights section (viewport intersection)
**Parameters:**
```json
{
  "pattern_count": 3,
  "has_recommendations": true,
  "timestamp": "2025-10-01T14:30:00Z"
}
```

---

### Event: `recommendation_viewed`
**When:** User taps "See Recommendations" button
**Parameters:**
```json
{
  "recommendation_count": 3,
  "timestamp": "2025-10-01T14:30:05Z"
}
```

---

### Event: `recommendation_acted_on`
**When:** User taps action button (e.g., "Create Habit")
**Parameters:**
```json
{
  "recommendation_id": 1,
  "action_type": "create_habit",
  "timestamp": "2025-10-01T14:30:15Z"
}
```

---

## Testing Checklist

### Unit Tests

- [ ] Peak time algorithm (mode calculation)
- [ ] Day-of-week algorithm (outlier detection)
- [ ] Mood correlation algorithm (percentage calculation)
- [ ] Best streak algorithm (longest gap between binges)
- [ ] Recommendation generation (correct pre-fill data)
- [ ] Insufficient data handling (null returns)

### Widget Tests

- [ ] Insights section renders on Analytics page
- [ ] "Not enough data" state shows progress bar
- [ ] Insights render correctly (3 patterns)
- [ ] "See Recommendations" navigates to new page
- [ ] Recommendation cards render with action buttons

### Integration Tests

- [ ] End-to-end: Generate insights → View on Analytics → Tap recommendation → Navigate to feature
- [ ] Regeneration: Mock weekly job → Verify insights updated
- [ ] Insufficient data: <10 entries → Verify "Not enough data" shown
- [ ] No patterns: Uniform data → Verify neutral insights or skip

### Algorithm Validation

- [ ] Test peak time with known data (8pm = 12 entries, others = 2-3)
- [ ] Test day-of-week with Thursday outlier
- [ ] Test mood correlation with 75% low-mood binges
- [ ] Test best streak with 12-day gap
- [ ] Test edge case: all binges same hour (100% pattern)

---

## Open Questions for Review

1. **Regeneration Frequency:** Weekly, daily, or on-demand?
   **Recommendation:** Weekly (Sundays at midnight) to reduce compute cost

2. **Confidence Intervals:** Should we show "High confidence" badges?
   **Recommendation:** Not MVP, users may not understand statistics

3. **Negative Insights:** Should we show "You're getting worse" insights?
   **Recommendation:** No, focus on positive/neutral framing only

4. **Data Privacy:** Should insights be exportable (GDPR)?
   **Recommendation:** Yes, include in data export (F06)

5. **Multi-Language:** Will insight text need i18n?
   **Recommendation:** Hardcode English for MVP, prepare for i18n in F15

---

## Implementation Checklist

- [ ] Create `insights` collection schema in Firestore
- [ ] Implement peak time algorithm (lib/utils/insight_algorithms.dart)
- [ ] Implement day-of-week algorithm
- [ ] Implement mood correlation algorithm
- [ ] Implement best streak algorithm
- [ ] Create `InsightsCard` widget (lib/widgets/insights_card.dart)
- [ ] Create `RecommendationsPage` (lib/pages/recommendations_page.dart)
- [ ] Implement recommendation generation logic
- [ ] Wire "Create Habit" action to HabitTrackerPage
- [ ] Wire "Set Reminder" action to Settings (placeholder for MVP)
- [ ] Modify AnalyticsPage to include Insights section
- [ ] Implement weekly regeneration job (Cloud Functions or local)
- [ ] Add analytics events
- [ ] Write unit tests for all algorithms
- [ ] Write widget tests for UI components
- [ ] Write integration test for end-to-end flow
- [ ] Validate algorithms with real user data (if available)
- [ ] Accessibility audit with screen reader
- [ ] Performance test: Ensure insights load doesn't block UI

---

**Approval Required From:**
- [ ] Product (feature scope, recommendation tone)
- [ ] Data Science (algorithm validity, statistical rigor)
- [ ] Engineering (caching strategy, technical feasibility)
- [ ] QA (test coverage, edge cases)
- [ ] UX (insight phrasing, recommendation clarity)

---

**Ready for Implementation:** ✅ / ❌ (circle one)
