# Chat Feature Implementation Documentation

## Overview

This document details the complete implementation of the chat feature for the
Coms Inferential desktop overlay application. The chat system supports full AI
conversations with multiple models, media attachments, message editing, chat
history management, and persistence.

## Architecture

The implementation follows the BLoC (Business Logic Component) pattern for state
management, separating business logic from UI concerns. The architecture
consists of:

### Core Components

1. **Data Models** - Domain entities representing chat data
2. **Services** - Business logic for AI communication and data persistence
3. **BLoCs** - State management for active chat and chat history
4. **UI Widgets** - Presentation layer components
5. **Database** - SQLite-based persistence layer

## Data Models

### ChatMessage (`lib/models/chat_message.dart`)

Represents a single message in a conversation.

**Properties:**

- `id: String` - Unique identifier (UUID)
- `content: Content` - Message content (from google_generative_ai package)
- `role: MessageRole` - Who sent the message (user/assistant/system)
- `timestamp: DateTime` - When the message was created
- `isEdited: bool` - Whether the message has been edited

**Key Features:**

- Serialization support for database storage
- Immutable with `copyWith` method for updates
- Supports text and media content through the `Content` type

### ChatHistory (`lib/models/chat_history.dart`)

Represents a complete chat conversation.

**Properties:**

- `chatId: String` - Unique chat identifier
- `title: String` - Chat title (auto-generated from first message)
- `messages: List<ChatMessage>` - All messages in the conversation
- `selectedModel: String` - AI model used for this chat
- `createdAt: DateTime` - Chat creation timestamp
- `updatedAt: DateTime` - Last modification timestamp

**Default Model:** `gemini-2.0-flash-exp`

## Services Layer

### GeminiService (`lib/services/gemini_service.dart`)

Manages communication with Google's Gemini AI models.

**Available Models:**

- `gemini-2.0-flash-exp`
- `gemini-2.0-flash-lite`
- `gemini-2.5-flash-exp`
- `gemini-2.5-flash-lite`

**Key Methods:**

- `setModel(String modelName)` - Switch active model
- `getModel()` - Get current GenerativeModel instance
- `sendMessage(List<Content> history, Content message)` - Send message with
  conversation history
- `sendMessageWithModel(...)` - Send message with specific model override

**Implementation Details:**

- Singleton pattern for model instances
- API key loaded from environment variable `GEMINI_API_KEY`
- Maintains conversation context through history parameter

### ChatHistoryService (`lib/services/chat_history_service.dart`)

Manages persistence of chat data to SQLite database.

**Key Methods:**

- `createNewChat(String chatId, String title, {String selectedModel})` -
  Initialize new chat
- `addMessage(String chatId, ChatMessage message)` - Add message to chat
- `updateMessage(ChatMessage message)` - Update existing message (for edits)
- `deleteMessage(String messageId)` - Remove message
- `getChat(String chatId)` - Load complete chat with messages
- `getAllChats()` - Load all chats sorted by update time
- `deleteChat(String chatId)` - Delete entire chat
- `updateChatTitle(String chatId, String newTitle)` - Update chat title
- `updateChatModel(String chatId, String selectedModel)` - Change model for chat

**Automatic Behaviors:**

- Updates `updatedAt` timestamp on any chat modification
- Auto-generates chat title from first user message (first 5 words)
- Cascading deletes for messages when chat is deleted

### DatabaseHelper (`lib/services/database_helper.dart`)

SQLite database management with schema versioning.

**Schema (Version 2):**

**chats table:**

