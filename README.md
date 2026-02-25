# REGA - Quiz App

A production-ready Flutter quiz application with paid subscriptions.

## Features

- Clean Architecture with feature-based structure
- Material 3 design
- GoRouter navigation
- Responsive UI with flutter_screenutil
- Custom theme and typography
- Onboarding flow
- Authentication UI (bottom sheet)
- Quiz interface
- Home screen with categories

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── widgets/
│   └── utils/
├── features/
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   └── quiz/
│       └── presentation/
│           ├── screens/
│           └── widgets/
└── main.dart
```

## Platform Support

- iOS (minimum version 13.0)
- Android (minimum SDK 23)

## Dependencies

- go_router: Navigation
- flutter_screenutil: Responsive UI
- google_fonts: Typography
- flutter_svg: SVG support

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Configuration

- Application ID: com.rega.app
- Android minSdk: 23
- iOS minimum version: 13.0

## Routes

- `/` - Onboarding Screen
- `/home` - Home Screen
- `/quiz` - Quiz Screen
- Login Bottom Sheet (modal)

## Next Steps

- Implement backend integration
- Add authentication logic
- Connect to Supabase
- Implement quiz functionality
- Add payment integration
