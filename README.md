# LyForia

A Flutter mental health tracking app for daily mood monitoring, eating habit awareness, task management, and wellness analytics.

## Why This Exists

LyForia helps people develop awareness of their mental health and wellness patterns through structured daily check-ins and visual analytics. It combines mood tracking, habit formation, and task management in one place—supporting users who want to understand their emotional trends and build better daily routines.

## Example User Flow

1. **Open app** → bottom nav shows 5 tabs (Check-in, Eating, To-Do, Analytics, Habits)
2. **Check-in tab**: Tap a mood slider (5-point scale), optionally add notes and a diary entry, hit "Save"
3. **Eating tab**: Log meals and track binge patterns over time
4. **To-Do tab**: Create and manage daily tasks
5. **Analytics tab**: View charts of mood trends and habit completion rates over days/weeks
6. **Habits tab**: Create custom daily habits (e.g., "exercise", "sleep 8h") and check off completions

All data syncs to Firebase in real-time and persists across devices.

## Tech Stack

- **Framework:** Flutter (SDK >= 3.0.0) | **State:** Provider | **Backend:** Firebase (Auth, Firestore)
- **UI:** Material Design, FL Chart (analytics), table_calendar, Google Fonts
- **Auth:** Google Sign-in + Firebase Auth | **Platforms:** Android, iOS, Web

## Project Structure

```
lib/
├── main.dart              # App entry, Firebase init, 5-tab bottom nav (lazy-loaded pages)
├── pages/                 # Check-in, Eating, To-Do, Analytics, Habit Tracker screens
├── screens/               # Diary screen
├── models/                # Data models (Habit, CheckIns, etc.)
├── widgets/               # Reusable UI components
├── theme.dart, theme_provider.dart
├── utils/                 # Firebase refs, constants, error handling
└── firebase_options.dart  # Firebase config (platform-specific)
```

## Status & Gotchas

**Dormant/paused** — feature-complete MVP (v0.1.0) but not actively maintained. Known limitations:
- Requires valid Firebase project credentials (`firebase_options.dart`) to run; no mock backend
- No sample/demo data—starts with empty state
- Pre-release polish; UI/UX may feel minimal
- No onboarding flow or settings screen (yet)

## How to Run

```bash
cd lyforia
flutter pub get
flutter run
```

**Requirements:** Flutter 3.0.0+, iOS Xcode, Android SDK, valid Firebase project config.

## Screenshots

_TODO (Patrik): add screenshots here._
