# RouteFlow

RouteFlow is a portfolio-grade, production-minded Flutter mobile application designed for route building, saving, and discovery. It features a clean architecture, robust state management, offline-first persistence, and real-time synchronization.

## 🚀 Key Features

- **Onboarding Flow**: Smooth user introduction and session initialization.
- **Authentication**: Secure email/password login integrated with Supabase Auth.
- **Interactive Map**: Built with `flutter_map` and OpenStreetMap tiles.
- **Route Building**: Real-time driving routes using the OSRM (Open Source Routing Machine) API.
- **Saved Routes**: Personal library of routes with Hive-based local caching and Supabase synchronization.
- **Favorites**: Toggle favorite status for quick access to preferred routes.
- **Premium Features**: Subscription gating using RevenueCat (gated route saving).
- **Deep Linking**: Support for opening specific routes via shared links.
- **Crash Reporting**: Integrated Sentry monitoring for runtime error tracking.
- **Localization**: Full support for English and Russian.

## 🏗 Architecture & Tech Stack

The project follows a **Feature-First Clean Architecture** with distinct layers for Data, Domain, and Presentation within each feature module.

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLoC/Cubit)
- **Navigation**: [go_router](https://pub.dev/packages/go_router)
- **Backend / Database**: [Supabase](https://supabase.com)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) & [SharedPreferences](https://pub.dev/packages/shared_preferences)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it) & [injectable](https://pub.dev/packages/injectable)
- **Monetization**: [Purchases (RevenueCat)](https://pub.dev/packages/purchases_flutter)
- **Error Monitoring**: [Sentry](https://sentry.io)
- **Testing**: `bloc_test`, `mocktail`, `golden_toolkit`

## 🛠 Setup & Configuration

This project uses `--dart-define` for environment configuration. 

### Prerequisites

You must provide the following configuration values:

```bash
--dart-define=SUPABASE_URL=YOUR_URL
--dart-define=SUPABASE_ANON_KEY=YOUR_KEY
--dart-define=REVENUECAT_API_KEY_IOS=YOUR_KEY
--dart-define=REVENUECAT_API_KEY_ANDROID=YOUR_KEY
--dart-define=SENTRY_DSN=YOUR_DSN
```

### Running the Project

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://abc.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=OSRM_BASE_URL=https://router.project-osrm.org/route/v1/driving
```

## 🧪 Testing

The project includes a representative test suite covering critical logic and UI:

```bash
# Run unit and bloc tests
flutter test

# Run golden tests (requires specific rendering configuration)
flutter test --update-goldens
```

## 📊 Portfolio Status: Portfolio-Ready

RouteFlow is considered **Portfolio-Ready** with the following notes:

1. **Fully Implemented**: Auth, Map, Routing, Saving/Syncing, Localization, CI/CD Pipeline.
2. **Configuration-Dependent**: RevenueCat and Sentry require active API keys to function; otherwise, they fail gracefully (monitored in logs).
3. **Third-Party APIs**: Uses the OSRM public demo server. For high-traffic use, a private OSRM instance should be deployed.
4. **Platform Support**: Optimized for iOS and Android. Desktop support includes basic guards to prevent crashes from mobile-only plugins.

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
