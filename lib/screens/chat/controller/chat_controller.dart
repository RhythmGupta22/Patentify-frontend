import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart'; // Still needed for ChatMessage type
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var patentLinks = <String>[].obs;
  RxBool isLoading = false.obs; // New loading state

  void sendMessage(String text) async {
    isLoading.value = true; // Start loading
    try {
      // Add user's message
      final userMessage = ChatMessage(
        user: ChatUser(id: 'user', firstName: 'You'),
        text: text,
        createdAt: DateTime.now(),
      );
      messages.add(userMessage);

      // Call backend API and get response
      final response = await _fetchBotResponse(text);
      final botMessage = _parseBackendResponse(response);
      messages.add(botMessage);
    } catch (e, stackTrace) {
      print('Error in sendMessage: $e');
      print('Stack trace: $stackTrace');
      messages.add(ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Oops! Something went wrong: $e',
        createdAt: DateTime.now(),
      ));
    }
    finally {
      isLoading.value = false; // Stop loading
    }
  }

  Future<String> _fetchBotResponse(String userMessage) async {
    try {
      final url = Uri.parse('https://pzfllzns-8000.inc1.devtunnels.ms/patents/search');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idea': userMessage}),
      );

      if (response.statusCode == 200) {
        print('Backend response: ${response.body}');
        return response.body;
      } else {
        throw Exception('Failed to get response: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error: Unable to connect to the server');
    } on FormatException catch (e) {
      print('Format error: $e');
      throw Exception('Invalid response format from server');
    } catch (e, stackTrace) {
      print('Unexpected error in _fetchBotResponse: $e');
      print('Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  ChatMessage _parseBackendResponse(String responseBody) {
    try {
      final jsonResponse = json.decode(responseBody);

      // Check if required fields exist
      if (jsonResponse['success'] != true || jsonResponse['data'] == null) {
        throw FormatException('Invalid response: Success is not true or data is missing');
      }

      final data = jsonResponse['data'];
      final userJson = data['user'];
      if (userJson == null || userJson['id'] == null) {
        throw FormatException('Invalid response: User data is missing or incomplete');
      }

      final overview = data['overview'] as String? ?? 'No overview provided';
      final patents = data['patents'] as List<dynamic>? ?? [];
      print("patents");
      print(patents);

      // Build HTML formatted message
      final messageContent = StringBuffer()
        ..writeln(overview)
        ..writeln('<br>'); // HTML line break

      if (patents.isNotEmpty) {
        messageContent.writeln('<h3><strong>Related Patents:</strong></h3>');
        messageContent.writeln('<ul>');

        for (final patent in patents) {
          final link = patent['patent_link'] ?? '#';
          print("link");
          print(link);
          final title = patent['title'] as String? ?? 'Untitled Patent';
          final number = patent['number'] as String?;

          messageContent.writeln('  <li>');
          messageContent.write('    <a href= $link target="_blank">$title</a>');
          if (number != null) {
            messageContent.write(' (Patent $number)');
          }
          messageContent.writeln();
          messageContent.writeln('  </li>');

          patentLinks.add(link);
        }

        messageContent.writeln('</ul>');
      }
      else {
        messageContent.writeln('<i>No related patents found.</i>');
      }

      return ChatMessage(
        user: ChatUser(
          id: userJson['id'] as String,
          firstName: userJson['firstName'] as String?,
        ),
        text: messageContent.toString(),
        createdAt: DateTime.now(), // Use current time since response doesn't provide one
      );
    } on FormatException catch (e) {
      print('Parsing error: $e');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Error parsing response: $e',
        createdAt: DateTime.now(),
      );
    } on TypeError catch (e) {
      print('Type error: $e');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Invalid data type in response: $e',
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Unexpected error in _parseBackendResponse: $e');
      print('Stack trace: $stackTrace');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Unexpected error processing response: $e',
        createdAt: DateTime.now(),
      );
    }
  }

  void clearChat() {
    try {
      messages.clear();
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }
}