import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/theme/app_theme.dart';

// API Configuration
const String API_KEY = "AIzaSyCAzGYeMcfLMCp1ghvQWBX2xdbLhbJS1Go";
const String GEMINI_API_URL =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

// Language selection provider
final selectedLanguageProvider = StateProvider<String>((ref) => 'English');

// Chat message model
class ChatMessage {
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final String? severity;
  final List<String>? recommendations;
  final bool isError;
  final String? originalUserMessage; // Store original message for retry

  ChatMessage({
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.severity,
    this.recommendations,
    this.isError = false,
    this.originalUserMessage,
  });
}

// AI Chat state
class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String currentInput;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.currentInput = '',
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? currentInput,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentInput: currentInput ?? this.currentInput,
    );
  }
}

// AI Chat state provider
final aiChatProvider =
    StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier();
});

// AI Chat notifier
class AIChatNotifier extends StateNotifier<AIChatState> {
  AIChatNotifier() : super(AIChatState());

  void updateCurrentInput(String input) {
    state = state.copyWith(currentInput: input);
  }

  void addMessage(ChatMessage message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> sendMessage(String userMessage, String language) async {
    if (userMessage.trim().isEmpty) return;

    // Add user message
    addMessage(ChatMessage(
      content: userMessage,
      isFromUser: true,
      timestamp: DateTime.now(),
    ));

    // Clear input and set loading
    state = state.copyWith(currentInput: '', isLoading: true);

    // Try API call with retry mechanism
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('Attempt $attempt of 3 for API call');

        // Check network connection on first attempt
        if (attempt == 1) {
          final hasNetwork = await _checkNetworkConnection();
          if (!hasNetwork) {
            throw Exception('No internet connection available');
          }
        }

        // Call Gemini API
        final aiResponse = await _callGeminiAPI(userMessage, language);

        // Add AI response
        addMessage(ChatMessage(
          content: aiResponse['content'] ??
              'Sorry, I could not process your request.',
          isFromUser: false,
          timestamp: DateTime.now(),
          severity: aiResponse['severity'],
          recommendations: aiResponse['recommendations']?.cast<String>(),
        ));

        // Success - break out of retry loop
        break;
      } catch (e) {
        print('Attempt $attempt failed: $e');

        // If this is the last attempt, show error
        if (attempt == 3) {
          String errorMessage =
              'Sorry, I encountered an error. Please try again.';

          if (e.toString().contains('timeout')) {
            errorMessage =
                'Request timed out. Please check your internet connection and try again.';
          } else if (e.toString().contains('Network')) {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (e.toString().contains('API Error: 400')) {
            errorMessage =
                'Invalid request. Please rephrase your question and try again.';
          } else if (e.toString().contains('API Error: 401')) {
            errorMessage = 'Authentication error. Please contact support.';
          } else if (e.toString().contains('API Error: 403')) {
            errorMessage = 'Access denied. Please contact support.';
          } else if (e.toString().contains('API Error: 429')) {
            errorMessage =
                'Too many requests. Please wait a moment and try again.';
          } else if (e.toString().contains('API Error: 500')) {
            errorMessage = 'Server error. Please try again in a few minutes.';
          }

          addMessage(ChatMessage(
            content: errorMessage,
            isFromUser: false,
            timestamp: DateTime.now(),
            isError: true,
            originalUserMessage: userMessage,
          ));
        } else {
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    state = state.copyWith(isLoading: false);
  }

  Future<bool> _checkNetworkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _callGeminiAPI(
      String userMessage, String language) async {
    try {
      final systemInstruction = _getSystemInstruction(language);
      final prompt = "$systemInstruction\n\nPatient: $userMessage";

      print('🚀 Calling Gemini API...');
      print('📡 API URL: $GEMINI_API_URL');
      print('🔑 API Key: ${API_KEY.substring(0, 10)}...');

      // Simplified request body without safety settings to avoid API errors
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        }
      };

      final requestBodyString = jsonEncode(requestBody);
      print(
          '📝 Request body: ${requestBodyString.length > 200 ? requestBodyString.substring(0, 200) + "..." : requestBodyString}');

      final response = await http
          .post(
            Uri.parse('$GEMINI_API_URL?key=$API_KEY'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: requestBodyString,
          )
          .timeout(const Duration(seconds: 30));

      print('✅ API Response Status: ${response.statusCode}');
      final responseBodyString = response.body;
      print(
          '📄 API Response Body: ${responseBodyString.length > 500 ? responseBodyString.substring(0, 500) + "..." : responseBodyString}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response has candidates
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          print('❌ No candidates in response');

          // Check for blocked response
          if (data['promptFeedback'] != null &&
              data['promptFeedback']['blockReason'] != null) {
            print(
                '🚫 Response blocked: ${data['promptFeedback']['blockReason']}');
            return {
              'content':
                  'I understand you\'re asking about health concerns. Could you please rephrase your question? I\'m here to help with general health information.',
              'severity': 'mild',
              'recommendations': <String>[]
            };
          }

          return {
            'content':
                'I apologize, but I cannot provide a response right now. Please rephrase your question or try again.',
            'severity': 'mild',
            'recommendations': <String>[]
          };
        }

        final candidate = data['candidates'][0];

        // Check if candidate has content
        if (candidate['content'] == null ||
            candidate['content']['parts'] == null ||
            candidate['content']['parts'].isEmpty) {
          print('❌ No content in candidate');

          // Check for finish reason
          if (candidate['finishReason'] != null) {
            print('🏁 Finish reason: ${candidate['finishReason']}');
            if (candidate['finishReason'] == 'SAFETY') {
              return {
                'content':
                    'I understand you\'re asking about health concerns. For safety reasons, please consult with a healthcare professional for medical advice.',
                'severity': 'moderate',
                'recommendations': [
                  'Consult with a healthcare professional',
                  'Contact your doctor for medical advice'
                ]
              };
            }
          }

          return {
            'content':
                'I apologize, but I cannot provide a response to that specific query. Please try asking about your symptoms in a different way.',
            'severity': 'mild',
            'recommendations': <String>[]
          };
        }

        final aiContent =
            candidate['content']['parts'][0]['text'] ?? 'No response available';
        print('🤖 AI Content: ${aiContent.substring(0, 100)}...');

        return _parseAIResponse(aiContent, language);
      } else {
        print(
            '💥 API Error - Status: ${response.statusCode}, Body: ${response.body}');

        // Handle specific error codes with more details
        if (response.statusCode == 400) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['error'] != null &&
                errorData['error']['message'] != null) {
              print('💥 API Error Message: ${errorData['error']['message']}');
              throw Exception('API Error: ${errorData['error']['message']}');
            }
          } catch (e) {
            print('💥 Error parsing error response: $e');
          }
        }

        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 API Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Request timeout - please check your internet connection');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
            'Network error - please check your internet connection');
      } else if (e.toString().contains('API Error:')) {
        throw e; // Re-throw API errors as-is
      } else {
        throw Exception('Unable to connect to AI service - please try again');
      }
    }
  }

  Map<String, dynamic> _parseAIResponse(String aiContent, String language) {
    String severity = 'mild';
    List<String> recommendations = [];

    if (aiContent.toLowerCase().contains('severe') ||
        aiContent.toLowerCase().contains('emergency') ||
        aiContent.toLowerCase().contains('immediate')) {
      severity = 'severe';
    } else if (aiContent.toLowerCase().contains('moderate') ||
        aiContent.toLowerCase().contains('doctor') ||
        aiContent.toLowerCase().contains('medical')) {
      severity = 'moderate';
    }

    final lines = aiContent.split('\n');
    for (String line in lines) {
      if (line.trim().startsWith('-') ||
          line.trim().startsWith('•') ||
          line.trim().startsWith('*')) {
        recommendations.add(line.trim().substring(1).trim());
      }
    }

    return {
      'content': aiContent,
      'severity': severity,
      'recommendations': recommendations,
    };
  }

  String _getSystemInstruction(String language) {
    final instructions = {
      'English':
          '''You are a helpful AI medical assistant. Provide concise, accurate health information about symptoms.

IMPORTANT GUIDELINES:
- Keep responses under 200 words
- Ask 1-2 clarifying questions to better understand symptoms
- Provide preliminary assessment based on symptoms
- Always recommend consulting healthcare professionals for serious concerns
- Be supportive and non-alarming
- Use simple, easy-to-understand language
- Include severity assessment (mild/moderate/severe)
- Provide 2-3 actionable recommendations starting with "-"
- ALWAYS remind patients this is not a substitute for professional medical advice

Format your response clearly with:
1. Brief acknowledgment of symptoms
2. Preliminary assessment
3. 2-3 recommendations with "-" 
4. When to see a doctor

Example format:
"I understand you're experiencing [symptoms]. This could be [assessment]. 
- Rest and stay hydrated
- Monitor your temperature
- Avoid strenuous activities
Consult a healthcare professional if symptoms worsen or persist beyond 2-3 days."''',
      'Hindi':
          '''आप एक सहायक AI चिकित्सा सहायक हैं। लक्षणों के बारे में संक्षिप्त, सटीक स्वास्थ्य जानकारी प्रदान करें।

महत्वपूर्ण दिशानिर्देश:
- जवाब 200 शब्दों से कम रखें
- लक्षणों को बेहतर समझने के लिए 1-2 स्पष्टीकरण प्रश्न पूछें
- वर्णित लक्षणों के आधार पर प्रारंभिक मूल्यांकन प्रदान करें
- गंभीर चिंताओं के लिए हमेशा स्वास्थ्य पेशेवरों से सलाह लेने की सिफारिश करें
- सहायक और गैर-चिंताजनक बनें
- सरल भाषा का उपयोग करें
- गंभीरता का आकलन शामिल करें (हल्का/मध्यम/गंभीर)
- "-" से शुरू होने वाली 2-3 सिफारिशें प्रदान करें

हमेशा याद दिलाएं कि यह पेशेवर चिकित्सा सलाह का विकल्प नहीं है।''',
      'Punjabi':
          '''ਤੁਸੀਂ ਇੱਕ ਮਦਦਗਾਰ AI ਮੈਡੀਕਲ ਸਹਾਇਕ ਹੋ। ਲੱਛਣਾਂ ਬਾਰੇ ਸੰਖੇਪ, ਸਟੀਕ ਸਿਹਤ ਜਾਣਕਾਰੀ ਦਿਓ।

ਮਹੱਤਵਪੂਰਨ ਦਿਸ਼ਾ-ਨਿਰਦੇਸ਼:
- ਜਵਾਬ 200 ਸ਼ਬਦਾਂ ਤੋਂ ਘੱਟ ਰੱਖੋ
- ਲੱਛਣਾਂ ਨੂੰ ਬਿਹਤਰ ਸਮਝਣ ਲਈ 1-2 ਸਪੱਸ਼ਟੀਕਰਣ ਸਵਾਲ ਪੁੱਛੋ
- ਵਰਣਿਤ ਲੱਛਣਾਂ ਦੇ ਅਧਾਰ ਤੇ ਸ਼ੁਰੂਆਤੀ ਮੁਲਾਂਕਣ ਦਿਓ
- ਗੰਭੀਰ ਚਿੰਤਾਵਾਂ ਲਈ ਹਮੇਸ਼ਾ ਸਿਹਤ ਪੇਸ਼ੇਵਰਾਂ ਨਾਲ ਸਲਾਹ ਲੈਣ ਦੀ ਸਿਫਾਰਸ਼ ਕਰੋ
- ਸਹਾਇਕ ਅਤੇ ਗੈਰ-ਚਿੰਤਾਜਨਕ ਬਣੋ
- ਸਰਲ ਭਾਸ਼ਾ ਦੀ ਵਰਤੋਂ ਕਰੋ
- ਗੰਭੀਰਤਾ ਮੁਲਾਂਕਣ ਸ਼ਾਮਲ ਕਰੋ (ਹਲਕਾ/ਮੱਧਮ/ਗੰਭੀਰ)
- "-" ਨਾਲ ਸ਼ੁਰੂ ਹੋਣ ਵਾਲੀਆਂ 2-3 ਸਿਫਾਰਸ਼ਾਂ ਦਿਓ

ਹਮੇਸ਼ਾ ਯਾਦ ਦਿਵਾਓ ਕਿ ਇਹ ਪੇਸ਼ੇਵਰ ਮੈਡੀਕਲ ਸਲਾਹ ਦਾ ਵਿਕਲਪ ਨਹੀਂ ਹੈ।'''
    };

    return instructions[language] ?? instructions['English']!;
  }

  void clearChat() {
    state = AIChatState();
  }

  Future<void> retryMessage(String originalMessage, String language) async {
    // Remove the last error message
    if (state.messages.isNotEmpty && state.messages.last.isError) {
      final updatedMessages =
          state.messages.sublist(0, state.messages.length - 1);
      state = state.copyWith(messages: updatedMessages);
    }

    // Retry sending the message
    await sendMessage(originalMessage, language);
  }
}

