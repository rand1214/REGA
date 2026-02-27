# REGA - Kurdish Quiz Application

A Flutter-based quiz application designed for Kurdish learners with computer practice modules, interactive quizzes, and a comprehensive learning system.

## Overview

REGA is an educational app that helps users learn through interactive quizzes and computer practice exercises. The app features a clean, responsive UI optimized for both Android and iOS devices, with full support for Kurdish language (Sorani script) and right-to-left (RTL) text layout.

## Features

### 1. Home Screen
- Welcome banner with animated notification bell (Lottie animation)
- Responsive description container with auto-sizing text
- Navigation to different learning modules
- Bottom navigation bar for quick access to main sections

### 2. Quiz System
- Chapter-based quiz organization
- Multiple choice questions (A, B, C options)
- Visual question grid with images
- Timer functionality for timed quizzes
- Progress tracking
- Emoji feedback screen after quiz completion
- Responsive layout that prevents UI overlap on all screen sizes

### 3. Computer Practice Module
- Interactive splash screen with device rotation animation
- Code entry system with custom numpad
- Username entry with custom keyboard
- 50/50 split screen layout (question/answer)
- 60-second timer per question
- Keyboard-aware layout that adapts to device safe areas
- Optimized for iPhone home indicator and notch

### 4. Book/Reading Section
- Educational content display
- Chapter navigation
- Reading materials

### 5. Profile Section
- User information
- Settings and preferences

## Technical Architecture

### Project Structure
```
lib/
├── core/
│   ├── router/          # App routing (go_router)
│   └── theme/           # App theme and styling
├── features/
│   ├── auth/            # Authentication
│   ├── book/            # Reading materials
│   ├── computer_practice/
│   │   └── presentation/
│   │       ├── computer_practice_screen.dart
│   │       └── screens/
│   │           └── computer_practice_splash_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   │           ├── bottom_nav_bar.dart
│   │           ├── circle_navigator.dart
│   │           ├── description_container.dart
│   │           ├── home_content.dart
│   │           └── top_bar.dart
│   ├── onboarding/      # First-time user experience
│   ├── profile/         # User profile
│   ├── quiz/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── quiz_home_screen.dart
│   │       │   └── quiz_screen.dart
│   │       └── widgets/
│   │           ├── chapter_selection_dialog.dart
│   │           └── computer_practice_widget.dart
│   ├── splash/          # App splash screen
│   └── welcome/         # Welcome screens
└── main.dart
```

### Key Dependencies
- `flutter_screenutil: ^5.9.3` - Responsive UI sizing
- `go_router: ^14.6.2` - Navigation and routing
- `lottie: ^3.1.3` - Animated icons and graphics
- `flutter_svg: ^2.0.16` - SVG image support
- `google_fonts: ^6.2.1` - Custom fonts

### Custom Fonts
- **Prototype** - Used for specific UI elements
- **PeshangDes** - Primary font for Kurdish text (Sorani script)

## UI/UX Features

### Responsive Design
- Adapts to different screen sizes (iPhone SE to iPhone 14 Pro Max)
- Uses MediaQuery for dynamic sizing
- Flexible layouts with proper constraints
- Safe area handling for notched devices

### Kurdish Language Support
- Full RTL (Right-to-Left) text support
- Kurdish digits (٠-٩) throughout the app
- Custom Kurdish fonts (PeshangDes)
- Proper text alignment and direction

### Accessibility
- High contrast text
- Clear visual hierarchy
- Touch-friendly button sizes
- Keyboard-aware layouts

## Recent Bug Fixes

### iPhone UI Optimizations
1. **Question Grid Overlap** - Fixed using strict Column layout with Flexible widgets
2. **Numpad Coverage** - Implemented keyboard-aware layout with MediaQuery.viewInsets
3. **Chapter Title Truncation** - Adjusted aspect ratios and font sizes
4. **Banner Text Truncation** - Added responsive font sizing with clamp

### Animation Improvements
- Replaced GIF notification bell with Lottie animation
- Smooth swing animation on tap (frames 27-74)
- Proper resting position (frame 90)

### Layout Enhancements
- Fixed numpad button responsiveness (fixed width, responsive height)
- Proper spacing around device safe areas (5px bottom padding)
- Grid layout using GridView.builder inside Expanded
- No Stack/Positioned widgets to prevent overlap

## How It Works

### App Flow
1. **Splash Screen** → Initial app loading
2. **Welcome/Onboarding** → First-time user introduction
3. **Home Screen** → Main dashboard with navigation
4. **Quiz Selection** → Choose chapter and start quiz
5. **Computer Practice** → Interactive practice with custom numpad
6. **Results** → Emoji feedback and score display

### Computer Practice Flow
1. User taps "Computer Practice" widget
2. Splash screen shows device rotation animation (5 seconds)
3. Code entry screen with custom numpad
4. Username entry screen
5. Quiz questions with 50/50 split layout
6. Timer counts down from 60 seconds
7. Results displayed after completion

### Quiz Flow
1. User selects chapter from grid
2. Quiz screen loads with 3 questions
3. User answers using A/B/C buttons
4. Progress tracked through questions
5. Emoji feedback screen shows results

## Configuration

### Screen Orientation
- Locked to portrait mode only (`DeviceOrientation.portraitUp`)

### Design Size
- Base design: 375x812 (iPhone X/11 Pro dimensions)
- Scales responsively to other screen sizes

### Color Scheme
- Background: `#F1F1F1` (light grey)
- Primary: Black
- Accent: Various greys and whites

## Building the App

### Android
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
Note: iOS builds require macOS with Xcode installed

## Development Notes

### Important File Locations
- Computer practice screen: `lib/features/computer_practice/presentation/computer_practice_screen.dart`
- NOT in screens subfolder (common mistake)

### Import Paths
- Use relative imports within features
- Example: `import '../computer_practice_screen.dart';`

### Layout Guidelines
- Use Column with Expanded for vertical layouts
- Avoid Stack/Positioned for main layouts (causes overlap)
- Use GridView.builder with NeverScrollableScrollPhysics inside Expanded
- Always consider safe areas (MediaQuery.padding)

## Testing

The app has been tested on:
- iPhone SE (small screen)
- iPhone 14 Pro (standard screen with notch)
- iPhone 14 Pro Max (large screen with notch)
- Android devices (various sizes)

## Future Enhancements

- User authentication system
- Progress tracking and analytics
- More quiz chapters
- Offline mode support
- Sound effects and haptic feedback
- Leaderboard system
- Social sharing features

## Documentation

See `UI_FIXES_DOCUMENTATION.md` for detailed information about iPhone UI bug fixes and solutions.

## License

Copyright © 2024 REGA. All rights reserved.

## Version

Current version: 1.0.0+1
