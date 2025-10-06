# Baseline Analysis — Lyforia

**Date:** October 1, 2025
**Version:** 0.1.0
**Analyst:** Claude Code

---

## 1. Executive Summary

Lyforia is a Flutter wellbeing app helping users track binge-eating episodes, mood, habits, and tasks to surface insights that reduce binges and improve mental health. The app is Firebase-enabled (Firestore + Auth) with Google Sign-In, currently at MVP stage with core tracking features operational but **several quality issues blocking production readiness**.

**Key Findings:**
- **Build Status:** ❌ FAILING (2 compile errors in theme.dart)
- **Test Status:** ❌ 4/5 tests failing (Firebase initialization, empty state mismatches)
- **Analyze Status:** ⚠️ 36 issues (2 errors, 4 warnings, 30 info lints)
- **Architecture:** Clean separation with pages/, models/, widgets/, utils/; lazy loading optimization in place
- **Target Users:** Individuals managing binge eating disorder, seeking mood/habit correlation insights

---

## 2. Feature Inventory

### 2.1 Core Features (Implemented)

| Feature | Route/Tab | Data Model | Key Capabilities | Status |
|---------|-----------|------------|------------------|--------|
| **Check-in** | CheckInPage (tab 0) | `check_ins` collection | Mood slider (1-5), optional notes + diary, recent check-in list, TODO mood chart | ✅ Functional |
| **Binge Eating Log** | BingeEatingLogPage (tab 1) | `binge_entries` collection | Time, place, food, context, flags (V/L/starred), calendar heatmap, weight log, weekly summary | ✅ Functional |
| **To-Do List** | ToDoListPage (tab 2) | `tasks` collection | Add/check/delete tasks, swipe-to-dismiss, Pomodoro timer (25/5 min) | ✅ Functional |
| **Analytics** | AnalyticsPage (tab 3) | Aggregates `binge_entries`, `moods` | Weekly entry trends (line), hourly patterns (bar), mood trend (30d), starred events count | ✅ Functional |
| **Habit Tracker** | HabitTrackerPage (tab 4) | `habits` collection (Firestore) | Add habits, daily check-in, streak counter, undo last check-in, weekly goal tracking | ✅ Functional |
| **Diary** | DiaryScreen (named route) | None (not linked) | Text entry screen with save/cancel | ⚠️ Orphaned (no nav path) |
| **Settings** | SettingsPage (from Analytics) | n/a | Theme toggle (light/dark), account management (email/password + Google Sign-In), crisis support links | ✅ Functional |

### 2.2 Authentication & Data Sync
- **Firebase Auth:** Email/password + Google Sign-In (configured for Android)
- **Firestore:** Per-user data isolation with `uid` field on all collections
- **Offline:** No explicit offline mode; relies on Firestore SDK caching

---

## 3. Architecture & Code Structure

### 3.1 Directory Layout
```
lib/
├── main.dart                 # App entry, Firebase init, bottom nav (5 tabs)
├── theme.dart                # Material 3 theme with seed color, constants
├── theme_provider.dart       # ThemeMode state (light/dark)
├── pages/                    # 12 page files (check_in, binge, analytics, habits, etc.)
├── screens/                  # 1 screen (diary_screen.dart, not linked)
├── models/                   # 1 model (habit.dart)
├── widgets/                  # 4 reusable widgets (habit_card, entry_tile, common_widgets)
├── utils/                    # 4 utilities (firebase_refs, migrations, error_handler, app_constants)
test/
├── check_in_page_test.dart
├── settings_page_test.dart
├── widget_test.dart
└── widget/habit_tracker_page_test.dart
```

### 3.2 State Management
- **Provider:** ThemeProvider for theme switching
- **Local State:** StatefulWidget + ChangeNotifier (HabitController) for habit tracker
- **Firestore Streams:** StreamBuilder for real-time data binding (check-ins, binge entries, tasks, moods)

### 3.3 Key Design Patterns
- **Lazy Page Loading:** MainPage uses `_ensurePage()` to instantiate tabs on first access (reduces initial build cost)
- **Repository Abstraction:** HabitStore interface with InMemoryHabitStore + FirestoreHabitStore (testable)
- **Mixin-based Error Handling:** ErrorHandlerMixin provides `showError()`/`showSuccess()` to pages
- **Data Migration:** Backfill utility for `dateTime` field consistency on binge_entries

---

## 4. Dependencies & Tech Stack

### 4.1 Core Dependencies
```yaml
flutter: SDK (>=3.0.0 <4.0.0)
provider: ^6.1.5               # State management
firebase_core: ^4.0.0           # Firebase init
cloud_firestore: ^6.0.0        # Database
firebase_auth: ^6.0.1          # Authentication
google_sign_in: ^6.2.1         # OAuth
```

### 4.2 UI/UX Libraries
```yaml
google_fonts: ^6.3.0           # Lato font family
table_calendar: ^3.2.0         # Calendar widget (binge log)
fl_chart: ^1.0.0               # Charts (analytics)
flutter_ringtone_player: ^4.0.0+4  # Pomodoro timer notification
cupertino_icons: ^1.0.6        # iOS-style icons
```

