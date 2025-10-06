# Feature Backlog — Lyforia

**Date:** October 1, 2025
**Scoring Method:** RICE (Reach × Impact × Confidence ÷ Effort)
**Prioritization:** Descending RICE score

---

## RICE Scoring Key

- **Reach:** % of users affected per quarter (0-100)
- **Impact:** Value per user (0.25 Minimal, 0.5 Low, 1 Medium, 2 High, 3 Massive)
- **Confidence:** Certainty of estimates (0-100%)
- **Effort:** Person-weeks to ship (1-20)
- **RICE Score:** (Reach × Impact × Confidence) ÷ Effort

---

## Feature Backlog

| ID | Feature | Reach | Impact | Confidence | Effort | **RICE** | Status |
|----|---------|-------|--------|------------|--------|----------|--------|
| F01 | **Urge Logging + Coping Prompts** | 90 | 3.0 | 80% | 2 | **108.0** | 🎯 Planned |
| F02 | **Quick-Log Binge (Minimal Fields)** | 95 | 2.0 | 90% | 1 | **171.0** | 🎯 Planned |
| F03 | **Insight Engine (Trigger Patterns)** | 85 | 3.0 | 70% | 3 | **59.5** | 🎯 Planned |
| F04 | **Predictive Check-in Reminders** | 75 | 2.0 | 60% | 2 | **45.0** | ⏳ Backlog |
| F05 | **Calendar Heatmap (Multi-Data)** | 80 | 1.0 | 85% | 1.5 | **45.3** | ⏳ Backlog |
| F06 | **Data Export (CSV/JSON)** | 50 | 1.0 | 90% | 1 | **45.0** | ⏳ Backlog |
| F07 | **Coping Toolkit (Breathing, Grounding)** | 70 | 2.0 | 75% | 2 | **52.5** | ⏳ Backlog |
| F08 | **Streaks with Grace Windows** | 80 | 1.0 | 80% | 1 | **64.0** | ⏳ Backlog |
| F09 | **Onboarding Flow (2-3 Screens)** | 100 | 1.0 | 95% | 1 | **95.0** | ⏳ Backlog |
| F10 | **App Shortcuts (Quick Actions)** | 40 | 1.0 | 60% | 1.5 | **16.0** | 📋 Icebox |
| F11 | **Habit Packs (Templates)** | 60 | 1.0 | 70% | 1.5 | **28.0** | 📋 Icebox |
| F12 | **Weekly Review (Reflection Prompt)** | 70 | 1.0 | 75% | 1 | **52.5** | ⏳ Backlog |
| F13 | **Privacy Lock (Biometric/PIN)** | 30 | 2.0 | 80% | 2 | **24.0** | 📋 Icebox |
| F14 | **Correlations Dashboard** | 60 | 2.0 | 50% | 4 | **15.0** | 📋 Icebox |
| F15 | **Localization Scaffold (i18n)** | 25 | 0.5 | 70% | 3 | **2.9** | 📋 Icebox |

---

## Detailed Feature Specs

### F01: Urge Logging + Coping Prompts ⭐ **RICE: 108.0**

**User Story:**
> As a user feeling an urge to binge, I want to log the urge and receive immediate coping suggestions, so I can interrupt the pattern and feel supported.

**Problem:**
- Current app only tracks *completed* binges (post-hoc), missing the critical moment of intervention
- No guidance on what to do *instead* of binging
- Users report feeling helpless during urges

**Value Proposition:**
- **Prevention > Treatment:** Catching urges before they become binges is 10x more impactful
- **Positive Reinforcement:** Logging "I resisted" builds self-efficacy
- **Immediate Support:** In-app coping prompts reduce reliance on external resources

**UX Sketch:**
```
[Check-in Tab]
┌─────────────────────────────┐
│ 💭 Feeling an urge?         │ ← New prominent card
│ [Log Urge] [I'm OK]         │
└─────────────────────────────┘

[On "Log Urge"]
┌─────────────────────────────┐
│ What triggered this urge?   │
│ ☐ Emotion (sad, anxious...) │
│ ☐ Location (home, work...)  │
│ ☐ Social (alone, conflict)  │
│ ☐ Physical (tired, hungry)  │
│ [Save Urge]                 │
└─────────────────────────────┘

[After Save]
┌─────────────────────────────┐
│ ✅ Urge logged. Try this:   │
│ • 5-min breathing exercise  │
│ • Call a friend             │
│ • Go for a 10-min walk      │
│ [Start] [Not now]           │
└─────────────────────────────┘
```

