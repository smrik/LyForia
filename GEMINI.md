# Gemini Project: LyForia

## Project Overview

This is a Flutter project named LyForia. The goal of the project is to create a health and wellness application. The user has provided a screenshot of a previous Firestore database, and the data structure from that database will be used in this project.

## Current State

The project is in the early stages of development. The basic file structure has been created, and some UI pages are present. However, the application is not currently runnable due to configuration issues.

### Key Issues:

1.  **Firebase Configuration:** The project is not correctly configured to connect to Firebase. The application is throwing a `PlatformException` because it cannot load `FirebaseOptions`. This needs to be resolved by correctly setting up the Firebase project and adding the necessary configuration files (e.g., `google-services.json` for Android).
2.  **Android `minSdkVersion`:** The `cloud_firestore` plugin requires an Android `minSdkVersion` of 23, but the project is currently set to 21. This is causing a build failure. The `minSdkVersion` needs to be updated in the `android/app/build.gradle` file.
3.  **Dart Analysis Issues:** There are several "uri_does_not_exist" and "undefined\_name" errors in the Dart files. These are likely due to missing dependencies or incorrect imports, which should be resolved after fixing the main configuration issues.

### Database Schema (from screenshot)

The Firestore database has the following collections and fields:

-   **`bingeLogs`**:
    -   `context`: String
    -   `date`: String
    -   `foodAndDrink`: String
    -   `id`: String
    -   `place`: String
    -   `star`: Boolean
    -   `time`: String
    -   `vOrL`: Boolean
-   **`bingeWeighIns`**: (Structure not fully visible, but likely contains weigh-in data related to binges)
-   **`tasks`**: (Structure not visible)
-   **`weighIns`**: (Structure not visible)

## Next Steps

1.  **Fix Firebase Configuration:**
    -   Ensure a Firebase project is created.
    -   Add the `google-services.json` file for Android.
    -   Configure the iOS project with the `GoogleService-Info.plist` file.
    -   Initialize Firebase correctly in `lib/main.dart`.
2.  **Update Android `minSdkVersion`:**
    -   Change `minSdkVersion` to 23 in `android/app/build.gradle`.
3.  **Resolve Dart Analysis Issues:**
    -   Run `flutter pub get` to ensure all dependencies are fetched.
    -   Fix any remaining import or type errors in the Dart code.
4.  **Implement Data Models:**
    -   Create Dart classes that correspond to the Firestore data structures.
5.  **Build UI:**
    -   Continue building the UI pages to display and interact with the Firestore data.