### 4.3 Dev Dependencies
```yaml
flutter_lints: ^6.0.0          # Linting rules
flutter_test: SDK              # Testing framework
```

---

## 5. Quality Assessment

### 5.1 Flutter Analyze Results (36 issues)

#### 🔴 **Errors (2)** — BLOCKING BUILD
| File | Line | Issue | Impact |
|------|------|-------|--------|
| theme.dart | 120 | `CardTheme` → `CardThemeData` type mismatch | Build fails |
| theme.dart | 129 | `DialogTheme` → `DialogThemeData` type mismatch | Build fails |

#### ⚠️ **Warnings (4)**
| File | Line | Issue | Impact |
|------|------|-------|--------|
| main.dart | 28 | Dead null-aware operator (`??`) | Unreachable code |
| habit_tracker_page.dart | 246 | BuildContext across async gap | Potential crash |
| habit_tracker_page.dart | 296 | Unused parameters (initialTitle, initialEmoji) | Tech debt |
| widget_test.dart | 2 | Unused import | Clutter |

#### ℹ️ **Info Lints (30)** — Quality/Style
- **Deprecations (20):** `withOpacity` → `withValues`, `MaterialState` → `WidgetState`, `background` → `surface`
- **Style (10):** Unnecessary breaks, prefer interpolation, `SizedBox` instead of `Container`

### 5.2 Test Results (1/5 passing)

| Test | Status | Root Cause |
|------|--------|------------|
| check_in_page_test | ❌ FAIL | Firebase not initialized in test |
| settings_page_test | ❌ FAIL | Firebase not initialized in test |
| habit_tracker_page_test | ❌ FAIL | Empty state text mismatch (expected "No habits yet", not found) |
| widget_test.dart | ❌ FAIL | Compilation errors from theme.dart |
| (1 passing test) | ✅ PASS | Unknown (no output) |

**Test Coverage:** Unknown (no `--coverage` run due to build errors)

### 5.3 Performance Baseline
- **Startup:** Unknown (no measurement)
- **APK Size:** Unknown (no build due to errors)
- **Frame Drops:** Not measured
- **Optimizations Present:**
  - Lazy tab loading (MainPage._ensurePage)
  - const constructors where applicable
  - StreamBuilder with .limit() queries

---

## 6. Data Model Overview

### 6.1 Firestore Collections

| Collection | Fields | Indexes | Notes |
|------------|--------|---------|-------|
| `check_ins` | uid, mood (1-5), notes, diaryText, dateTime, day | uid + dateTime desc | Daily check-ins with mood slider |
| `binge_entries` | uid, time, place, food, comments, v, l, starred, date, dateTime, createdAt | uid + date | Eating episodes with calendar visualization |
| `tasks` | uid, text, done, createdAt | uid + createdAt desc | To-do items |
| `moods` | uid, mood, dateTime, createdAt | uid + dateTime asc | Mood logs (possibly duplicate of check_ins?) |
| `habits` | uid, userId, title, description, emoji, color, weeklyDays, archived, createdAt, updatedAt, lastCheckedAt, streakCount, bestStreak | uid + createdAt desc | Habit tracking with streaks |

**Schema Inconsistencies:**
- `moods` vs `check_ins`: Overlapping purpose (mood tracking); may cause confusion
- `uid` vs `userId` in habits: Redundant fields
- Missing composite indexes for common queries (e.g., uid + done on tasks)

### 6.2 Model Classes
- **Habit** (lib/models/habit.dart): Full CRUD model with toJson/fromJson, copyWith
- **BingeEntry** (inline in binge_eating_log_page.dart): Embedded model, should be extracted
- **No models** for check-ins, tasks, moods (raw Map usage)

---

## 7. User Experience Observations

### 7.1 Onboarding & Discoverability
- ❌ **No onboarding flow:** New users dropped into Check-in tab with no guidance
- ⚠️ **Sign-in friction:** Must navigate to Analytics → Settings → Account to sign in
- ✅ **Empty states:** Good empty state messages with CTAs (e.g., "Add your first task")

### 7.2 Navigation & Information Architecture
- ✅ **Clear bottom nav:** 5 labeled tabs with filled/outlined icons
- ❌ **Orphaned Diary screen:** DiaryScreen exists but no nav path (only routed, never pushed)
- ⚠️ **Settings buried:** 2 taps from Analytics; should be in Check-in or main nav

