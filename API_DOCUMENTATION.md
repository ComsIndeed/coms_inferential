# API Documentation - Blocs and Services

This document provides comprehensive API documentation for all BLoC state
managers and services in the Coms Inferential application.

---

## Table of Contents

- [BLoCs](#blocs)
  - [ChatHistoryBloc](#chathistorybloc)
  - [ChatSessionBloc](#chatsessionbloc)
  - [SettingsBloc](#settingsbloc)
  - [WindowBloc](#windowbloc)
- [Services](#services)
  - [GeminiService](#geminiservice)
  - [ChatHistoryService](#chathistoryservice)
  - [DatabaseHelper](#databasehelper)

---

## BLoCs

### ChatHistoryBloc

**Purpose**: Manages the list of all chat histories, including loading,
selection, deletion, and multi-select operations.

#### Dependencies

- `ChatHistoryService` - Required for database operations

#### Events

##### `LoadAllChats`

Loads all chat histories from the database.

```dart
context.read<ChatHistoryBloc>().add(const LoadAllChats());
```

**Parameters**: None\
**Result**: Emits `ChatHistoryLoaded` with list of chats or `ChatHistoryError`
on failure

---

##### `SelectChat`

Selects a specific chat by ID.

```dart
context.read<ChatHistoryBloc>().add(SelectChat(chatId));
```

**Parameters**:

- `chatId` (String) - The unique identifier of the chat to select

**Result**: Currently no-op (implementation incomplete)

---

##### `DeleteChatEvent`

Deletes a single chat from history.

```dart
context.read<ChatHistoryBloc>().add(DeleteChatEvent(chatId));
```

**Parameters**:

- `chatId` (String) - The unique identifier of the chat to delete

**Result**: Deletes chat and triggers `LoadAllChats` to refresh the list

---

##### `ClearAllChats`

Clears all chat history from the database.

```dart
context.read<ChatHistoryBloc>().add(const ClearAllChats());
```

**Parameters**: None\
**Result**: Emits `ChatHistoryLoaded` with empty list

---

##### `ToggleSelectionMode`

Toggles the selection mode UI for multi-select operations.

```dart
context.read<ChatHistoryBloc>().add(const ToggleSelectionMode());
```

**Parameters**: None\
**Result**: Toggles `isSelectionMode` flag and clears selected chat IDs

---

##### `ToggleChatSelection`

Toggles selection state of a specific chat in multi-select mode.

```dart
context.read<ChatHistoryBloc>().add(ToggleChatSelection(chatId));
```

**Parameters**:

- `chatId` (String) - The chat ID to toggle selection

**Result**: Adds or removes chat ID from `selectedChatIds` set

---

##### `DeleteSelectedChats`

Deletes all currently selected chats in multi-select mode.

```dart
context.read<ChatHistoryBloc>().add(const DeleteSelectedChats());
```

**Parameters**: None\
**Result**: Deletes all selected chats, exits selection mode, and refreshes list

---

##### `ClearSelection`

Clears the current selection and exits selection mode.

```dart
context.read<ChatHistoryBloc>().add(const ClearSelection());
```

**Parameters**: None\
**Result**: Clears `selectedChatIds` and sets `isSelectionMode` to false

---

#### States

##### `ChatHistoryInitial`

Initial state before any data is loaded.

**Properties**: None

---

##### `ChatHistoryLoading`

Indicates chat history is being loaded from database.

**Properties**: None

---

##### `ChatHistoryLoaded`

Successfully loaded chat history with optional selection state.

**Properties**:

- `chats` (List<ChatHistory>) - List of all chat histories
- `isSelectionMode` (bool) - Whether multi-select mode is active (default:
  false)
- `selectedChatIds` (Set<String>) - Set of selected chat IDs (default: empty)

**Methods**:

- `copyWith()` - Creates a copy with optional property updates

---

##### `ChatHistoryError`

Error occurred while loading or managing chat history.

**Properties**:

- `error` (String) - Error message description

---

### ChatSessionBloc

**Purpose**: Manages an active chat session, including sending messages,
editing, regenerating responses, and switching AI models.

#### Dependencies

- `ChatHistoryService` - Required for persisting chat data
- `GeminiService` - Required for AI message generation

#### Events

##### `StartNewChat`

Initializes a new chat session with a generated UUID.

```dart
context.read<ChatSessionBloc>().add(const StartNewChat());
```

**Parameters**: None\
**Result**: Emits `ChatSessionActive` with new chat ID, empty messages, and
default title "New Chat"

**Note**: Chat is not persisted to database until first message is sent

---

##### `LoadChat`

Loads an existing chat session from database.

```dart
context.read<ChatSessionBloc>().add(LoadChat(chatId));
```

**Parameters**:

- `chatId` (String) - The unique identifier of the chat to load

**Result**: Emits `ChatSessionLoading` then `ChatSessionActive` with loaded
messages, or `ChatSessionError` on failure

**Side Effects**: Sets the AI model to the chat's `selectedModel`

---

##### `SendMessage`

Sends a new user message and requests AI response.

```dart
context.read<ChatSessionBloc>().add(SendMessage(content));
```

**Parameters**:

- `content` (Content) - The user's message content (from `google_generative_ai`
  package)

**Result**:

- Adds user message to chat
- Sets `isGenerating` to true
- Creates chat in database if first message
- Updates chat title based on first message (first 5 words)
- Triggers AI response via `MessageReceived` or `MessageError`

**State Flow**: `ChatSessionActive` → `ChatSessionActive` (with new message +
isGenerating=true) → `ChatSessionActive` (with AI response + isGenerating=false)

---

##### `EditMessage`

Edits an existing message and regenerates conversation from that point.

```dart
context.read<ChatSessionBloc>().add(EditMessage(messageId, newContent));
```

**Parameters**:

- `messageId` (String) - ID of the message to edit
- `newContent` (Content) - The new content for the message

**Result**:

- Updates message with `isEdited: true` flag
- Removes all messages after edited message
- Regenerates AI response from edited message onwards

**Side Effects**: Deletes subsequent messages from database

---

##### `RegenerateLastMessage`

Regenerates the last AI response using the same prompt.

```dart
context.read<ChatSessionBloc>().add(const RegenerateLastMessage());
```

**Parameters**: None\
**Requirements**: Last message must be from assistant (AI)

**Result**:

- Removes last AI message
- Resends previous user message to generate new AI response

---

##### `ChangeModel`

Switches the AI model for the current chat session.

```dart
context.read<ChatSessionBloc>().add(ChangeModel('gemini-2.5-flash-exp'));
```

**Parameters**:

- `modelName` (String) - Name of the model to switch to (must be in
  `GeminiService.availableModels`)

**Result**: Updates `selectedModel` in state and database

**Side Effects**: Updates `GeminiService` to use new model

---

##### `MessageReceived` (Internal)

Internal event triggered when AI response is received.

```dart
// Typically called internally by _onSendMessage
add(MessageReceived(response));
```

**Parameters**:

- `response` (Content) - The AI's response content

**Result**: Adds assistant message to chat and sets `isGenerating` to false

---

##### `MessageError` (Internal)

Internal event triggered when AI request fails.

```dart
// Typically called internally on error
add(MessageError(errorMessage));
```

**Parameters**:

- `error` (String) - Error message description

**Result**: Emits `ChatSessionError` state

---

#### States

##### `ChatSessionInitial`

Initial state before any chat is loaded or created.

**Properties**: None

---

##### `ChatSessionLoading`

Indicates a chat is being loaded from database.

**Properties**: None

---

##### `ChatSessionActive`

Active chat session with messages and metadata.

**Properties**:

- `chatId` (String) - Unique chat identifier
- `title` (String) - Chat title
- `messages` (List<ChatMessage>) - All messages in conversation order
- `isGenerating` (bool) - Whether AI is currently generating response (default:
  false)
- `selectedModel` (String) - Currently selected AI model (default:
  'gemini-2.0-flash-exp')

**Methods**:

- `copyWith()` - Creates a copy with optional property updates

---

##### `ChatSessionError`

Error occurred during chat operations.

**Properties**:

- `errorMessage` (String) - Error description
- `messages` (List<ChatMessage>) - Messages from before error occurred

---

### SettingsBloc

**Purpose**: Manages settings overlay visibility and window effects.

#### Dependencies

- `window_manager` package
- `flutter_acrylic` package

#### Events

##### `ShowSettings`

Shows the settings overlay.

```dart
context.read<SettingsBloc>().add(ShowSettings());
```

**Parameters**: None\
**Result**: Unmaximizes window, disables acrylic effect, emits `SettingsVisible`

**Side Effects**: Changes window to normal size and removes blur effect

---

##### `HideSettings`

Hides the settings overlay.

```dart
context.read<SettingsBloc>().add(HideSettings());
```

**Parameters**: None\
**Result**: Maximizes window, re-enables acrylic effect, emits `SettingsHidden`

**Side Effects**: Restores window to full screen with blur effect

---

#### States

##### `SettingsHidden`

Settings overlay is not visible (default state).

**Properties**: None

---

##### `SettingsVisible`

Settings overlay is currently displayed.

**Properties**: None

---

### WindowBloc

**Purpose**: Manages the main window visibility, animations, hotkey
registration, and window effect transitions.

#### Dependencies

- `window_manager` package
- `flutter_acrylic` package
- `hotkey_manager` package
- `AnimationController` (requires `TickerProvider`)

#### Constructor

```dart
WindowBloc(TickerProvider vsync)
```

**Parameters**:

- `vsync` (TickerProvider) - Required for AnimationController (usually from
  `SingleTickerProviderStateMixin`)

---

#### Public Properties

##### `animation`

```dart
Animation<double> get animation
```

Access to the underlying animation controller's view for observing animation
progress.

---

##### `currentEffect`

```dart
WindowEffect get currentEffect
```

Returns the currently active window effect (e.g., `WindowEffect.acrylic`).

---

#### Events

##### `OpenWindowEvent`

Opens and shows the main window with fade-in animation.

```dart
context.read<WindowBloc>().add(OpenWindowEvent());
```

**Parameters**: None\
**Result**: Shows window, focuses it, animates opacity from 0 to 1, emits
`WindowOpenedState`

**Animation**: 200ms fade-in

---

##### `CloseWindowEvent`

Closes and hides the main window with fade-out animation.

```dart
context.read<WindowBloc>().add(CloseWindowEvent());
```

**Parameters**: None\
**Result**: Animates opacity from 1 to 0, hides window, emits
`WindowClosedState`

**Animation**: 200ms fade-out

---

##### `WindowAnimationUpdateEvent` (Internal)

Internal event fired during animation updates.

```dart
// Automatically triggered by AnimationController listener
add(WindowAnimationUpdateEvent(progress));
```

**Parameters**:

- `progress` (double) - Animation progress from 0.0 to 1.0

**Result**: Emits `WindowAnimationState` with current progress

---

##### `WindowTransitionEvent`

Transitions between different window effects with animation.

```dart
context.read<WindowBloc>().add(WindowTransitionEvent(
  effect: WindowEffect.mica,
  duration: const Duration(milliseconds: 400),
));
```

**Parameters**:

- `effect` (WindowEffect) - Target window effect to transition to
- `duration` (Duration) - Total transition duration (default: 200ms)
- `background` (Widget) - Background widget to show during transition (default:
  `StaticBackground()`)

**Result**:

1. Shows static background
2. Waits half duration
3. Applies new effect
4. Waits half duration
5. Hides static background

**Note**: No-op if `effect` matches `currentEffect`

---

#### States

##### `InitialWindowState`

Initial state before window is shown (default state).

**Properties**:

- `isVisible` = false
- `showStatic` = false
- `currentEffect` = WindowEffect.acrylic

---

##### `WindowAnimationState`

Window is currently animating or at a specific animation progress.

**Properties**:

- `progress` (double) - Animation progress from 0.0 to 1.0
- `isVisible` (bool) - Whether window is visible
- `currentEffect` (WindowEffect) - Current window effect
- `showStatic` (bool) - Whether to show static background overlay (default:
  false)

---

##### `WindowOpenedState`

Window has fully opened and animation completed.

**Properties**:

- `isVisible` = true
- `isBefore` (bool) - Internal flag for transition timing (default: false)

---

##### `WindowClosedState`

Window has fully closed and is hidden.

**Properties**:

- `isVisible` = false

---

#### Hotkey Registration

The `WindowBloc` automatically registers a global hotkey on initialization:

**Hotkey**: `Ctrl+Shift+Space`

**Action**: Toggles window visibility (opens if closed, closes if open)

**Implementation**: Uses `hotkey_manager` package with
`PhysicalKeyboardKey.space` and modifiers
`[HotKeyModifier.control, HotKeyModifier.shift]`

---

## Services

### GeminiService

**Purpose**: Manages Google Gemini AI model interactions, including model
selection and message generation.

#### Configuration

##### API Key

```dart
static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
```

API key must be provided via `--dart-define=GEMINI_API_KEY=your_key_here` at
build/run time.

---

##### Available Models

```dart
static const List<String> availableModels = [
  'gemini-2.0-flash-exp',
  'gemini-2.0-flash-lite',
  'gemini-2.5-flash-exp',
  'gemini-2.5-flash-lite',
];
```

---

#### Methods

##### `setModel(String modelName)`

Sets the active AI model.

```dart
geminiService.setModel('gemini-2.5-flash-exp');
```

**Parameters**:

- `modelName` (String) - Must be one of `availableModels`

**Throws**: `ArgumentError` if model name is not in available models list

**Side Effects**: Initializes new `GenerativeModel` instance

---

##### `getModel()`

Returns the current `GenerativeModel` instance.

```dart
final model = geminiService.getModel();
```

**Returns**: `GenerativeModel` - The active model instance

**Side Effects**: Initializes model with default if not already set

---

##### `sendMessageStream(List<Content> history, String message)`

Sends a message and streams the AI response in chunks.

```dart
await for (final chunk in geminiService.sendMessageStream(history, 'Hello')) {
  print(chunk.text);
}
```

**Parameters**:

- `history` (List<Content>) - Previous conversation messages
- `message` (String) - New message text to send

**Returns**: `Stream<GenerateContentResponse>` - Streamed response chunks

**Use Case**: Real-time UI updates as AI generates response

---

##### `sendMessage(List<Content> history, Content message)`

Sends a message and waits for complete AI response.

```dart
final response = await geminiService.sendMessage(history, Content.text('Hello'));
print(response.text);
```

**Parameters**:

- `history` (List<Content>) - Previous conversation messages
- `message` (Content) - New message content to send

**Returns**: `Future<GenerateContentResponse>` - Complete AI response

**Use Case**: Batch message processing, simpler API

---

##### `sendMessageWithModel(List<Content> history, Content message, String modelName)`

Sends a message using a specific model without changing the service's default.

```dart
final response = await geminiService.sendMessageWithModel(
  history,
  Content.text('Explain AI'),
  'gemini-2.5-flash-exp',
);
```

**Parameters**:

- `history` (List<Content>) - Previous conversation messages
- `message` (Content) - New message content
- `modelName` (String) - Model to use for this request only

**Returns**: `Future<GenerateContentResponse>` - AI response

**Throws**: `ArgumentError` if model name is not available

**Use Case**: One-off requests with different models without affecting service
state

---

### ChatHistoryService

**Purpose**: Manages chat persistence operations including CRUD operations for
chats and messages in SQLite database.

#### Dependencies

- `DatabaseHelper` - Database connection management

---

#### Methods

##### `createNewChat(String chatId, String title, {String selectedModel})`

Creates a new chat record in the database.

```dart
await chatHistoryService.createNewChat(
  'uuid-123',
  'My New Chat',
  selectedModel: 'gemini-2.5-flash-exp',
);
```

**Parameters**:

- `chatId` (String) - Unique chat identifier (usually UUID)
- `title` (String) - Chat display title
- `selectedModel` (String) - AI model name (default: 'gemini-2.0-flash-exp')

**Side Effects**:

- Inserts record into `chats` table
- Sets `createdAt` and `updatedAt` to current time
- Uses `ConflictAlgorithm.replace` for upsert behavior

---

##### `updateChatTitle(String chatId, String newTitle)`

Updates the title of an existing chat.

```dart
await chatHistoryService.updateChatTitle('uuid-123', 'Updated Title');
```

**Parameters**:

- `chatId` (String) - Chat to update
- `newTitle` (String) - New title text

**Side Effects**: Updates `updatedAt` timestamp

---

##### `updateChatModel(String chatId, String selectedModel)`

Updates the AI model associated with a chat.

```dart
await chatHistoryService.updateChatModel('uuid-123', 'gemini-2.5-flash-exp');
```

**Parameters**:

- `chatId` (String) - Chat to update
- `selectedModel` (String) - New model name

**Side Effects**: Updates `updatedAt` timestamp

---

##### `addMessage(String chatId, ChatMessage message)`

Adds a new message to a chat.

```dart
await chatHistoryService.addMessage(chatId, ChatMessage(
  id: 'msg-uuid',
  content: Content.text('Hello'),
  role: MessageRole.user,
  timestamp: DateTime.now(),
));
```

**Parameters**:

- `chatId` (String) - Parent chat ID
- `message` (ChatMessage) - Message to add

**Side Effects**:

- Serializes `Content` object to JSON string in `contentJson` field
- Updates parent chat's `updatedAt` timestamp
- Uses `ConflictAlgorithm.replace` for upsert behavior

---

##### `updateMessage(ChatMessage message)`

Updates an existing message (typically for edits).

```dart
await chatHistoryService.updateMessage(editedMessage);
```

**Parameters**:

- `message` (ChatMessage) - Message with updated content

**Side Effects**: Locates message by `id` field

---

##### `deleteMessage(String messageId)`

Deletes a single message from the database.

```dart
await chatHistoryService.deleteMessage('msg-uuid');
```

**Parameters**:

- `messageId` (String) - ID of message to delete

---

##### `getChat(String chatId)`

Retrieves a complete chat with all messages.

```dart
final chat = await chatHistoryService.getChat('uuid-123');
print(chat.title);
print(chat.messages.length);
```

**Parameters**:

- `chatId` (String) - Chat to retrieve

**Returns**: `Future<ChatHistory>` - Complete chat object with:

- `chatId` (String)
- `title` (String)
- `selectedModel` (String)
- `messages` (List<ChatMessage>) - Ordered by timestamp ASC
- `createdAt` (DateTime?)
- `updatedAt` (DateTime?)

**Throws**: `Exception('Chat not found')` if chat doesn't exist

**Processing**: Deserializes `contentJson` back to `Content` objects

---

##### `getAllChats()`

Retrieves all chats ordered by most recently updated.

```dart
final allChats = await chatHistoryService.getAllChats();
```

**Returns**: `Future<List<ChatHistory>>` - All chats with complete message lists

**Ordering**: Descending by `updatedAt` (most recent first)

**Error Handling**: Silently skips chats that fail to load (continues iteration)

---

##### `getAllChatIds()`

Retrieves only the chat IDs without loading messages.

```dart
final ids = await chatHistoryService.getAllChatIds();
```

**Returns**: `Future<List<String>>` - List of all chat IDs

**Use Case**: Lightweight operations that don't need full chat data

---

##### `deleteChat(String chatId)`

Deletes a chat and all its messages.

```dart
await chatHistoryService.deleteChat('uuid-123');
```

**Parameters**:

- `chatId` (String) - Chat to delete

**Side Effects**:

- Deletes from `chats` table
- Cascade deletes all messages from `messages` table

---

##### `deleteMultipleChats(List<String> chatIds)`

Deletes multiple chats in a single transaction.

```dart
await chatHistoryService.deleteMultipleChats(['uuid-1', 'uuid-2', 'uuid-3']);
```

**Parameters**:

- `chatIds` (List<String>) - List of chat IDs to delete

**Optimization**: Uses database transaction for atomic operation

**Edge Case**: No-op if list is empty

---

##### `clearHistory()`

Deletes all chats and messages from database.

```dart
await chatHistoryService.clearHistory();
```

**Parameters**: None

**Side Effects**: Truncates both `chats` and `messages` tables

---

### DatabaseHelper

**Purpose**: Singleton manager for SQLite database initialization, schema
management, and migrations.

#### Architecture

##### Singleton Pattern

```dart
static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
```

Access via `DatabaseHelper.instance` only - constructor is private.

---

#### Properties

##### `database`

```dart
Future<Database> get database async
```

Lazy-initialized database instance getter.

**Returns**: `Future<Database>` - SQLite database connection

**Usage**:

```dart
final db = await DatabaseHelper.instance.database;
final results = await db.query('chats');
```

---

#### Database Schema

##### Current Version: 2

##### `chats` Table

| Column        | Type | Constraints                    | Description            |
| ------------- | ---- | ------------------------------ | ---------------------- |
| chatId        | TEXT | PRIMARY KEY                    | Unique chat identifier |
| title         | TEXT | NOT NULL                       | Chat display name      |
| selectedModel | TEXT | DEFAULT 'gemini-2.0-flash-exp' | Active AI model        |
| createdAt     | TEXT | NOT NULL                       | ISO 8601 timestamp     |
| updatedAt     | TEXT | NOT NULL                       | ISO 8601 timestamp     |

---

##### `messages` Table

| Column      | Type    | Constraints           | Description                    |
| ----------- | ------- | --------------------- | ------------------------------ |
| id          | TEXT    | PRIMARY KEY           | Unique message identifier      |
| chatId      | TEXT    | NOT NULL, FOREIGN KEY | Parent chat reference          |
| role        | TEXT    | NOT NULL              | 'user' or 'assistant'          |
| timestamp   | TEXT    | NOT NULL              | ISO 8601 timestamp             |
| contentJson | TEXT    | NOT NULL              | Serialized Content object      |
| isEdited    | INTEGER | DEFAULT 0             | Boolean flag (0=false, 1=true) |

**Foreign Key**: `chatId` references `chats(chatId)` with `ON DELETE CASCADE`

---

#### Schema Migrations

##### Version 1 → 2

Adds the following columns to existing tables:

- `chats.selectedModel` (TEXT, default 'gemini-2.0-flash-exp')
- `chats.createdAt` (TEXT, defaults to current timestamp)
- `chats.updatedAt` (TEXT, defaults to current timestamp)
- `messages.isEdited` (INTEGER, default 0)

**Migration Method**: `_onUpgrade(Database db, int oldVersion, int newVersion)`

---

#### File Location

Database file path: `{ApplicationSupportDirectory}/coms_chat.db`

Uses `path_provider` package to get platform-specific application support
directory.

---

## Usage Examples

### Starting a New Chat Session

```dart
// Get services from provider
final chatSessionBloc = context.read<ChatSessionBloc>();
final chatHistoryBloc = context.read<ChatHistoryBloc>();

// Start new chat
chatSessionBloc.add(const StartNewChat());

// Send first message
chatSessionBloc.add(SendMessage(Content.text('Hello, AI!')));

// Refresh history list
chatHistoryBloc.add(const LoadAllChats());
```

---

### Loading Existing Chat

```dart
final chatSessionBloc = context.read<ChatSessionBloc>();

// Load chat by ID
chatSessionBloc.add(LoadChat('existing-chat-uuid'));

// Listen to state
BlocBuilder<ChatSessionBloc, ChatSessionState>(
  builder: (context, state) {
    if (state is ChatSessionActive) {
      return ListView.builder(
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          return MessageWidget(message: state.messages[index]);
        },
      );
    }
    return const CircularProgressIndicator();
  },
);
```

---

### Multi-Select Delete Chats

```dart
final chatHistoryBloc = context.read<ChatHistoryBloc>();

// Enable selection mode
chatHistoryBloc.add(const ToggleSelectionMode());

// Select multiple chats
chatHistoryBloc.add(ToggleChatSelection('chat-1'));
chatHistoryBloc.add(ToggleChatSelection('chat-2'));
chatHistoryBloc.add(ToggleChatSelection('chat-3'));

// Delete selected
chatHistoryBloc.add(const DeleteSelectedChats());
```

---

### Window Visibility with Hotkey

```dart
// WindowBloc automatically registers Ctrl+Shift+Space
// User can press hotkey to toggle window

// Programmatic control:
final windowBloc = context.read<WindowBloc>();

// Show window
windowBloc.add(OpenWindowEvent());

// Hide window
windowBloc.add(CloseWindowEvent());

// Listen to animation
BlocBuilder<WindowBloc, WindowState>(
  builder: (context, state) {
    if (state is WindowAnimationState) {
      return Opacity(
        opacity: state.progress,
        child: MainContent(),
      );
    }
    return const SizedBox.shrink();
  },
);
```

---

### Changing AI Models

```dart
final chatSessionBloc = context.read<ChatSessionBloc>();

// Switch to different model mid-conversation
chatSessionBloc.add(const ChangeModel('gemini-2.5-flash-exp'));

// Future messages will use new model
chatSessionBloc.add(SendMessage(Content.text('Test new model')));
```

---

## Error Handling

### Common Error States

#### ChatHistoryError

```dart
BlocListener<ChatHistoryBloc, ChatHistoryState>(
  listener: (context, state) {
    if (state is ChatHistoryError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    }
  },
  child: YourWidget(),
);
```

#### ChatSessionError

```dart
BlocConsumer<ChatSessionBloc, ChatSessionState>(
  listener: (context, state) {
    if (state is ChatSessionError) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(state.errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  },
  builder: (context, state) => YourChatUI(state),
);
```

---

## Best Practices

### 1. Initialize Services Before BLoCs

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database first
  await DatabaseHelper.instance.database;
  
  // Create services
  final chatHistoryService = ChatHistoryService();
  final geminiService = GeminiService();
  
  // Then create BLoCs with services
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChatHistoryBloc(chatHistoryService: chatHistoryService)),
        BlocProvider(create: (_) => ChatSessionBloc(
          chatHistoryService: chatHistoryService,
          geminiService: geminiService,
        )),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Always Check State Type Before Accessing Properties

```dart
// BAD
final messages = (state as ChatSessionActive).messages; // Can crash

// GOOD
if (state is ChatSessionActive) {
  final messages = state.messages;
  // Use messages safely
}
```

### 3. Use BlocConsumer for Side Effects + UI Updates

```dart
BlocConsumer<ChatSessionBloc, ChatSessionState>(
  listener: (context, state) {
    // Side effects: navigation, dialogs, snackbars
    if (state is ChatSessionError) {
      showErrorDialog(context, state.errorMessage);
    }
  },
  builder: (context, state) {
    // UI rendering
    return ChatUI(state: state);
  },
);
```

### 4. Dispose WindowBloc Properly

```dart
@override
void dispose() {
  // WindowBloc manages AnimationController internally
  // Must be closed to prevent memory leaks
  context.read<WindowBloc>().close();
  super.dispose();
}
```

---

## Dependencies Reference

### Required Packages

```yaml
dependencies:
    flutter_bloc: ^8.1.3
    equatable: ^2.0.5
    google_generative_ai: # Custom fork
    sqflite: ^2.3.0
    path_provider: ^2.1.1
    uuid: ^4.2.1
    window_manager: ^0.3.7
    flutter_acrylic: ^1.1.3
    hotkey_manager: ^0.1.8
```

---

## Version History

- **v1.0** - Initial API documentation
- Database schema version: 2
- Compatible with Flutter 3.x

---

## Related Documentation

- [Project Setup Guide](copilot-instructions.md)
- [Model Classes](lib/models/)
- [Utility Extensions](lib/utilities/)
- [UI Widgets](lib/widgets/)
