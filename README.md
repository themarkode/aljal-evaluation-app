# AlJal Evaluation App

A comprehensive real estate evaluation application for **AlJal Real Estate Services (شركة الجال للخدمات العقارية)**.

Built with Flutter, this app allows real estate professionals to create detailed property evaluations and generate professional Word documents.

## Features

- 📝 **Multi-step evaluation forms** - 9 comprehensive steps covering all property aspects
- 📄 **Word document generation** - Auto-generate professional evaluation reports
- 🔥 **Firebase integration** - Secure cloud storage and real-time sync
- 🖼️ **Image management** - Capture and upload property photos with compression
- 📱 **Responsive design** - Works on mobile, tablet, and desktop
- 🌐 **RTL support** - Full Arabic language support
- 💾 **Auto-save** - Draft saving prevents data loss
- 🔐 **Authentication** - Secure login system

## Project Structure

```
lib/
├── core/                          # Core utilities and configurations
│   ├── config/                    # App credentials and environment config
│   ├── constants/                 # App constants and dropdown options
│   ├── routing/                   # Navigation and routing
│   ├── theme/                     # App colors, typography, spacing
│   └── utils/                     # Extensions, validators, formatters
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   └── pages_models/          # Step-specific models
│   └── services/                  # Firebase and business services
├── presentation/                  # UI layer
│   ├── providers/                 # Riverpod state management
│   ├── screens/                   # App screens
│   │   ├── auth/                  # Login and splash screens
│   │   ├── evaluation/            # Evaluation list and steps
│   │   └── statistics/            # Statistics screen
│   ├── shared/                    # Shared utilities
│   └── widgets/                   # Reusable widgets (Atomic Design)
│       ├── atoms/                 # Basic building blocks
│       ├── molecules/             # Combinations of atoms
│       ├── organisms/             # Complex UI sections
│       └── templates/             # Page templates
└── main.dart                      # App entry point

assets/
├── fonts/                         # Inter font family
├── images/                        # Logo and images
└── word_template/                 # Word document template
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase project configured

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd aljal-evaluation-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. **Configure credentials**
   - Copy `lib/core/config/app_credentials.template.dart` to `app_credentials.dart`
   - Update with your credentials

5. **Run the app**
   ```bash
   flutter run
   ```

## Evaluation Steps

1. **General Info** - Report metadata and client information
2. **Property Info** - Location, area, plot details
3. **Property Description** - Building type, age, features
4. **Floors** - Floor-by-floor breakdown
5. **Area Details** - Land and building areas
6. **Income Notes** - Financial information
7. **Site Plans** - Location and site plan images
8. **Property Images** - Property photographs
9. **Additional Data** - Final evaluation values

## Architecture

- **State Management**: Riverpod
- **Backend**: Firebase (Firestore + Storage)
- **Design Pattern**: Atomic Design for widgets
- **Navigation**: Named routes with arguments

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/validators_test.dart

# Run with coverage
flutter test --coverage
```

## Building

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests
4. Submit a pull request

## License

Proprietary - AlJal Real Estate Services © 2024

---

**Developed for شركة الجال للخدمات العقارية**
