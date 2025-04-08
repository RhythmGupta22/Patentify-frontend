import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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


  Future<void> generateTimeline(String idea) async {
    print("kkkkkkk");
    print(idea);


    isLoading.value = true;
    try {
      final userMessage = ChatMessage(
        user: ChatUser(id: 'user', firstName: 'You'),
        text: 'Generating timeline for $idea selected patent(s)',
        createdAt: DateTime.now(),
      );
      messages.add(userMessage);

      final response = await _fetchTimelineResponse(idea);
      _showTimelinePopup(response);
    } catch (e, stackTrace) {
      print('Error in generateTimeline: $e');
      print('Stack trace: $stackTrace');
      messages.add(ChatMessage(
        user: ChatUser(id: 'bot', firstName: 'Patentify'),
        text: 'Oops! Something went wrong while generating timeline',
        createdAt: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _fetchTimelineResponse(String idea) async {
    try {
      final url = Uri.parse('https://pzfllzns-8000.inc1.devtunnels.ms/timeline'); // Adjust endpoint as needed
      final requestBody = {
        "idea": idea
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Timeline response: ${response.body}');
        return response.body;
      } else {
        throw Exception('Failed to generate timeline: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Unable to connect to the server');
    } catch (e, stackTrace) {
      print('Unexpected error in _fetchTimelineResponse: $e');
      print('Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  void _showTimelinePopup(String responseBody) {
    try {
      final jsonResponse = json.decode(responseBody);

      if (jsonResponse['success'] != true || jsonResponse['data'] == null) {
        throw FormatException('Invalid timeline response: Success is not true or data is missing');
      }

      final data = jsonResponse['data'];
      final filingTrend = (data['filing_trend'] as List<dynamic>).map((e) => TrendData(e['year'], e['count'])).toList();
      final publicationTrend = (data['publication_trend'] as List<dynamic>).map((e) => TrendData(e['year'], e['count'])).toList();
      final statusDistribution = (data['status_distribution'] as List<dynamic>).map((e) => DistributionData(e['status'], e['count'])).toList();
      final topAssignees = (data['top_assignees'] as List<dynamic>).map((e) => AssigneeData(e['assignee'], e['count'])).toList();

      Get.dialog(
        Dialog(
          backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patent Timeline Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLineChart('Filing Trend', filingTrend, Colors.blue),
                  const SizedBox(height: 24),
                  _buildLineChart('Publication Trend', publicationTrend, Colors.green),
                  const SizedBox(height: 24),
                  _buildBarChart('Status Distribution', statusDistribution),
                  const SizedBox(height: 24),
                  _buildBarChart('Top Assignees', topAssignees),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromRGBO(66, 66, 66, 1),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error in _showTimelinePopup: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to display timeline: $e');
    }
  }

  Widget _buildLineChart(String title, List<TrendData> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(drawHorizontalLine: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    );
                  }),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    );
                  }),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white70, width: 0.5)),
              lineBarsData: [
                LineChartBarData(
                  spots: data.map((e) => FlSpot(e.year.toDouble(), e.count.toDouble())).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String title, List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: data.asMap().entries.map((entry) {
                final item = entry.value;
                final index = entry.key;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (item is DistributionData ? item.count : (item as AssigneeData).count).toDouble(),
                      color: Colors.blueAccent,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    );
                  }),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        final item = data[index];
                        final label = item is DistributionData ? item.status : (item as AssigneeData).assignee;
                        return SideTitleWidget(
                          meta: TitleMeta(min: 0, max: 10, parentAxisSize: 5, axisPosition: 0.0, appliedInterval: 3, sideTitles: SideTitles(), formattedValue: '', axisSide: AxisSide.bottom, rotationQuarterTurns: 1),
                          child: Text(
                            label.length > 10 ? '${label.substring(0, 10)}...' : label,
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white70, width: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

// Data classes for parsing
class TrendData {
  final int year;
  final int count;

  TrendData(this.year, this.count);
}

class DistributionData {
  final String status;
  final int count;

  DistributionData(this.status, this.count);
}

class AssigneeData {
  final String assignee;
  final int count;

  AssigneeData(this.assignee, this.count);
}