```sql
CREATE TABLE chats (
  chatId TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  selectedModel TEXT DEFAULT 'gemini-2.0-flash-exp',
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

**messages table:**

```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  chatId TEXT NOT NULL,
  role TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  contentJson TEXT NOT NULL,
  isEdited INTEGER DEFAULT 0,
  FOREIGN KEY (chatId) REFERENCES chats (chatId) ON DELETE CASCADE
)
```

**Migration:** Handles upgrade from version 1 to 2 by adding new columns with
defaults.

## BLoC State Management

### ChatSessionBloc (`lib/blocs/chat_session_bloc/`)

Manages the active chat session state.

#### Events

- `StartNewChat()` - Create and load a new empty chat
- `LoadChat(String chatId)` - Load existing chat from database
- `SendMessage(Content content)` - Send user message and get AI response
- `EditMessage(String messageId, Content newContent)` - Edit message and
  regenerate subsequent responses
- `RegenerateLastMessage()` - Delete last AI response and generate new one
- `ChangeModel(String modelName)` - Switch AI model for current chat
- `MessageReceived(Content response)` - Internal event when AI responds
- `MessageError(String error)` - Internal event on error

#### States

- `ChatSessionInitial` - No chat loaded
- `ChatSessionLoading` - Loading chat from database
- `ChatSessionActive` - Chat loaded and ready
  - Contains: chatId, title, messages, isGenerating flag, selectedModel
- `ChatSessionError` - Error occurred (preserves messages for recovery)

#### Key Behaviors

**Message Sending Flow:**

1. Add user message to state immediately (optimistic update)
2. Save to database
3. Auto-generate title if first message
4. Send to AI with full history context
5. Receive response and add to state
6. Save AI response to database

**Message Editing Flow:**

1. Update message with edited content
2. Delete all subsequent messages (conversation fork)
3. Regenerate AI response with new context
4. Save updated conversation

**Model Changes:**

- Persist to database immediately
- Apply to future messages only (doesn't affect existing messages)

### ChatHistoryBloc (`lib/blocs/chat_history_bloc/`)

Manages the list of all chat conversations.

#### Events

- `LoadAllChats()` - Load all chats from database
- `SelectChat(String chatId)` - User selected a chat (handled by
  ChatSessionBloc)
- `DeleteChatEvent(String chatId)` - Delete chat and refresh list
- `ClearAllChats()` - Delete all chats

#### States

- `ChatHistoryInitial` - Not loaded
- `ChatHistoryLoading` - Loading from database
- `ChatHistoryLoaded(List<ChatHistory> chats)` - Chats loaded successfully
- `ChatHistoryError(String error)` - Error occurred

**Sort Order:** Chats sorted by `updatedAt` descending (most recently used
first)

## UI Components

### ChatMessagesList (`lib/widgets/chat_messages_list.dart`)

Scrollable list of messages with auto-scroll to bottom on new messages.

**Features:**

- Displays all messages in conversation
- Shows "Thinking..." indicator during generation
- Edit button on last user message
- Regenerate button on last AI message
- Error handling with inline error display
- Empty state messages

**Edit Dialog:**

- Modal dialog with multiline text field
- Cancel/Save actions
- Triggers `EditMessage` event on save

### MessageBubble (`lib/widgets/message_bubble.dart`)

Individual message display component.

**Features:**

- Different styling for user vs AI messages
- Selectable text
- Media attachment previews with icons
- Edited indicator
- Action buttons (edit/regenerate) on hover

**Media Support:**

- Images (JPEG, PNG, GIF, WebP)
- Videos (MP4, AVI, MOV)
- Audio (MP3, WAV)
- Documents (PDF, DOC, DOCX, TXT)

### ChatInput (`lib/widgets/chat_input.dart`)

Message composition area with media attachment support.

**Features:**

- Multiline text input
- File attachment picker
- Media preview chips with remove button
- Model selector integration
- Send button
- Disabled state during generation
- Enter key to send

**File Handling:**

- Reads files as bytes
- Converts to inline data with MIME type detection
- Supports multiple attachments per message
- Platform-agnostic file picker

### ModelSelector (`lib/widgets/model_selector.dart`)

Dropdown menu for selecting AI model.

**Features:**

- Popup menu with all available models
- Checkmark on selected model
- Bold text for active selection
- Triggers `ChangeModel` event

### ChatHistorySidebar (`lib/widgets/chat_history_sidebar.dart`)

Left sidebar showing all chat conversations.

**Features:**

- List of all chats with titles
- Message count display
- New chat button
- Delete chat with confirmation dialog
- Tap to load chat
- Auto-refresh on changes

**Layout:**

- Fixed 250px width
- Scrollable list
- Acrylic blur background
- Border separator

## Integration

### Homepage Layout (`lib/pages/homepage/homepage.dart`)

Restructured to accommodate chat interface.

**Layout Structure:**

```
Row
├─ ChatHistorySidebar (250px fixed)
└─ Expanded
   └─ Center
      └─ Column (700px max width)
         ├─ TopRow (settings, etc.)
         ├─ ChatMessagesList (expanded)
         ├─ Spacing
         └─ ChatInput