class SymptomCheckerPage extends ConsumerWidget {
  SymptomCheckerPage({super.key});

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final chatState = ref.watch(aiChatProvider);
    final chatNotifier = ref.read(aiChatProvider.notifier);

    if (_messageController.text != chatState.currentInput) {
      _messageController.text = chatState.currentInput;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('title', selectedLanguage)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => chatNotifier.clearChat(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String language) {
              ref.read(selectedLanguageProvider.notifier).state = language;
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'English', child: Text('English')),
              const PopupMenuItem(value: 'Hindi', child: Text('हिंदी')),
              const PopupMenuItem(value: 'Punjabi', child: Text('ਪੰਜਾਬੀ')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  _getLocalizedText('subtitle', selectedLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildWelcomeScreen(selectedLanguage, chatNotifier)
                : _buildChatMessages(chatState, selectedLanguage, ref),
          ),
          _buildInputSection(
              chatNotifier, selectedLanguage, chatState.isLoading),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(String language, AIChatNotifier chatNotifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.psychology,
            size: 100,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            _getLocalizedText('welcomeTitle', language),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedText('welcomeMessage', language),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._getQuickStartQuestions(language).map((question) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    chatNotifier.sendMessage(question, language);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    question,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getLocalizedText('disclaimer', language),
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedText('disclaimerText', language),
                  style: TextStyle(
                    color: AppColors.grey700,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(
      AIChatState chatState, String language, WidgetRef ref) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length) {
          return _buildTypingIndicator();
        }

        final message = chatState.messages[index];
        return _buildMessageBubble(message, language, ref);
      },
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, String language, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    message.isFromUser ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isFromUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomLeft: message.isFromUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color:
                          message.isFromUser ? Colors.white : AppColors.grey800,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  if (!message.isFromUser && message.severity != null) ...[
                    const SizedBox(height: 12),
                    _buildSeverityIndicator(message.severity!, language),
                  ],

                  // Add retry button for error messages
                  if (!message.isFromUser &&
                      message.isError &&
                      message.originalUserMessage != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final chatNotifier = ref.read(aiChatProvider.notifier);
                        chatNotifier.retryMessage(
                            message.originalUserMessage!, language);
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(_getLocalizedText('retry', language)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isFromUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.grey500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondary,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator(String severity, String language) {
    Color severityColor;
    IconData severityIcon;
    String severityText;

    switch (severity) {
      case 'severe':
        severityColor = AppColors.error;
        severityIcon = Icons.warning;
        severityText = _getLocalizedText('severityHigh', language);
        break;
      case 'moderate':
        severityColor = AppColors.warning;
        severityIcon = Icons.info;
        severityText = _getLocalizedText('severityModerate', language);
        break;
      default:
        severityColor = AppColors.success;
        severityIcon = Icons.check_circle;
        severityText = _getLocalizedText('severityMild', language);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severityIcon, color: severityColor, size: 16),
          const SizedBox(width: 8),
          Text(
            severityText,
            style: TextStyle(
              color: severityColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(
      AIChatNotifier chatNotifier, String language, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (value) => chatNotifier.updateCurrentInput(value),
              enabled: !isLoading,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _sendMessage(chatNotifier, language),
              decoration: InputDecoration(
                hintText: _getLocalizedText('typeMessage', language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.grey50,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed:
                  isLoading ? null : () => _sendMessage(chatNotifier, language),
              icon: Icon(
                isLoading ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(AIChatNotifier chatNotifier, String language) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      chatNotifier.sendMessage(message, language);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  List<String> _getQuickStartQuestions(String language) {
    final questions = {
      'English': [
        'I have a fever and headache',
        'I feel nauseous and dizzy',
        'I have a persistent cough',
        'I have stomach pain',
        'I feel chest tightness'
      ],
      'Hindi': [
        'मुझे बुखार और सिरदर्द है',
        'मुझे मितली और चक्कर आ रहे हैं',
        'मुझे लगातार खांसी है',
        'मुझे पेट में दर्द है',
        'मुझे सीने में जकड़न है'
      ],
      'Punjabi': [
        'ਮੈਨੂੰ ਬੁਖਾਰ ਅਤੇ ਸਿਰ ਦਰਦ ਹੈ',
        'ਮੈਨੂੰ ਮਤਲੀ ਅਤੇ ਚੱਕਰ ਆ ਰਹੇ ਹਨ',
        'ਮੈਨੂੰ ਲਗਾਤਾਰ ਖੰਘ ਹੈ',
        'ਮੈਨੂੰ ਪੇਟ ਵਿੱਚ ਦਰਦ ਹੈ',
        'ਮੈਨੂੰ ਛਾਤੀ ਵਿੱਚ ਜਕੜਨ ਹੈ'
      ]
    };

    return questions[language] ?? questions['English']!;
  }

  String _getLocalizedText(String key, String language) {
    final texts = {
      'English': {
        'title': 'AI Health Assistant',
        'subtitle': 'Chat with AI about your symptoms',
        'welcomeTitle': 'Welcome to AI Health Chat',
        'welcomeMessage':
            'I\'m here to help you understand your symptoms. Please describe how you\'re feeling, and I\'ll provide guidance and recommendations.',
        'typeMessage': 'Describe your symptoms...',
        'disclaimer': 'Important Disclaimer',
        'disclaimerText':
            'This AI assistant provides general health information only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult with qualified healthcare professionals for medical concerns.',
        'retry': 'Retry',
        'severityHigh': 'High Severity',
        'severityModerate': 'Moderate',
        'severityMild': 'Mild',
      },
      'Hindi': {
        'title': 'AI स्वास्थ्य सहायक',
        'subtitle': 'अपने लक्षणों के बारे में AI से बात करें',
        'welcomeTitle': 'AI स्वास्थ्य चैट में आपका स्वागत है',
        'welcomeMessage':
            'मैं आपके लक्षणों को समझने में आपकी मदद करने के लिए यहाँ हूँ। कृपया बताएं कि आप कैसा महसूस कर रहे हैं, और मैं मार्गदर्शन और सुझाव प्रदान करूंगा।',
        'typeMessage': 'अपने लक्षणों का वर्णन करें...',
        'disclaimer': 'महत्वपूर्ण अस्वीकरण',
        'disclaimerText':
            'यह AI सहायक केवल सामान्य स्वास्थ्य जानकारी प्रदान करता है। यह पेशेवर चिकित्सा सलाह, निदान या उपचार का विकल्प नहीं है। चिकित्सा संबंधी चिंताओं के लिए हमेशा योग्य स्वास्थ्य पेशेवरों से सलाह लें।',
        'retry': 'पुनः प्रयास करें',
        'severityHigh': 'उच्च गंभीरता',
        'severityModerate': 'मध्यम',
        'severityMild': 'हल्का',
      },
      'Punjabi': {
        'title': 'AI ਸਿਹਤ ਸਹਾਇਕ',
        'subtitle': 'ਆਪਣੇ ਲੱਛਣਾਂ ਬਾਰੇ AI ਨਾਲ ਗੱਲ ਕਰੋ',
        'welcomeTitle': 'AI ਸਿਹਤ ਚੈਟ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ',
        'welcomeMessage':
            'ਮੈਂ ਤੁਹਾਡੇ ਲੱਛਣਾਂ ਨੂੰ ਸਮਝਣ ਵਿੱਚ ਤੁਹਾਡੀ ਮਦਦ ਕਰਨ ਲਈ ਇੱਥੇ ਹਾਂ। ਕਿਰਪਾ ਕਰਕੇ ਦੱਸੋ ਕਿ ਤੁਸੀਂ ਕਿਵੇਂ ਮਹਿਸੂਸ ਕਰ ਰਹੇ ਹੋ, ਅਤੇ ਮੈਂ ਮਾਰਗਦਰਸ਼ਨ ਅਤੇ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਦਾਨ ਕਰਾਂਗਾ।',
        'typeMessage': 'ਆਪਣੇ ਲੱਛਣਾਂ ਦਾ ਵਰਣਨ ਕਰੋ...',
        'disclaimer': 'ਮਹੱਤਵਪੂਰਨ ਅਸਵੀਕਰਣ',
        'disclaimerText':
            'ਇਹ AI ਸਹਾਇਕ ਸਿਰਫ਼ ਆਮ ਸਿਹਤ ਜਾਣਕਾਰੀ ਪ੍ਰਦਾਨ ਕਰਦਾ ਹੈ। ਇਹ ਪੇਸ਼ੇਵਰ ਮੈਡੀਕਲ ਸਲਾਹ, ਨਿਦਾਨ ਜਾਂ ਇਲਾਜ ਦਾ ਵਿਕਲਪ ਨਹੀਂ ਹੈ। ਮੈਡੀਕਲ ਚਿੰਤਾਵਾਂ ਲਈ ਹਮੇਸ਼ਾ ਯੋਗ ਸਿਹਤ ਪੇਸ਼ੇਵਰਾਂ ਨਾਲ ਸਲਾਹ ਕਰੋ।',
        'retry': 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
        'severityHigh': 'ਉੱਚ ਗੰਭੀਰਤਾ',
        'severityModerate': 'ਮੱਧਮ',
        'severityMild': 'ਹਲਕਾ',
      },
    };

    return texts[language]?[key] ?? texts['English']![key] ?? '';
  }
}
