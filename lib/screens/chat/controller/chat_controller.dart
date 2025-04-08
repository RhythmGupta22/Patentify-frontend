import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var patentLinks = <String>[].obs;
  RxBool isLoading = false.obs;
  var selectedPatents = <Map<String, String>>[].obs; // Store selected title and link

  void sendMessage(String text) async {
    isLoading.value = true;
    try {
      final userMessage = ChatMessage(
        user: ChatUser(id: 'user', firstName: 'You'),
        text: text,
        createdAt: DateTime.now(),
      );
      messages.add(userMessage);

      final response = await _fetchBotResponse(text);
      final botMessage = _parseBackendResponse(response);
      messages.add(botMessage);
    } catch (e, stackTrace) {
      print('Error in sendMessage: $e');
      print('Stack trace: $stackTrace');
      messages.add(ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Oops! Something went wrong',
        createdAt: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void generateMashup(String idea) async {
    if (selectedPatents.isEmpty) {
      Get.snackbar('Error', 'Please select at least one patent before generating a mashup.');
      return;
    }

    isLoading.value = true;
    try {
      final userMessage = ChatMessage(
        user: ChatUser(id: 'user', firstName: 'You'),
        text: 'Generating mashup for: $idea with ${selectedPatents.length} selected patent(s)',
        createdAt: DateTime.now(),
      );
      messages.add(userMessage);

      final response = await _fetchMashupResponse(idea, selectedPatents);
      final botMessage = _parseMashupResponse(response);
      messages.add(botMessage);
    } catch (e, stackTrace) {
      print('Error in generateMashup: $e');
      print('Stack trace: $stackTrace');
      messages.add(ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Oops! Something went wrong while generating mashup',
        createdAt: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
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
      throw Exception('Network error: Unable to connect to the server');
    } catch (e, stackTrace) {
      print('Unexpected error in _fetchBotResponse: $e');
      print('Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> _fetchMashupResponse(String idea, List<Map<String, String>> patents) async {
    try {
      final url = Uri.parse('https://pzfllzns-8000.inc1.devtunnels.ms/mashup/generate');
      final requestBody = {
        "patents": patents.map((patent) => {
          "title": patent["title"],
          "snippet": patent["link"] // Using link as snippet since no snippet is provided
        }).toList(),
        "idea": idea,
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Mashup response: ${response.body}');
        return response.body;
      } else {
        throw Exception('Failed to generate mashup: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Unable to connect to the server');
    } catch (e, stackTrace) {
      print('Unexpected error in _fetchMashupResponse: $e');
      print('Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  ChatMessage _parseBackendResponse(String responseBody) {
    try {
      final jsonResponse = json.decode(responseBody);

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

      final messageContent = StringBuffer();
      messageContent.writeln('<h3>$overview</h3>');
      messageContent.writeln('<br>');

      if (patents.isNotEmpty) {
        messageContent.writeln('<h3><strong>Related Patents:</strong></h3>');
        messageContent.writeln('<ul>');

        for (final patent in patents) {
          final link = patent['pdf_url'] ?? '#';
          final title = patent['title'] as String? ?? 'Untitled Patent';
          final number = patent['number'] as String?;

          messageContent.writeln('  <li>');
          messageContent.write('    <a href="$link" target="_blank">$title</a>');
          if (number != null) {
            messageContent.write(' (Patent $number)');
          }
          messageContent.writeln();
          messageContent.writeln('  </li>');

          patentLinks.add(link);
        }

        messageContent.writeln('</ul>');
      } else {
        messageContent.writeln('<i>No related patents found.</i>');
      }

      return ChatMessage(
        user: ChatUser(
          id: userJson['id'] as String,
          firstName: userJson['firstName'] as String?,
        ),
        text: messageContent.toString(),
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Error in _parseBackendResponse: $e');
      print('Stack trace: $stackTrace');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Unexpected error processing response',
        createdAt: DateTime.now(),
      );
    }
  }

  ChatMessage _parseMashupResponse(String responseBody) {
    try {
      final jsonResponse = json.decode(responseBody);

      if (jsonResponse['success'] != true || jsonResponse['data'] == null) {
        throw FormatException('Invalid mashup response: Success is not true or data is missing');
      }

      final data = jsonResponse['data'];
      final title = data['title'] as String? ?? 'Untitled Mashup';
      final summary = data['summary'] as String? ?? 'No summary provided';
      final abstract = data['abstract'] as String? ?? 'No abstract provided';

      // Build a nicely formatted HTML string
      final messageContent = StringBuffer()
        ..writeln('<h2 style="color: #ffffff; font-weight: bold;">$title</h2>')
        ..writeln('<br>')
        ..writeln('<h3 style="color: #b4b4b4;">Summary</h3>')
        ..writeln('<p style="color: #ffffff;">$summary</p>')
        ..writeln('<br>')
        ..writeln('<h3 style="color: #b4b4b4;">Abstract</h3>')
        ..writeln('<p style="color: #ffffff;">$abstract</p>');

      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: messageContent.toString(),
        createdAt: DateTime.now(),
      );
    } on FormatException catch (e) {
      print('Parsing error: $e');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Error parsing mashup response: $e',
        createdAt: DateTime.now(),
      );
    } on TypeError catch (e) {
      print('Type error: $e');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Invalid data type in mashup response: $e',
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Unexpected error in _parseMashupResponse: $e');
      print('Stack trace: $stackTrace');
      return ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Unexpected error processing mashup response: $e',
        createdAt: DateTime.now(),
      );
    }
  }

  void togglePatentSelection(String title, String link) {
    final patent = {"title": title, "link": link};
    final existingIndex = selectedPatents.indexWhere((p) => p["link"] == link);
    if (existingIndex >= 0) {
      selectedPatents.removeAt(existingIndex);
    } else {
      selectedPatents.add(patent);
    }
    print('Selected patents: $selectedPatents');
  }

  void clearChat() {
    try {
      messages.clear();
      patentLinks.clear();
      selectedPatents.clear();
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }
}