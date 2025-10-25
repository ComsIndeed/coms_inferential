# Coms Inferential

A desktop overlay Flutter application that provides a hotkey-activated AI chat
interface with beautiful acrylic blur effects.

## Overview

Coms Inferential is a Windows desktop application that creates a transparent,
overlay window similar to Raycast or Spotlight. Press `Ctrl+Shift+Space`
globally to instantly summon an AI assistant chat interface that appears over
your current work.

### Key Features

- 🎯 **Global Hotkey Access** - Summon the AI assistant from anywhere with
  `Ctrl+Shift+Space`
- 💬 **AI Chat Interface** - Powered by Google Gemini AI models
- ✨ **Acrylic Blur Effects** - Beautiful transparent window with native Windows
  blur
- 💾 **Chat History** - Persistent storage of all conversations with SQLite
- 🤖 **Multiple AI Models** - Switch between different Gemini models
  mid-conversation
- ✏️ **Message Editing** - Edit previous messages and regenerate responses
- 🔄 **Response Regeneration** - Re-roll AI responses if you're not satisfied

## Platform Support

- ✅ **Windows** - Primary target with full feature support
- 🔧 **Android & Web** - Compilable but not optimized (future expansion)
- ⚠️ **macOS/Linux** - Basic compatibility exists but not prioritized

## Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Windows 10/11 (for desktop features)
- Google Gemini API key

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ComsIndeed/coms_inferential.git
cd coms_inferential
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up API Key

You need a Google Gemini API key to use the AI features. Get one from
[Google AI Studio](https://makersuite.google.com/app/apikey).

Run the application with your API key:

```bash
flutter run -d windows --dart-define=GEMINI_API_KEY=your_api_key_here
```

### 4. Build for Release

```bash
flutter build windows --dart-define=GEMINI_API_KEY=your_api_key_here
```

## Usage

### Basic Operation

1. **Launch** - Start the application (window will be hidden by default)
2. **Activate** - Press `Ctrl+Shift+Space` to show the overlay
3. **Chat** - Type your message and press Enter
4. **Dismiss** - Press `Ctrl+Shift+Space` again or click outside

### Keyboard Shortcuts

| Shortcut           | Action                   |
| ------------------ | ------------------------ |
| `Ctrl+Shift+Space` | Toggle window visibility |
| `Enter`            | Send message             |
| `Shift+Enter`      | New line in message      |

### Chat Features

- **Start New Chat** - Click the new chat button or start typing
- **Load History** - Access previous conversations from the sidebar
- **Edit Messages** - Click edit on any message to modify and regenerate
- **Change Models** - Switch between AI models in chat settings
- **Regenerate** - Re-roll the last AI response for different results

## Architecture

### State Management

The application uses **BLoC (Business Logic Component)** pattern for state
management:

- `ChatSessionBloc` - Manages active chat sessions
- `ChatHistoryBloc` - Manages chat history list
- `WindowBloc` - Controls window visibility and animations
- `SettingsBloc` - Handles settings overlay

### Services

- `GeminiService` - Integrates with Google Gemini AI API
- `ChatHistoryService` - Handles chat persistence operations
- `DatabaseHelper` - SQLite database management

### Data Persistence

- **Database**: SQLite via `sqflite` package
- **Location**: Application support directory
- **Schema**: Chats and messages tables with foreign key relationships

## Project Structure

```
lib/
├── main.dart                 # App entry point, window initialization
├── blocs/                    # BLoC state management
│   ├── chat_history_bloc/
│   ├── chat_session_bloc/
│   ├── settings_bloc/
│   └── window_bloc/
├── models/                   # Data models
│   ├── chat_history.dart
│   └── chat_message.dart
├── pages/                    # Page-level UI components
│   ├── homepage/
│   └── settings/
├── services/                 # Business logic services
│   ├── gemini_service.dart
│   ├── chat_history_service.dart
│   └── database_helper.dart
├── utilities/                # Helper functions and extensions
└── widgets/                  # Reusable UI components
```

## Documentation

- [API Documentation](API_DOCUMENTATION.md) - Complete API reference for BLoCs
  and services
- [Project Instructions](.github/copilot-instructions.md) - Detailed development
  guide

## Dependencies

### Core Dependencies

- `flutter_bloc` - State management
- `google_generative_ai` - AI integration (custom fork)
- `sqflite` - Local database
- `window_manager` - Desktop window control
- `flutter_acrylic` - Window blur effects
- `hotkey_manager` - Global keyboard shortcuts

See [pubspec.yaml](pubspec.yaml) for complete list.

## Development

### Running in Development

```bash
# Windows desktop (primary platform)
flutter run -d windows --dart-define=GEMINI_API_KEY=your_key

# Web (for testing)
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key

# Android (requires emulator/device)
flutter run -d android --dart-define=GEMINI_API_KEY=your_key
```

### Code Style

The project follows Flutter linting standards:

- Uses `flutter_lints` package
- Prefers `const` constructors
- Follows standard Dart naming conventions

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development Guidelines

1. Follow the existing code structure and patterns
2. Use BLoC for state management
3. Add tests for new features
4. Update documentation as needed
5. Ensure Windows desktop functionality works

## License

This project is licensed under the MIT License - see the LICENSE file for
details.

## Acknowledgments

- Google Gemini AI for powering the chat functionality
- Flutter team for the amazing framework
- Community packages that make desktop development possible

## Support

For issues, questions, or suggestions:

- Create an issue on
  [GitHub](https://github.com/ComsIndeed/coms_inferential/issues)
- Check the [API Documentation](API_DOCUMENTATION.md) for technical details

---

**Made with ❤️ using Flutter**