**Data Model Changes:**
```dart
// New collection: urge_logs
{
  uid: string,
  dateTime: timestamp,
  triggers: List<string>, // emotion, location, social, physical
  intensity: int (1-5),
  copingAttempted: bool,
  copingAction: string?,
  outcome: string?, // resisted | gave_in | null (incomplete)
}
```

**Analytics Events:**
- `urge_logged` (trigger_types, intensity)
- `coping_attempted` (action_type)
- `urge_outcome` (resisted | gave_in)

**Risks:**
- **UI Clutter:** Adding urge logging to already-busy Check-in tab
- **False Positives:** Users may log urges frivolously if too easy
- **Incomplete Logs:** Users may not return to mark outcome

**Mitigation:**
- Make urge logging optional but prominent (collapsible card)
- Add gentle reminder 30min later: "How did it go?"
- Gamify: "You've resisted 5 urges this week 🎉"

**RICE Breakdown:**
- Reach: 90% (most users experience urges weekly)
- Impact: 3.0 (Massive — core JTBD, can prevent binges)
- Confidence: 80% (UX proven in CBT apps, but custom implementation)
- Effort: 2 weeks (new collection, UI components, notification logic)
- **Score: (90 × 3.0 × 0.80) / 2 = 108.0**

---

### F02: Quick-Log Binge (Minimal Fields) ⭐ **RICE: 171.0**

**User Story:**
> As a user who just binged, I want to quickly log it without filling 7 fields, so I can record it in the moment without shame-induced friction.