### 7.3 Data Entry Friction
- ✅ **Quick entry:** Task and habit creation via bottom sheets (modal)
- ⚠️ **Binge log complexity:** 7 fields (time, place, food, comments, V/L/*, weight) — too many for "in the moment"
- ✅ **Smart defaults:** Check-in pre-fills mood at 3/5

### 7.4 Insights & Value Delivery
- ✅ **Analytics charts:** Weekly trends, hourly patterns, mood correlation
- ❌ **No actionable insights:** Charts show data but no "you tend to binge at 8pm, try X"
- ❌ **No correlations:** Binge × mood × habits not cross-analyzed

---

## 8. Pain Points & Risks

### 8.1 Critical (P0) — Must Fix Before Launch
1. **Build Errors:** theme.dart type mismatches block compilation
2. **Test Failures:** Firebase mock setup missing, blocking CI/CD
3. **Auth Friction:** Users can't access features without signing in, but sign-in is hidden

### 8.2 High (P1) — User Experience Blockers
4. **No Insights/Recommendations:** App collects data but doesn't tell users *what to do*
5. **Binge Log Too Heavy:** 7-field form discourages real-time logging
6. **Orphaned Diary:** DiaryScreen exists but not accessible
7. **Mood vs Check-in Confusion:** Two overlapping mood tracking systems

### 8.3 Medium (P2) — Quality & Polish
8. **Deprecated APIs:** 20 deprecation warnings will break in future Flutter releases
9. **No Offline Support:** App fails silently without network
10. **Schema Redundancy:** uid/userId duplication, moods/check_ins overlap

---

## 9. Target Users & JTBD

### 9.1 Primary Persona: "Recovery Riley"
- **Demographics:** 18-35, urban, tech-comfortable
- **Context:** Managing binge eating disorder in recovery (therapy/self-help)
- **JTBD:** *When I feel an urge to binge, I want to understand my triggers and log my response, so I can reduce frequency and rebuild trust with food.*

### 9.2 User Goals (Inferred from Features)
1. **Awareness:** "What patterns lead to my binges?" (Analytics)
2. **Accountability:** "Did I stick to my habits today?" (Habit Tracker)
3. **Coping:** "What should I do instead of binging?" (No feature yet — critical gap)
4. **Progress:** "Am I getting better over time?" (Streaks, trends)

### 9.3 Unmet Needs (Opportunities)
- **Urge Logging:** Capture near-misses ("I wanted to binge but didn't") for positive reinforcement
- **Trigger Tagging:** Link binges to emotions, locations, people → predictive insights
- **Coping Library:** Breathing exercises, distraction tasks, crisis contacts
- **Notifications:** Proactive check-ins at high-risk times (learned from analytics)

---

## 10. Code Quality & Maintainability

### 10.1 Strengths ✅
- **Clean separation:** Pages, widgets, utils well-organized
- **Reusable components:** AppPageWrapper, AppEmptyState, AppLoadingIndicator
- **Constants-driven:** AppSpacing, AppSizes, AppStrings centralize magic numbers
- **Testability:** HabitStore abstraction enables unit tests
- **Material 3:** Modern design system with seed colors

### 10.2 Weaknesses ⚠️
- **Inline models:** BingeEntry defined in page file (violates SRP)
- **No service layer:** Firestore queries scattered across pages
- **Error handling inconsistency:** Some pages use mixin, others inline
- **Hard-coded strings:** Many UI strings not in AppStrings
- **No logging:** No observability for debugging production issues

### 10.3 Technical Debt
- **TODO in CheckInPage:79:** Mood chart unimplemented (hand-off to human?)
- **Migration tool in Analytics:** Admin-only backfill exposed in prod UI
- **Unused DiaryScreen:** Dead code or incomplete feature?

---

## 11. Recommendations Summary

### 11.1 Immediate (Before any new features)
1. **Fix build errors** (theme.dart CardTheme/DialogTheme)
2. **Mock Firebase in tests** (FakeFirebaseAuth/MockFirestore)
3. **Move Settings to main nav** (or Check-in page)
4. **Extract BingeEntry model** to lib/models/
5. **Remove/link DiaryScreen** (delete or wire up)

### 11.2 MVP Hardening (Next 2 weeks)
6. **Add onboarding flow** (1-2 screens explaining core features)
7. **Quick-log binge** (time + place only, expand optional)
8. **Implement mood chart** in CheckInPage (fl_chart bar)
9. **Unify mood tracking** (deprecate `moods` collection, use check_ins)
10. **Offline support** (Firestore persistence + offline banner)

### 11.3 Value Acceleration (Post-launch)
11. **Insight engine:** "You binge most on Thursdays at 8pm — schedule a habit then"
12. **Urge logging:** Track near-misses for positive feedback loop
13. **Coping toolkit:** Breathing timer, distraction prompts, crisis contacts
14. **Predictive reminders:** "It's 7:45pm — check in with yourself"
15. **Data export:** CSV/JSON for therapy sharing

---

## 12. Appendix: Dependency Graph

```
main.dart
├── theme.dart (errors here)
├── theme_provider.dart
├── firebase_options.dart
└── pages/
    ├── check_in_page.dart → utils/firebase_refs, error_handler, app_constants
    ├── binge_eating_log_page.dart → table_calendar, firebase_refs
    ├── analytics_page.dart → fl_chart, firebase_refs, migrations
    ├── habit_tracker_page.dart → models/habit, widgets/habit_card, error_handler
    ├── to_do_list_page.dart → flutter_ringtone_player, firebase_refs
    └── settings_page.dart → firebase_auth, google_sign_in, theme_provider
```

**Critical Path:** theme.dart errors cascade to all pages → **fix first**.

---

**End of Baseline Report**
