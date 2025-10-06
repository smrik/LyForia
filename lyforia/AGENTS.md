# Repository Guidelines

## Project Structure & Module Organization
- `lib/`: Dart sources. Entry: `lib/main.dart`; themes in `lib/theme.dart`, state in `lib/theme_provider.dart`, feature screens in `lib/pages/`.
- `test/`: Widget/unit tests (e.g., `test/widget_test.dart`).
- Platforms: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`.
- Tooling: Dart/Flutter via `pubspec.yaml`; lint rules in `analysis_options.yaml`.

## Build, Test, and Development Commands
- Run app (hot reload): `flutter run -d <device>`.
- Analyze code: `flutter analyze`.
- Format code: `dart format .` (CI-friendly); fix lints: `dart fix --apply`.
- Run tests: `flutter test` (coverage: `flutter test --coverage`).
- Build Android: `flutter build apk` or `flutter build appbundle`.
- Build iOS/macOS: `flutter build ios` / `flutter build macos` (Xcode setup required).

## Coding Style & Naming Conventions
- Indentation: 2 spaces; no tabs.
- Files: `snake_case.dart` (e.g., `binge_eating_log_page.dart`).
- Types/Widgets: `PascalCase` (suffix `Page`, `Widget`, `Provider`).
- Variables/fields: `lowerCamelCase`; constants: `lowerCamelCase` with `const`.
- Linting: `flutter_lints` with overrides in `analysis_options.yaml` (prints allowed; `use_key_in_widget_constructors` relaxed). Keep changes consistent with current rules.

## Testing Guidelines
- Framework: `flutter_test`.
- Place tests under `test/`, mirroring `lib/` paths; name with `_test.dart`.
- Prefer widget tests for pages in `lib/pages/`; use `WidgetTester`.
- Run locally: `flutter test`; aim to cover rendering, interactions, and basic state.

## Commit & Pull Request Guidelines
- History shows no strict convention; use Conventional Commits (e.g., `feat: add mood tracker chart`).
- Branches: `feature/<short-name>`, `fix/<short-name>`.
- PRs: clear description, linked issue (if any), screenshots for UI, and notes on testing. Keep diffs focused and pass `flutter analyze` and tests.

## Security & Configuration Tips
- Firebase: initialized in `main.dart`. Manage platform configs via FlutterFire and platform-specific files; do not commit secrets.
- Avoid storing sensitive data in source; prefer secure platform storage. Review logs before sharing builds.

## Current Progress
- Analytics page now visualizes binge entry trends (weekly line, hourly histogram) and mood averages over the last 30 days with an inline average mood indicator.
- Admin backfill flow reuses a cached `ScaffoldMessenger` to address context-after-await linting.
- Latest `flutter analyze` run reports only pre-existing warnings in `lib/main.dart`, `lib/pages/habit_tracker_page.dart`, `lib/pages/mood_tracker_page.dart`, `lib/pages/to_do_list_page.dart`, and `test/widget_test.dart`; no new errors introduced.
