# Coms Inferential - AI Agent Instructions

## Project Overview
This is a **desktop overlay Flutter application** that creates a hotkey-activated, transparent window with acrylic blur effects. The app serves as a **chat interface for an AI assistant** (similar to Raycast/Spotlight) that can be toggled globally with `Ctrl+Shift+Space`.

### Platform Strategy
- **Primary target**: Windows desktop
- **Future platforms**: Android and Web (will be compilable but not optimized with responsive layouts initially)
- macOS/Linux compatibility exists but is not a priority

## Core Architecture

### Window & Lifecycle Management
- **Entry point**: `lib/main.dart` initializes multiple critical systems in sequence
- **Initialization order matters**: Must call in this exact order:
  1. `WidgetsFlutterBinding.ensureInitialized()`
  2. `hotKeyManager.unregisterAll()` (cleanup from previous sessions)
  3. `windowManager.ensureInitialized()`
  4. `Window.initialize()` (flutter_acrylic)
  
- **Window configuration** (`main.dart`):
  - Starts hidden with `opacity: 0.0` to prevent flash on startup
  - Uses `skipTaskbar: true`, `titleBarStyle: TitleBarStyle.hidden`, `fullScreen: true`
  - Applies acrylic blur effect after window is ready via `Window.setEffect(effect: WindowEffect.acrylic)`

### Hotkey & Toggle System
- **Global hotkey**: `Ctrl+Shift+Space` (registered in `_MainAppState._registerHotKey()`)
- **Toggle animation**: 50ms AnimationController drives window opacity fade in/out
- **Window state**: Tracked via `_isWindowVisible` boolean
- The animation controller's value is clamped and multiplied by 10 in `homepage.dart` for fade effect: `clampDouble(controller.value * 10, 0, 1)`

### UI Structure
```
MainApp (StatefulWidget)
├── AnimationController (manages fade in/out)
├── MaterialApp
│   └── Homepage (receives controller)
│       └── AnimatedOpacity (fade wrapper)
│           └── InputContainer (main search UI)
```

## Project Structure

### Directory Organization
- `lib/main.dart` - App initialization, window/hotkey management, root widget
- `lib/pages/homepage/` - Page-level components
  - `homepage.dart` - Top-level page with opacity animation
  - `input_container.dart` - Search input UI with acrylic container
- `lib/providers/` - Currently empty (intended for state management)

### Dependencies
Key packages with specific purposes:
- `flutter_acrylic` - Native window blur/transparency effects (Windows desktop)
- `window_manager` - Desktop window control (show/hide/opacity/position)
- `hotkey_manager` - Global system hotkeys (desktop)
- `provider` - State management (installed but unused)
- `flutter_animate` - Animation utilities (installed but unused)

**Upcoming dependencies**:
- **BLoC** (flutter_bloc) - Will replace local state management for complex features
- **google_generative_ai** - Custom fork maintained by project owner (replaces deprecated official package)
- Additional AI/chat-related packages as features expand

### State Management Architecture
- **Current**: Local state in `_MainAppState` and component-level state
- **Planned**: BLoC pattern for feature development
  - Window visibility/animation may remain local state
  - Chat, AI interactions, and complex features will use BLoC
- `lib/providers/` directory is reserved for future BLoC implementation

## Development Patterns

### Theming
- Uses `ThemeData.dark()` with transparent scaffold background
- Colors reference theme: `Theme.of(context).cardColor`, `Theme.of(context).colorScheme.onPrimaryContainer`
- Semi-transparent containers use `.withAlpha(160)` for layered glass effect

### Widget Conventions
- Stateless widgets for presentational components (`Homepage`)
- Stateful widgets when managing local state (`InputContainer`, `MainApp`)
- Use `const` constructors wherever possible
- Animation controllers use `SingleTickerProviderStateMixin`

### File Naming
- Feature-based directories: `pages/homepage/`
- Component files named after their main widget class in snake_case: `input_container.dart` contains `InputContainer`
- One widget class per file (except private state classes like `_InputContainerState`)

## Common Development Tasks

### Running the Application
```bash
# Primary development platform
flutter run -d windows

# Future platforms (compilable but not optimized)
flutter run -d chrome      # Web
flutter run -d android     # Android (requires emulator/device)
```

**Note**: This is primarily a **Windows desktop app**. Android and Web compilation support exists for future expansion, but features are Windows-optimized. Desktop-specific packages (`flutter_acrylic`, `window_manager`, `hotkey_manager`) will not function on mobile/web.

### Testing Window Behavior
1. Launch app (window should be invisible initially)
2. Press `Ctrl+Shift+Space` to show overlay
3. Press `Ctrl+Shift+Space` again to hide
4. Window should fade in/out smoothly (50ms duration)

### Modifying the Hotkey
Edit `lib/main.dart` in `_registerHotKey()`:
```dart
HotKey hotKey = HotKey(
  key: PhysicalKeyboardKey.space,  // Change key here
  modifiers: [HotKeyModifier.control, HotKeyModifier.shift],  // Modify modifiers
);
```

### Adding New Pages
1. Create folder in `lib/pages/[feature_name]/`
2. Add main page file: `[feature_name].dart`
3. Add component files as needed in same folder
4. Import in `main.dart` if it's a root-level route

## Critical Implementation Details

### Opacity Animation Pattern
The app uses a **dual-layer opacity system**:
1. `windowManager.setOpacity()` - Native window opacity (0.0 to 1.0)
2. `AnimatedOpacity` in `Homepage` - Widget-level fade with value clamped and scaled

When toggling visibility, both layers animate together for smooth appearance.

### Transparent Window Requirements
- Scaffold must use `Colors.transparent` as background
- Acrylic effect is applied at native window level (not Flutter widget)
- Order matters: set window opacity to 0 before applying effects to prevent visual glitches

## Build & Distribution
- Primary build target: `flutter build windows`
- Future platforms: `flutter build web` and `flutter build apk/appbundle` (Android)
- Platform-specific build files are in respective folders (`windows/`, `android/`, `web/`)
- macOS/Linux builds exist but are not maintained for production

## Linting
- Uses `flutter_lints` package with standard rules
- Config: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`
- Prefers const constructors, proper key usage, and standard Flutter patterns
