import 'package:get/get.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  void sendMessage(String content) {
    messages.add(ChatMessage(
      role: 'user',
      content: content,
    ));
    _generateResponse(content);
  }

  void _generateResponse(String userInput) async {
    String response;
    try {
      if (userInput.toLowerCase().contains('mashup')) {
        response = await _handleMashupRequest(userInput);
      } else if (userInput.toLowerCase().contains('search')) {
        response = await _handleSearchRequest(userInput);
      } else {
        response = 'I can help with patent searches or mashups. Try "search solar panels" or "mashup solar tech with battery storage".';
      }
    } catch (e) {
      response = 'Oops, something went wrong: $e';
    }

    messages.add(ChatMessage(
      role: 'assistant',
      content: response,
    ));
  }

  Future<String> _handleSearchRequest(String query) async {
    return 'Searching for "$query"... (API integration pending)';
  }

  Future<String> _handleMashupRequest(String query) async {
    return 'Mashing up "$query"... (API integration pending)';
  }

  void clearChat() {
    messages.clear();
  }
}