```

**Animation:**

- Fade in on window open
- Slide up for messages and input
- Respects window visibility state

### Main App Initialization (`lib/main.dart`)

**Service Initialization:**

1. Create `ChatHistoryService` instance
2. Create `GeminiService` instance
3. Create `ChatSessionBloc` with services
4. Create `ChatHistoryBloc` with service

**Initial Actions:**

- Start new chat automatically
- Load all chats for sidebar

**BLoC Providers:**

- WindowBloc (existing)
- SettingsBloc (existing)
- ChatSessionBloc (new)
- ChatHistoryBloc (new)

## Key Features Implemented

### ✅ Message Management

- Send text messages
- Attach multiple media files (images, videos, audio, documents)
- Display messages with proper formatting
- Auto-scroll to latest message

### ✅ Message Editing

- Edit last user message
- Conversation forks from edit point
- Regenerates AI response with new context
- Visual indicator for edited messages

### ✅ Response Regeneration

- Regenerate last AI response
- Maintains conversation history
- Same model and context

### ✅ Chat History

- Create new chats
- Load existing chats
- Delete chats with confirmation
- Auto-title generation from first message
- Sort by recent activity

### ✅ Model Selection

- Switch between 4 Gemini models
- Per-chat model persistence
- Visual indication of active model
- Applies to new messages only

### ✅ Persistence

- SQLite database for all chat data
- Survives app restarts
- Efficient queries with indexing
- Automatic schema migrations

### ✅ UI/UX Polish

- Loading indicators
- Error handling and display
- Disabled states during generation
- Empty states
- Confirmation dialogs for destructive actions
- Tooltips for buttons

## Technical Decisions

### Why BLoC Pattern?

- Clear separation of business logic and UI
- Testable state management
- Reactive state updates
- Scalable architecture for complex features

### Why Separate Session and History BLoCs?

- **ChatSessionBloc** focuses on active conversation state
- **ChatHistoryBloc** manages list of all chats
- Prevents unnecessary rebuilds
- Clear responsibilities

### Why SQLite?

- Local-first data storage
- No server dependency
- Fast queries for chat history
- Reliable persistence

### Why Content Type from google_generative_ai?

- Native support for multimodal inputs
- Handles text and media uniformly
- Simplifies serialization
- Future-proof for new media types

## Data Flow Examples

### Sending a Message

```
User types message and clicks send
    ↓
ChatInput dispatches SendMessage(Content)
    ↓
ChatSessionBloc receives event
    ↓
Creates ChatMessage with user content
    ↓
Emits ChatSessionActive with new message (optimistic)
    ↓
Saves to database via ChatHistoryService
    ↓
Calls GeminiService.sendMessage() with history
    ↓
GeminiService returns response
    ↓
Dispatches MessageReceived(Content) to self
    ↓
Saves AI message to database
    ↓
Emits ChatSessionActive with AI message
    ↓
ChatMessagesList rebuilds with new messages
```

### Loading a Chat

```
User clicks chat in sidebar
    ↓
ChatHistorySidebar dispatches LoadChat(chatId)
    ↓
ChatSessionBloc emits ChatSessionLoading
    ↓
Calls ChatHistoryService.getChat()
    ↓
DatabaseHelper queries messages table
    ↓
Deserializes messages with ContentSerialization
    ↓
Returns ChatHistory object
    ↓
