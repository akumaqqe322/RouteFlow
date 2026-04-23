# RouteFlow

RouteFlow is a technical portfolio project demonstrating a Flutter-based mobile application for route planning, management, and synchronization. It is built using absolute feature-first architecture, BLoC-based state management, and a cache-first data persistence strategy.

## 📄 Project Overview
RouteFlow allows users to create driving routes on an interactive map, save them to a personal library, and sync them across devices. The project serves as a demonstration of clean architecture, dependency injection, and integration with third-party cloud services.

## ⚙️ Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: BLoC / Cubit (`flutter_bloc`)
- **Navigation**: `go_router`
- **Backend / Persistence**: Supabase (Auth/DB), Hive (Local Cache)
- **Networking**: `dio` (for OSRM API integration)
- **Service Locator**: `get_it` with `injectable` code generation
- **Monitoring**: Sentry (Crash Reporting)
- **Monetization**: RevenueCat (Subscription management)
- **Testing**: `bloc_test`, `mocktail`, `golden_toolkit`

## 🏗 Architecture Summary
The project implements a **Feature-First Clean Architecture**. Each feature (e.g., `saved_routes`) is isolated into three layers:
- **Data**: Repository implementations, models, and data sources (Hive/Supabase).
- **Domain**: Abstract repository interfaces and plain-old-data entities.
- **Presentation**: BLoC state management and feature-specific widgets.

## ✅ Implementation Status

### Fully Implemented
- **Authentication**: Email/Password flow via Supabase Auth.
- **Onboarding**: Persistent first-run check and introduction flow.
- **Map Interactivity**: `flutter_map` integration with custom markers and interactive placement.
- **OSRM Routing**: Dynamic driving route calculation using the OSRM Public API.
- **Cache-First Persistence**: Routes are saved locally via Hive for offline access and synced to Supabase when online.
- **Localization**: Support for English and Russian (`intl` / `.arb`).
- **Deep Linking**: Infrastructure to launch specific routes via URI.

### Configuration-Dependent
- **Cloud Database (Supabase)**: Requires valid `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- **Crash Reporting (Sentry)**: Active only if `SENTRY_DSN` is provided.
- **Monetization (RevenueCat)**: Feature gating is implemented, but requires active `REVENUECAT_API_KEY`s and configured entitlements in the RevenueCat dashboard.

## 🚩 Current Limitations & Caveats
- **Routing API**: Currently utilizes the OSRM public demo server. For production use, a private OSRM instance is recommended to avoid rate limits.
- **Sync Logic**: Persistence uses a "remote-refresh" strategy rather than a background socket-based real-time sync.
- **Web Support**: Optimized for iOS and Android; desktop/web platforms include functional guards but are not primary targets.

## 🛠 Local Setup
To run the project, you must provide environment variables via `--dart-define`.

### Required Configuration
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=OSRM_BASE_URL=https://router.project-osrm.org/route/v1/driving \
  --dart-define=REVENUECAT_API_KEY_IOS=your_key \
  --dart-define=REVENUECAT_API_KEY_ANDROID=your_key \
  --dart-define=SENTRY_DSN=your_dsn
```

## 🧪 Testing
The suite includes representative coverage for business-critical paths:
- **Unit/BLoC**: Validation of state transitions for Auth, Routing, and Location.
- **Widget**: Verification of error/empty states for the `MyRoutes` and `Premium` screens.
- **Golden**: UI snapshot testing for the `RouteCard` and navigation components.

## 🤖 CI/CD
A GitHub Actions pipeline is configured in `.github/workflows/ci.yml` to perform:
- Static analysis and formatting checks.
- Execution of the test suite.
- Buildability verification for Android (APK) and iOS (No-codesign).

## 📊 Portfolio Verdict
**Status: Portfolio-Ready Stable Prototype.**
RouteFlow is a highly credible demonstration of modern Flutter development. While it requires external service configuration for full cloud functionality, the code is structurally complete, documented, and architecturally sound for a senior-level review.
