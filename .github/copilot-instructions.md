<!-- Auto-generated guidance for AI code assistants working on this repo. -->
# Copilot / AI Agent Instructions for tbcare_main

Goal: Help a developer-focused AI be immediately productive by documenting this repository's architecture, developer flows, and project-specific conventions.

1) Big-picture architecture
- **Monorepo app:** Flutter app with platform folders (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`) and core UI in `lib/`.
- **Entry point:** `lib/main.dart` initializes Firebase and calls `TBCareApp` from `lib/app.dart`.
- **Routing / navigation:** All named routes and transitions are centralized in `lib/routes/app_routes.dart`. Route names are defined in `lib/core/app_constants.dart` (see `AppConstants`).
- **State management:** Lightweight `provider` usage — `AuthStateProvider` is declared in `lib/app.dart`. Expect more `ChangeNotifier` providers across features.
- **Feature structure:** Features live under `lib/features/` grouped by domain (e.g., `chw`, `doctor`, `auth`, `landing`, `patient`). Follow the existing pattern when adding new features (screens, viewmodels, services under the same folder).

2) Key integration points
- **Firebase:** Project uses `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`. Generated options exist at `lib/firebase_options.dart`. Note: `main.dart` contains inline web options for Firebase (check before changing) — prefer `DefaultFirebaseOptions.currentPlatform` when modifying initialization.
- **Platform files:** Android `google-services.json` is in `android/app/`; iOS config and AppDelegate are under `ios/Runner/`.
- **Third-party services:** Google sign-in (`google_sign_in`), geolocation (`geolocator`, `geocoding`), recording (`record`), file/image handling (`image_picker`, `path_provider`, `permission_handler`). Changes to these require attention to platform permissions/config (AndroidManifest, Info.plist, capability declarations).

3) Project-specific conventions & patterns
- **Centralized constants & theme:** `lib/core/app_constants.dart` holds routes, colors, breakpoints, and `AppTheme`. Use these constants for colors, route names, and spacing to remain consistent.
- **Navigation:** Always use route names from `AppConstants` + `AppRoutes.generateRoute` patterns. For new routes: add constant in `AppConstants` and case in `AppRoutes.generateRoute`.
- **Platform checks:** The code uses `kIsWeb` and `universal_platform` to branch behavior between web vs mobile/desktop — preserve these checks for cross-platform logic.
- **Assets:** Assets are declared in `pubspec.yaml` (`assets/`, `assets/images/`, `assets/icons/`). Use `AssetPaths` in `app_constants.dart`.

4) Build / run / test workflows (PowerShell on Windows)
- Install deps: `flutter pub get`
- Run on web (Chrome): `flutter run -d chrome`
- Run on Windows: `flutter run -d windows`
- Run on Android emulator/device: `flutter run -d <deviceId>` or `flutter run` (with device attached)
- Build release: `flutter build apk` / `flutter build appbundle` (Android), `flutter build ios` (macOS required), `flutter build web`
- Tests: `flutter test` (there's `test/widget_test.dart`).

5) Code change guidance & safe-edit notes
- **Firebase keys:** `lib/firebase_options.dart` and `main.dart` include Firebase config. Avoid removing platform config; if you update Firebase, prefer using the FlutterFire CLI to regenerate `firebase_options.dart`.
- **Routes & feature additions:** Add route constant to `AppConstants`, then update `AppRoutes.generateRoute` for proper transition type. Example: to add `/my_feature`, add constant in `AppConstants` and a `case` in `AppRoutes.generateRoute` returning the new screen widget.
- **State providers:** Keep providers at `MultiProvider` in `lib/app.dart` for global state. For feature-level providers, create local `ChangeNotifierProvider` around the feature's root widget.

6) Files to inspect for patterns/examples
- Routing and transitions: `lib/routes/app_routes.dart`
- App-level state & theme: `lib/app.dart`, `lib/core/app_constants.dart`
- Firebase setup: `lib/firebase_options.dart`, `lib/main.dart`
- Feature layout examples: `lib/features/chw/`, `lib/features/doctor/`, `lib/features/auth/`

7) Quick search queries (useful when browsing)
- Routes: search `AppConstants.` or `AppRoutes.generateRoute`
- Firebase usage: search `Firebase.initializeApp` / `DefaultFirebaseOptions`
- Provider/state: search `ChangeNotifierProvider` / `Provider.of<` / `context.watch`

8) Security & sensitive-data notes
- The repo currently contains Firebase API keys (client-side keys). These are public-facing in standard Firebase web configs; do not attempt to move them to server secrets unless you understand the security model. Do NOT commit server private keys into this repo.

If anything in this file is unclear or you want additional examples (e.g., a sample patch that adds a new route + screen), tell me which area to expand and I will iterate.
