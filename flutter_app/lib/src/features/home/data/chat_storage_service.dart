import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/widgets/ai_chat_bot.dart';

class ChatStorageService {
  static const String _chatMessagesKey = 'ai_chat_messages';
  static const String _chatTimestampKey = 'ai_chat_timestamp';

  // Save chat messages to local storage
  static Future<void> saveMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert messages to JSON
      final messagesJson = messages.map((message) => {
        'message': message.message,
        'isUser': message.isUser,
        'timestamp': message.timestamp.toIso8601String(),
      }).toList();
      
      // Save messages and timestamp
      await prefs.setString(_chatMessagesKey, json.encode(messagesJson));
      await prefs.setString(_chatTimestampKey, DateTime.now().toIso8601String());
      
      print('DEBUG: Chat messages saved - ${messages.length} messages');
    } catch (e) {
      print('ERROR: Failed to save chat messages: $e');
    }
  }

  // Load chat messages from local storage
  static Future<List<ChatMessage>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_chatMessagesKey);
      
      if (messagesJson == null || messagesJson.isEmpty) {
        print('DEBUG: No chat messages found in storage');
        return [];
      }
      
      final messagesData = json.decode(messagesJson) as List<dynamic>;
      final messages = messagesData.map((messageData) {
        return ChatMessage(
          message: messageData['message'] as String,
          isUser: messageData['isUser'] as bool,
          timestamp: DateTime.parse(messageData['timestamp'] as String),
        );
      }).toList();
      
      print('DEBUG: Chat messages loaded - ${messages.length} messages');
      return messages;
    } catch (e) {
      print('ERROR: Failed to load chat messages: $e');
      return [];
    }
  }

  // Clear all chat messages (called on logout)
  static Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatMessagesKey);
      await prefs.remove(_chatTimestampKey);
      print('DEBUG: Chat messages cleared from storage');
    } catch (e) {
      print('ERROR: Failed to clear chat messages: $e');
    }
  }

  // Check if chat messages exist
  static Future<bool> hasMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_chatMessagesKey);
    } catch (e) {
      return false;
    }
  }

  // Get last chat timestamp
  static Future<DateTime?> getLastChatTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_chatTimestampKey);
      
      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }
    } catch (e) {
      print('ERROR: Failed to get last chat timestamp: $e');
    }
    return null;
  }

  // Check if chat is from today
  static Future<bool> isChatFromToday() async {
    final lastTimestamp = await getLastChatTimestamp();
    if (lastTimestamp == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final chatDate = DateTime(lastTimestamp.year, lastTimestamp.month, lastTimestamp.day);
    
    return chatDate.isAtSameMomentAs(today);
  }
}