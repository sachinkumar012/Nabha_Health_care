import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/chat_storage_service.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/domain/models/user.dart';

class AiChatBot extends ConsumerStatefulWidget {
  const AiChatBot({super.key});

  @override
  ConsumerState<AiChatBot> createState() => _AiChatBotState();
}

class _AiChatBotState extends ConsumerState<AiChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Watch for user changes
    final user = ref.watch(userProvider);
    if (_currentUser != null && user == null) {
      // User logged out, clear chat
      _clearChat();
    }
    _currentUser = user;
  }

  // Load chat history from storage
  Future<void> _loadChatHistory() async {
    final savedMessages = await ChatStorageService.loadMessages();
    
    if (savedMessages.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(savedMessages);
      });
    } else {
      // Add welcome message only if no saved messages
      setState(() {
        _messages.add(
          ChatMessage(
            message: "Hello! I'm your AI health assistant. I can help you book appointments with doctors. What kind of specialist would you like to see?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
    
    // Scroll to bottom after loading messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Save messages to storage
  Future<void> _saveMessages() async {
    await ChatStorageService.saveMessages(_messages);
  }

  // Clear chat messages
  Future<void> _clearChat() async {
    setState(() {
      _messages.clear();
      // Add welcome message
      _messages.add(
        ChatMessage(
          message: "Hello! I'm your AI health assistant. I can help you book appointments with doctors. What kind of specialist would you like to see?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    
    // Clear from storage
    await ChatStorageService.clearMessages();
    
    // Save the welcome message
    await _saveMessages();
    
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(
          message: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Save messages after user sends a message
    _saveMessages();

    // Simulate AI response
    _generateAiResponse(userMessage);
  }

  void _generateAiResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      String aiResponse = _getAiResponse(userMessage);

      setState(() {
        _messages.add(
          ChatMessage(
            message: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });

      // Save messages after AI responds
      _saveMessages();

      _scrollToBottom();
    });
  }

  String _getAiResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('cardiologist') || lowerMessage.contains('heart')) {
      return "I can help you book an appointment with a cardiologist. We have Dr. Sarah Johnson available:\n\n• Monday-Friday: 9:00 AM - 5:00 PM\n• Consultation fee: \$150\n• Next available: Tomorrow 2:00 PM\n\nWould you like me to book this appointment for you?";
    } else if (lowerMessage.contains('dermatologist') || lowerMessage.contains('skin')) {
      return "Great! I can schedule you with our dermatologist Dr. Michael Chen:\n\n• Tuesday, Thursday, Saturday: 10:00 AM - 4:00 PM\n• Consultation fee: \$120\n• Next available: Friday 11:00 AM\n\nShall I proceed with the booking?";
    } else if (lowerMessage.contains('pediatrician') || lowerMessage.contains('child')) {
      return "Perfect! Dr. Emily Rodriguez is our excellent pediatrician:\n\n• Monday-Friday: 8:00 AM - 6:00 PM\n• Consultation fee: \$100\n• Next available: Today 4:30 PM\n\nWould you like to book this slot?";
    } else if (lowerMessage.contains('yes') || lowerMessage.contains('book') || lowerMessage.contains('confirm')) {
      return "Excellent! I've successfully booked your appointment. You'll receive a confirmation SMS shortly with:\n\n✅ Appointment details\n✅ Doctor's location\n✅ Preparation instructions\n✅ Payment link\n\nIs there anything else I can help you with?";
    } else if (lowerMessage.contains('emergency') || lowerMessage.contains('urgent')) {
      return "For emergencies, please call 911 immediately or visit the nearest emergency room.\n\nFor urgent but non-emergency care, I can book you with our urgent care clinic:\n\n📍 Available 24/7\n⏰ Average wait time: 15 minutes\n💰 Fee: \$80\n\nWould you like me to check you in now?";
    } else if (lowerMessage.contains('price') || lowerMessage.contains('cost') || lowerMessage.contains('fee')) {
      return "Here are our consultation fees:\n\n👨‍⚕️ General Physician: \$80\n❤️ Cardiologist: \$150\n🧠 Neurologist: \$180\n👶 Pediatrician: \$100\n👨‍⚕️ Dermatologist: \$120\n🦴 Orthopedic: \$160\n\nMost insurance plans are accepted. Which specialist interests you?";
    } else {
      return "I can help you book appointments with these specialists:\n\n👨‍⚕️ General Physician\n❤️ Cardiologist\n🧠 Neurologist\n👶 Pediatrician\n👨‍⚕️ Dermatologist\n🦴 Orthopedic Surgeon\n👁️ Ophthalmologist\n\nWhich type of doctor would you like to see? Or do you have specific symptoms you'd like to discuss?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Assistant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey900,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: () async {
              // Show confirmation dialog
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat'),
                  content: const Text('Are you sure you want to clear all chat messages? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              
              if (shouldClear == true) {
                await _clearChat();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat cleared successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isUser ? AppColors.white : AppColors.grey900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? AppColors.white.withOpacity(0.7)
                          : AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.grey600,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.grey600,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hourStr:$minute $period';
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}