**Problem:**
- Current binge log requires: time, place, food, comments, V/L/*, weight, calendar selection = **too heavy**
- Users report abandoning logs mid-entry → incomplete data → bad analytics
- Logging should take <30 seconds, currently takes 2-3 minutes

**Value Proposition:**
- **Completeness:** More logs = better trend data
- **Real-time Capture:** Emotional state fresh, details accurate
- **Reduced Shame:** Quick log feels less like "confessing"

**UX Sketch:**
```
[Eating Tab - Quick Log Mode]
┌─────────────────────────────┐
│ ⚡ Quick Log                │
│ Time: [Now] [Pick time ▼]  │
│ Place: [_______________]    │
│ [Log It]  [Add Details →]  │
└─────────────────────────────┘

[After "Log It"]
→ SnackBar: "Entry saved. Want to add notes?" [Yes] [No]

[After "Add Details"]
→ Navigate to full form (existing BingeEatingLogPage)
```

**Data Model Changes:**
- **No changes** to `binge_entries` schema
- Quick-log creates entry with:
  - `time`: TimeOfDay
  - `place`: string
  - `food`, `comments`: empty strings
  - `v`, `l`, `starred`: false
  - `date`: DateTime (today or selected)

**Analytics Events:**
- `binge_quicklog_used` (completion_rate)
- `binge_details_expanded` (from_quicklog: bool)

**Risks:**
- **Data Sparsity:** Fewer details may reduce insight quality
- **User Confusion:** Two entry paths (quick vs full)

**Mitigation:**
- Default to quick-log, show "Add Details" inline
- Analytics can interpolate missing fields (e.g., "unknown food" → still useful for time/place trends)
- A/B test: Quick-log vs full form → measure completion rates

**RICE Breakdown:**
- Reach: 95% (all users log binges)
- Impact: 2.0 (High — removes friction, increases data volume)
- Confidence: 90% (proven pattern in habit trackers like Streaks, Habitica)
- Effort: 1 week (new widget, refactor BingeEatingLogPage to accept pre-fill)
- **Score: (95 × 2.0 × 0.90) / 1 = 171.0**

---

### F03: Insight Engine (Trigger Patterns) ⭐ **RICE: 59.5**

**User Story:**
> As a user reviewing my analytics, I want to see *why* I binge (triggers, patterns), so I can proactively avoid those situations.

**Problem:**
- Analytics page shows *what* (weekly counts, hourly distribution) but not *why*
- Users must manually correlate mood × binges × habits → cognitive load
- No actionable recommendations ("you binge on Thursdays at 8pm — schedule a habit then")

**Value Proposition:**
- **Actionable Insights:** "80% of your binges happen when mood < 3 and you're alone at home"
- **Predictive Value:** "You're at high risk today (similar pattern to last Tuesday)"
- **Personalization:** Insights unique to each user's data

**UX Sketch:**
```
[Analytics Tab - New Section]
┌─────────────────────────────┐
│ 💡 Insights                 │
│ • Most binges occur at 8pm  │
│   on Thursdays              │
│ • You're 3x more likely to  │
│   binge after low mood days │
│ • Your longest binge-free   │
│   streak was 12 days in Aug │
│ [See Recommendations →]     │
└─────────────────────────────┘

[Recommendations Page]
┌─────────────────────────────┐
│ Try This                    │
│ 1. Schedule a habit at 7pm  │
│    on Thursdays (interrupt) │
│ 2. Check in daily when mood │
│    drops below 3            │
│ 3. Avoid being home alone   │
│    8-10pm (your risk window)│
└─────────────────────────────┘
```

**Data Model Changes:**
- **New collection:** `insights` (cached, regenerated weekly)
```dart
{
  uid: string,
  generatedAt: timestamp,
  patterns: [
    {type: 'time_of_day', value: '20:00', frequency: 12},
    {type: 'mood_threshold', value: '<3', correlation: 0.78},
    {type: 'day_of_week', value: 'Thursday', frequency: 8},
  ],
  recommendations: [string],
}
```

**Algorithm (MVP):**
1. **Time Clustering:** Group binges by hour → find peak (mode)
2. **Mood Correlation:** Compare avg mood on binge days vs clean days (t-test)
3. **Day-of-Week:** Count binges per weekday → highlight outliers
4. **Streak Analysis:** Find longest binge-free period → "You did it before, you can again"

**Analytics Events:**
- `insight_viewed` (pattern_type)
- `recommendation_acted_on` (type, outcome)

**Risks:**
- **Cold Start:** Need 2+ weeks of data for meaningful patterns
- **False Correlations:** Small sample sizes → spurious insights
- **Privacy Concerns:** Users may feel "watched" by algorithmic insights

**Mitigation:**
- Show "Not enough data yet" for <10 entries
- Confidence intervals on insights (e.g., "78% correlation" vs "possible link")
- User control: opt-out of insights, delete specific entries from analysis

**RICE Breakdown:**
- Reach: 85% (users with 2+ weeks of data)
- Impact: 3.0 (Massive — core value prop, turns data into action)
- Confidence: 70% (algorithm risk, privacy concerns)
- Effort: 3 weeks (ML-lite algo, caching, UI, testing)
- **Score: (85 × 3.0 × 0.70) / 3 = 59.5**

---

### F04: Predictive Check-in Reminders **RICE: 45.0**

**User Story:**
> As a user approaching a high-risk time, I want a gentle nudge to check in with myself, so I can prevent an urge from escalating.

**Problem:**
- Users forget to check in during high-risk windows
- By the time they remember, urge has already escalated → binge
- Reactive (post-binge logging) vs proactive (pre-urge prevention)

**Value:**
- **Timely Intervention:** Reminder at 7:45pm (user's typical binge time is 8pm)
- **Habit Formation:** Daily reminders anchor check-in behavior
- **Adaptive:** Learns from user's data (not generic "8am daily" reminder)

**UX Sketch:**
```
[Notification - 7:45pm Thursday]
"Your urges often peak around now. How are you feeling?"
[Check In] [Dismiss]

[Check-in Page - Pre-filled]
"We noticed this is a tricky time for you. Take a moment to reflect."
[Mood Slider] [Save]
```

**Data Model:**
- **New collection:** `reminder_settings`
```dart
{
  uid: string,
  enabled: bool,
  learnedTimes: [timestamp], // derived from binge_entries
  customTimes: [timestamp],  // user-set
}
```

**Algorithm:**
1. Analyze last 30 days of binge_entries
2. Cluster by hour (e.g., 80% happen 8-10pm)
3. Set reminder 15min before peak cluster
4. Adjust weekly based on new data

**Analytics Events:**
- `reminder_sent` (learned | custom)
- `reminder_acted_on` (check_in | urge_log | dismiss)

**Risks:**
- **Notification Fatigue:** Too many reminders → users disable
- **Platform Permissions:** iOS/Android notification permissions may be denied
- **False Negatives:** User's pattern changes, reminders become irrelevant

**Mitigation:**
- Max 1 reminder/day
- User can disable or customize times
- Re-run analysis weekly to adapt

**RICE:**
- Reach: 75% (users with consistent patterns)
- Impact: 2.0 (High — prevention > treatment)
- Confidence: 60% (notifications tricky, user may disable)
- Effort: 2 weeks (local notifications, background task, permissions)
- **Score: (75 × 2.0 × 0.60) / 2 = 45.0**

---

### F05: Calendar Heatmap (Multi-Data) **RICE: 45.3**

**User Story:**
> As a user reviewing my month, I want to see binges, moods, and habits on one calendar, so I can spot correlations at a glance.

**Problem:**
- Current calendar (BingeEatingLogPage) only shows binges
- Mood, habits, check-ins are in separate tabs → fragmented view
- Users report wanting "one place to see it all"

**Value:**
- **Holistic View:** Spot patterns like "bad mood → no habits → binge"
- **Visual Correlation:** Color-coded calendar = instant insights
- **Motivational:** See "green days" (all habits + good mood + no binge)

**UX Sketch:**
```
[New Tab: Overview]
┌─────────────────────────────┐
│ October 2025                │
│ Sun Mon Tue Wed Thu Fri Sat │
│  1   2   3   4   5   6   7  │
│ 🟢  🟡  🔴  🟢  🟢  🟡  🟢  │ ← Color legend:
│  8   9  10  11  12  13  14  │   🟢 Great (habits+mood, no binge)
│ 🟢  🔴  🟢  🟢  🟢  🟢  🟢  │   🟡 OK (some habits, mid mood)
│ ...                         │   🔴 Tough (binge or low mood)
└─────────────────────────────┘
[Tap day → detail modal with all entries]
```

**Data Model:**
- **No new collections** (aggregates existing check_ins, binge_entries, habits)
- Pre-compute daily summaries:
```dart
{
  date: DateTime,
  mood: double?, // avg mood from check_ins
  bingeCount: int,
  habitsCompleted: int,
  totalHabits: int,
  status: 'great' | 'ok' | 'tough',
}
```

**Analytics Events:**
- `calendar_viewed` (month)
- `day_detail_opened` (status_type)

**Risks:**
- **Performance:** Loading 30+ days of data may be slow
- **Complexity:** Color-coding logic subjective ("what's a good day?")

**Mitigation:**
- Cache daily summaries in Firestore (update nightly)
- Let users customize "good day" criteria

**RICE:**
- Reach: 80% (all users with data)
- Impact: 1.0 (Medium — nice-to-have, aids reflection)
- Confidence: 85% (straightforward aggregation)
- Effort: 1.5 weeks (new tab, aggregation logic, calendar widget customization)
- **Score: (80 × 1.0 × 0.85) / 1.5 = 45.3**

---

### F06: Data Export (CSV/JSON) **RICE: 45.0**

**User Story:**
> As a user sharing progress with my therapist, I want to export my data, so I can discuss patterns in our sessions.

**Problem:**
- No way to extract data from app
- Users screenshotting analytics charts → lossy, unprofessional
- GDPR/data portability expectation

**Value:**
- **Therapy Integration:** Therapists can analyze data offline
- **Trust:** Users own their data, can leave platform
- **Backup:** Peace of mind (data not locked in)

**UX Sketch:**
```
[Settings → Data & Privacy]
┌─────────────────────────────┐
│ Export My Data              │
│ Download all entries as:    │
│ ☐ CSV (Excel-compatible)    │
│ ☐ JSON (developer-friendly) │
│ [Export]                    │
└─────────────────────────────┘

[On Export]
→ Generates file, shares via platform share sheet
```

**Data Model:**
- No changes (read-only operation)

**CSV Format:**
```csv
type,date,time,mood,place,food,notes
check_in,2025-10-01,14:30,4,,,"Feeling good"
binge,2025-10-01,20:00,,Home,Pizza + ice cream,"Stressed from work"
```

**Analytics Events:**
- `data_export_requested` (format)
- `data_export_completed` (row_count)

**Risks:**
- **Privacy:** Exported file may be shared insecurely
- **Support Burden:** Users may expect import/restore

**Mitigation:**
- Warning: "Keep this file secure (contains personal health data)"
- Phase 2: Import feature

**RICE:**
- Reach: 50% (therapist users, privacy-conscious)
- Impact: 1.0 (Medium — enabling, not core)
- Confidence: 90% (straightforward implementation)
- Effort: 1 week (query all collections, format, share)
- **Score: (50 × 1.0 × 0.90) / 1 = 45.0**

---

### F07: Coping Toolkit (Breathing, Grounding) **RICE: 52.5**

**User Story:**
> As a user in distress, I want guided coping exercises, so I can calm down without leaving the app.

**Problem:**
- App suggests coping strategies (F01) but doesn't *provide* them
- Users leave app to Google "breathing exercises" → friction
- No in-app support during crisis moments

**Value:**
- **Self-Sufficiency:** All tools in one place
- **Engagement:** Keeps users in app during high-value moments
- **Evidence-Based:** Box breathing, 5-4-3-2-1 grounding proven effective

**UX Sketch:**
```
[Check-in Tab → Coping Toolkit Button]
┌─────────────────────────────┐
│ 🧘 Coping Toolkit           │
│ • Box Breathing (4-4-4-4)   │
│ • 5-4-3-2-1 Grounding       │
│ • Progressive Muscle Relax  │
│ • Emergency Contacts        │
└─────────────────────────────┘

[Box Breathing]
┌─────────────────────────────┐
│     ⬜                       │ ← Animated square
│   Breathe In (4s)           │   grows/shrinks
│   [Start] [Stop]            │
└─────────────────────────────┘
```

**Data Model:**
- **New collection:** `coping_sessions`
```dart
{
  uid: string,
  dateTime: timestamp,
  exercise: 'box_breathing' | '54321' | 'pmr',
  durationSeconds: int,
  completed: bool,
}
```

**Analytics Events:**
- `coping_exercise_started` (type)
- `coping_exercise_completed` (type, duration)

**Risks:**
- **Medical Disclaimer:** Not a replacement for therapy/crisis hotline
- **Scope Creep:** Could expand into full meditation app

**Mitigation:**
- Prominent disclaimer: "If in crisis, call 988"
- Limit to 3-4 evidence-based exercises (no feature bloat)

**RICE:**
- Reach: 70% (users in distress moments)
- Impact: 2.0 (High — provides immediate relief)
- Confidence: 75% (exercises proven, but UI execution uncertain)
- Effort: 2 weeks (animations, timer logic, audio?)
- **Score: (70 × 2.0 × 0.75) / 2 = 52.5**

---

### F08: Streaks with Grace Windows **RICE: 64.0**

**User Story:**
> As a user who missed a habit yesterday, I don't want to lose my 30-day streak, so I stay motivated instead of feeling defeated.

**Problem:**
- Current streak logic: miss 1 day → streak resets to 0 → demotivating
- Recovery users need relapse-safe design ("progress, not perfection")
- All-or-nothing thinking is a binge trigger

**Value:**
- **Resilience:** 1 bad day doesn't erase 29 good days
- **Motivation:** Keeps users engaged after slip-ups
- **Realistic:** Aligns with recovery philosophy

**UX Sketch:**
```
[Habit Card - Streak Display]
┌─────────────────────────────┐
│ 🏃 Exercise Daily           │
│ 🔥 30-day streak            │
│ (1 grace day used this week)│ ← New
│ [✓ Check In]                │
└─────────────────────────────┘

[Settings → Habits]
Grace window: [1 day/week ▼] [2 days/week] [None]
```

**Data Model:**
- Add to `habits`:
```dart
{
  graceWindowDays: int, // default 1
  graceDaysUsedThisWeek: int,
  lastGraceDate: timestamp?,
}
```

**Algorithm:**
1. User misses check-in (yesterday was target day)
2. If `graceDaysUsedThisWeek < graceWindowDays`: don't break streak, increment grace counter
3. Reset `graceDaysUsedThisWeek` every Monday

**Analytics Events:**
- `grace_window_used` (habit_id)
- `streak_broken` (was_grace_exhausted: bool)

**Risks:**
- **Gaming:** Users may abuse grace windows
- **Complexity:** Weekly reset logic, edge cases (timezone)

**Mitigation:**
- Default to 1 day/week (not too lenient)
- Make configurable (users who want strict can set to 0)

**RICE:**
- Reach: 80% (all habit users)
- Impact: 1.0 (Medium — QoL improvement, not core value)
- Confidence: 80% (proven in Duolingo, Streaks app)
- Effort: 1 week (model changes, streak calculation, UI tweaks)
- **Score: (80 × 1.0 × 0.80) / 1 = 64.0**

---

### F09: Onboarding Flow (2-3 Screens) **RICE: 95.0**

**User Story:**
> As a new user, I want to understand what this app does before being dropped into the Check-in tab, so I don't feel lost.

**Problem:**
- No onboarding → users don't know where to start
- High churn in first session (analytics would show this)
- Core features (urge logging, insights) are hidden/not obvious

**Value:**
- **Activation:** Educate users on value prop → higher engagement
- **Retention:** Users who complete onboarding = 2x more likely to return
- **Feature Discovery:** Highlight hidden gems (e.g., coping toolkit)

**UX Sketch:**
```
[Screen 1]
Welcome to Lyforia
"Your companion for understanding and reducing binge eating"
[Next →]

[Screen 2]
Track Your Patterns
"Log binges, moods, and habits—we'll surface insights"
[Illustration: calendar heatmap]
[Next →]

[Screen 3]
Get Support When You Need It
"Log urges before they become binges, access coping tools"
[Illustration: breathing timer]
[Get Started →] → Check-in tab

[Optional: Sign In Later]
"You can use Lyforia without an account (local-only), or sign in to sync across devices"
[Sign In] [Skip]
```

**Data Model:**
- **New:** `onboarding_completed: bool` in user prefs (local or Firestore)

**Analytics Events:**
- `onboarding_started`
- `onboarding_completed` (screens_viewed: int)
- `onboarding_skipped` (screen_index: int)

**Risks:**
- **Friction:** Adding 3 screens may delay time-to-value
- **Stale Content:** Onboarding may not reflect app updates

**Mitigation:**
- Make skippable (top-right "Skip" button)
- Version onboarding screens (re-show if major features added)

**RICE:**
- Reach: 100% (all new users)
- Impact: 1.0 (Medium — reduces confusion, not core feature)
- Confidence: 95% (standard pattern, well-understood)
- Effort: 1 week (3 screens, illustrations, navigation logic)
- **Score: (100 × 1.0 × 0.95) / 1 = 95.0**

---

### F10-F15: Lower-Priority Features

| ID | Feature | User Story | Value | RICE | Status |
|----|---------|------------|-------|------|--------|
| **F10** | **App Shortcuts** | Quick-add binge/habit from home screen | Convenience | 16.0 | 📋 Icebox |
| **F11** | **Habit Packs** | Templates like "Morning Routine" (3 habits bundled) | Onboarding ease | 28.0 | 📋 Icebox |
| **F12** | **Weekly Review** | Sunday prompt: "Reflect on your week" | Reflection | 52.5 | ⏳ Backlog |
| **F13** | **Privacy Lock** | Biometric/PIN to access app | Security | 24.0 | 📋 Icebox |
| **F14** | **Correlations Dashboard** | Advanced stats (mood × binge × habits scatter plot) | Power users | 15.0 | 📋 Icebox |
| **F15** | **Localization** | i18n scaffold for Spanish, French | Global reach | 2.9 | 📋 Icebox |

---

## Next Steps

1. **Review this backlog** with stakeholders (if any) or user research
2. **Select top 3 features by RICE** (F01, F02, F03) for MVP implementation
3. **Create detailed UX specs** in `docs/specs/` for chosen features
4. **Implement in order** with tests and PRs per AGENTS.md

---

**End of Backlog**