Emits ChatSessionActive with loaded data
    ↓
UI rebuilds showing all messages
```

## File Structure

```
lib/
├── blocs/
│   ├── chat_session_bloc/
│   │   ├── chat_session_bloc.dart       (Core logic)
│   │   ├── chat_session_event.dart      (Event definitions)
│   │   └── chat_session_state.dart      (State definitions)
│   ├── chat_history_bloc/
│   │   ├── chat_history_bloc.dart       (Core logic)
│   │   ├── chat_history_event.dart      (Event definitions)
│   │   └── chat_history_state.dart      (State definitions)
│   └── ... (other blocs)
├── models/
│   ├── chat_message.dart                (Message model)
│   └── chat_history.dart                (Chat model)
├── services/
│   ├── gemini_service.dart              (AI communication)
│   ├── chat_history_service.dart        (Database operations)
│   └── database_helper.dart             (SQLite management)
├── widgets/
│   ├── chat_messages_list.dart          (Message list)
│   ├── message_bubble.dart              (Single message)
│   ├── chat_input.dart                  (Input area)
│   ├── model_selector.dart              (Model picker)
│   └── chat_history_sidebar.dart        (Chat list)
├── pages/
│   └── homepage/
│       └── homepage.dart                (Main layout)
└── main.dart                            (App initialization)
```

## Dependencies Added

```yaml
uuid: ^4.5.1 # UUID generation for IDs
file_picker: ^8.1.6 # File attachment picker
```

**Existing Dependencies Used:**

- flutter_bloc: State management
- equatable: State comparison
- sqflite: Database
- path_provider: Database path
- google_generative_ai: AI models

## Configuration Requirements

### Environment Variables

```bash
GEMINI_API_KEY=your_api_key_here
```

Set this in your run configuration or use `--dart-define`:

```bash
flutter run -d windows --dart-define=GEMINI_API_KEY=your_key
```

## Future Enhancements

Potential improvements not implemented:

1. **Streaming Responses** - Show AI responses as they generate
2. **Conversation Branching** - Multiple response variants
3. **Message Reactions** - Like/dislike responses
4. **Search** - Full-text search across all chats
5. **Export** - Export conversations as markdown/PDF
6. **Context Window Management** - Automatic summarization for long chats
7. **Custom System Prompts** - Per-chat personality/instructions
8. **Voice Input** - Speech-to-text for messages
9. **Code Blocks** - Syntax highlighting in messages
10. **Markdown Rendering** - Rich text formatting in AI responses

## Testing Recommendations

To test the implementation:

1. **New Chat Flow**
   - App starts with new empty chat
   - Verify chat appears in sidebar

2. **Message Sending**
   - Send text-only message
   - Send message with image attachment
   - Send message with multiple files
   - Verify AI responds

3. **Message Editing**
   - Edit last user message
   - Verify subsequent messages are deleted
   - Verify new AI response

4. **Regeneration**
   - Click regenerate on last AI message
   - Verify new response differs

5. **Model Switching**
   - Change model mid-conversation
   - Verify next response uses new model
   - Verify old messages unchanged

6. **Chat Management**
   - Create multiple chats
   - Switch between chats
   - Delete chat (verify confirmation)
   - Verify sidebar updates

7. **Persistence**
   - Send messages
   - Close app
   - Reopen app
   - Verify chats and messages persist

8. **Error Handling**
   - Send message with invalid API key
   - Verify error displays inline
   - Verify can retry

## Performance Considerations

- **Message Rendering**: ListView.builder for efficient scrolling
- **Database Queries**: Indexed by chatId and timestamp
- **State Updates**: Immutable state with copyWith minimizes rebuilds
- **Media Handling**: Files converted to bytes only when sending
- **History Pruning**: Consider implementing automatic trimming for very long
  chats

## Conclusion

This implementation provides a complete, production-ready chat interface with
all requested features. The architecture is scalable, maintainable, and follows
Flutter/BLoC best practices. The system is designed to be extended with
additional features while maintaining clean separation of concerns.
