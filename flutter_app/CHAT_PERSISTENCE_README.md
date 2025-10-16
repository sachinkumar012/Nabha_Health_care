# AI Chat Bot with Message Persistence

## Overview
The AI Chat Bot now includes message persistence functionality that saves chat messages until the user logs out of their account.

## Features Implemented

### 1. Chat Storage Service
**File:** `lib/src/features/home/data/chat_storage_service.dart`

- **Message Persistence**: Saves all chat messages to local storage using SharedPreferences
- **JSON Serialization**: Converts ChatMessage objects to/from JSON for storage
- **Timestamp Tracking**: Tracks when messages were last saved
- **Session Management**: Provides methods to clear messages on logout

### 2. User Provider Integration
**File:** `lib/src/features/auth/presentation/providers/user_provider.dart`

- **Logout Integration**: Automatically clears chat messages when user logs out
- **Clean Session**: Ensures no chat data persists between different user sessions

### 3. Enhanced AI Chat Bot
**File:** `lib/src/features/home/presentation/widgets/ai_chat_bot.dart`

- **Auto-save**: Automatically saves messages after each user interaction and AI response
- **Load History**: Loads previous chat history when opening the chat bot
- **Clear Chat**: Provides manual clear chat functionality with confirmation dialog
- **User State Monitoring**: Watches for user logout events to clear chat

## How It Works

### Message Saving
1. When user sends a message → Save to storage
2. When AI responds → Save to storage
3. Messages are stored as JSON in SharedPreferences

### Message Loading
1. When chat bot opens → Load previous messages from storage
2. If no saved messages → Show welcome message
3. Scroll to bottom after loading

### Message Clearing
1. **Manual**: User can tap the clear button in app bar
2. **Automatic**: Messages are cleared when user logs out
3. **Confirmation**: Shows dialog before manual clearing

### Session Management
- Each user session maintains its own chat history
- Chat history is cleared between different user accounts
- Messages persist across app restarts for same user

## Storage Structure

### Chat Messages Key: `ai_chat_messages`
```json
[
  {
    "message": "Hello! I need to see a cardiologist",
    "isUser": true,
    "timestamp": "2025-10-15T10:30:00.000Z"
  },
  {
    "message": "I can help you book an appointment...",
    "isUser": false,
    "timestamp": "2025-10-15T10:30:02.000Z"
  }
]
```

### Chat Timestamp Key: `ai_chat_timestamp`
```
"2025-10-15T10:30:02.000Z"
```

## User Experience

### Chat Continuity
- Users can close and reopen the chat bot without losing conversation history
- Previous conversations are immediately available
- Seamless experience across app sessions

### Privacy & Security
- Messages are automatically cleared when user logs out
- No chat data persists between different user accounts
- Local storage ensures data privacy

### User Control
- Manual clear chat option with confirmation
- Visual feedback when chat is cleared
- Welcome message appears after clearing

## Technical Implementation

### Dependencies
- `shared_preferences`: For local storage
- `flutter_riverpod`: For state management
- `dart:convert`: For JSON serialization

### Error Handling
- Graceful handling of storage errors
- Fallback to empty chat history if loading fails
- Debug logging for troubleshooting

### Performance
- Efficient JSON serialization
- Minimal storage footprint
- Fast loading of chat history

## Usage Instructions

### For Users
1. **Chat normally** - Messages automatically save
2. **Logout** - Chat history clears automatically
3. **Clear manually** - Tap trash icon in chat header
4. **Reopen chat** - Previous messages load automatically

### For Developers
1. **Chat Storage Service** - Use `ChatStorageService` for all persistence operations
2. **Message Format** - Follow `ChatMessage` model structure
3. **User Integration** - Monitor user provider for logout events
4. **Error Handling** - Implement try-catch blocks for storage operations

## Future Enhancements

### Potential Features
- Cloud synchronization for cross-device access
- Chat export functionality
- Message search capability
- Chat archiving by date
- User preferences for message retention

### Security Enhancements
- Message encryption
- Auto-expire old messages
- User consent for data storage
- GDPR compliance features