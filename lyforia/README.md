# lyforia

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

-   [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
-   [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Lyforia Diary (How to Run + Verify)

Run locally:

-   Install Flutter (stable) and platform toolchains.
-   Get packages: `flutter pub get`
-   Analyze/format: `flutter analyze` and `dart format .`
-   Run app: `flutter run -d <device>`

Manual test checklist:

-   Launch app → Bottom navigation shows tabs (Diary, Eating, Mood, To‑Do, Analytics, Habits).
-   Go to Diary tab → Tap “New Entry” → Diary screen opens with text field and Save/Cancel.
-   Empty input → Save disabled.
-   Enter text → Save enabled → tap Save → returns to Home, SnackBar appears, entry added at top.
-   Add 3 entries → list scrolls; newest first.
-   Rotate device / hot reload → entries remain during session (no persistence yet).

Notes:

-   Theme uses project palette from `lib/theme.dart` and applies across the app.
-   Next iteration ideas (not implemented): persist entries (SharedPreferences/Hive), edit/delete entries, migrate to Provider/Riverpod, and extend the diary model.
-   The default Flutter starter `widget_test.dart` is not applicable to this UI; feel free to update or remove it in your local workflow.

## Firebase Setup (Android)

1. In Firebase Console, open project “Mindful Steps”. Add an Android app with package `com.example.lyforia`.
2. Download `google-services.json` and place it at `android/app/google-services.json`.
3. Generate config with FlutterFire CLI:
    - `flutter pub global activate flutterfire_cli`
    - `flutterfire configure --project "Mindful Steps" --android-package-name com.example.lyforia`
    - This creates `lib/firebase_options.dart` with real values (replace the placeholder file).
4. Ensure Gradle is set (already in repo): `com.google.gms.google-services` plugin is applied and BOM included.
5. Run: `flutter pub get` then `flutter run`.

Verification:

-   On launch, no Firebase initialization errors in the console.
-   Adding entries under “Eating” creates documents in collection `binge_entries` with fields: `date`, `dateTime`, `createdAt`, `place`, `v`, `l`, `starred`, `food`, `comments`, `time`.
-   Analytics tab renders counts without errors.

### Firestore Database Target

-   FlutterFire currently targets your project’s default Firestore database.
-   If you created an additional database (e.g., `lyforia-storage`), the Flutter SDK does not expose selecting a non-default database at this time. Use the default database, or access the secondary DB via REST/Cloud Functions.

## Authentication (Email/Password)

-   Enable Email/Password provider in Firebase Console → Authentication → Sign-in method.
-   From Settings → Account: enter email/password to Create Account or Sign In, or Sign Out if already signed in.
-   Common issues:
    -   “We have blocked all requests from this device due to unusual activity” → wait and retry; ensure device has network.
    -   “operation-not-allowed” → enable the Email/Password provider in the Console.

## Google Sign-In

-   Enable Google provider in Firebase Console → Authentication → Sign-in method.
-   Android: Add your app’s SHA-1 and SHA-256 to Firebase Project Settings → Android app → Add fingerprint.
    -   Get debug SHA-1 quickly: `./gradlew signingReport` in `android/` or use Android Studio Gradle panel.
    -   Download the updated `google-services.json` and place it at `android/app/google-services.json`.
-   Usage: Settings → Account → “Continue with Google”.
-   Troubleshooting:
    -   If sign-in fails with “DEVELOPER_ERROR” or “Invalid SHA-1”, re-check fingerprints and re-download `google-services.json`.
    -   If multiple Google accounts are on device, you may be prompted to choose one.

.

..

🚀 Getting Started Steps

1. Find the TODO(human) in lib/pages/check_in_page.dart:79
2. Study \_buildRecentList() to understand the data fetching pattern
3. Replace the placeholder Container with your chart implementation
4. Test with flutter run and add some mood entries to see your chart!

Try implementing this step by step - start with just displaying static bars, then connect to
real data. This hands-on approach will solidify your understanding of Flutter's reactive UI
patterns!
