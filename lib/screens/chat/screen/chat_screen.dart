import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' show parse;
import 'package:patentify/screens/authentication/controller/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/chat_controller.dart' as cl;
import 'sidebar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cl.ChatController chatController = Get.find();
    final TextEditingController messageController = TextEditingController();
    final RxBool isSidebarOverlaid = false.obs;
    final RxString selectedButton = ''.obs;

    // Function to extract URLs from HTML string
    List<String> extractUrls(String htmlString) {
      final document = parse(htmlString);
      final links = document.getElementsByTagName('a');
      return links
          .map((link) => link.attributes['href'] ?? '')
          .where(
              (url) => url.isNotEmpty && Uri.tryParse(url)?.hasScheme == true)
          .toList();
    }

    return Scaffold(
      body: Obx(() => Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSidebarOverlaid.value ? 280 : 0,
                child: Sidebar(
                  onToggle: () =>
                      isSidebarOverlaid.value = !isSidebarOverlaid.value,
                  onNewChat: chatController.clearChat,
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color.fromRGBO(33, 33, 33, 1),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isSidebarOverlaid.value
                                        ? Icons.menu_open
                                        : Icons.menu,
                                    color:
                                        const Color.fromRGBO(180, 180, 180, 1),
                                  ),
                                  onPressed: () => isSidebarOverlaid.value =
                                      !isSidebarOverlaid.value,
                                ),
                                const SizedBox(width: 8),
                                const Text('Patentify',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color.fromRGBO(180, 180, 180, 1),
                                        fontSize: 20)),
                              ],
                            ),
                            Obx(() {
                              final user = AuthController.user.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Tooltip(
                                  message: 'profile',
                                  child: PopupMenuButton<String>(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.all(0),
                                    tooltip: 'profile',shadowColor: Colors.transparent,
                                    offset: const Offset(
                                        -30, -70),
                                    icon: CachedNetworkImage(
                                      imageUrl: user?.photoURL ?? '',
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        radius: 17,
                                        backgroundImage: imageProvider,
                                        backgroundColor: Colors.grey,
                                      ),
                                      placeholder: (context, url) =>
                                          const CircleAvatar(
                                        radius: 17,
                                        backgroundColor: Colors.grey,
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const CircleAvatar(
                                        radius: 17,
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.person,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'logout') {
                                        AuthController().signOut();
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem<String>(
                                        value: 'logout',
                                        padding: EdgeInsets
                                            .zero, // Remove default padding
                                        child: Container(
                                          color: Colors
                                              .transparent, // Make background transparent
                                          child: OutlinedButton(
                                            onPressed: () {
                                              AuthController()
                                                  .signOut(); // Trigger logout on press
                                              Navigator.pop(
                                                  context); // Close the popup
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Colors.white24),
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.2),
                                              foregroundColor: Colors.white70,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: const Text(
                                              'Logout',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          if (chatController.messages.isEmpty) {
                            return Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 800),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Patent ',
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'queries? Ask me',
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w100,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 800),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color.fromRGBO(
                                                180, 180, 180, 1),
                                            width: 0.3,
                                          ),
                                          color: const Color.fromRGBO(
                                              66, 66, 66, 1),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            TextField(
                                              cursorColor: Colors.white,
                                              controller: messageController,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: 'Ask anything...',
                                                hintStyle: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      180, 180, 180, 1),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 5),
                                                suffixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.mic),
                                                    color: const Color.fromRGBO(
                                                        180, 180, 180, 1),
                                                    onPressed: () {
                                                      debugPrint(
                                                          'Mic button pressed');
                                                    },
                                                  ),
                                                ),
                                              ),
                                              onSubmitted: (_) {
                                                final text = messageController
                                                    .text
                                                    .trim();
                                                if (text.isNotEmpty) {
                                                  chatController
                                                      .sendMessage(text);
                                                  messageController.clear();
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _buildButton(
                                                  icon:
                                                      Icons.attachment_rounded,
                                                  text: 'Attach',
                                                  onTap: () => debugPrint(
                                                      'Attach button pressed'),
                                                ),
                                                const SizedBox(width: 11),
                                                _buildButton(
                                                  icon: FontAwesomeIcons.mixer,
                                                  text: 'Mashup',
                                                  isSelected:
                                                      selectedButton.value ==
                                                          'mashup',
                                                  onTap: () {
                                                    selectedButton.value =
                                                        selectedButton.value ==
                                                                'mashup'
                                                            ? ''
                                                            : 'mashup';
                                                  },
                                                ),
                                                const SizedBox(width: 11),
                                                _buildButton(
                                                  icon: FontAwesomeIcons.clock,
                                                  text: 'Timeline',
                                                  isSelected:
                                                      selectedButton.value ==
                                                          'timeline',
                                                  onTap: () {
                                                    selectedButton.value =
                                                        selectedButton.value ==
                                                                'timeline'
                                                            ? ''
                                                            : 'timeline';
                                                  },
                                                ),
                                                const Spacer(),
                                                Container(
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.send,
                                                        size: 19),
                                                    color: const Color.fromRGBO(
                                                        66, 66, 66, 1),
                                                    onPressed: () {
                                                      final text =
                                                          messageController.text
                                                              .trim();
                                                      if (text.isNotEmpty) {
                                                        chatController
                                                            .sendMessage(text);
                                                        messageController
                                                            .clear();
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: chatController.messages.length,
                            itemBuilder: (context, index) {
                              if (chatController.isLoading.value &&
                                  index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 225),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 17,
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.auto_awesome,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Patentify",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                CircularProgressIndicator(
                                                  color: Colors.white70,
                                                  strokeWidth: 2,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Thinking...",
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final reversedIndex =
                                  chatController.messages.length - 1 - index;
                              final message =
                                  chatController.messages[reversedIndex];
                              final isUser = message.user.id == "user";
                              final urls = extractUrls(message.text.toString());

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 225),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: isUser
                                          ? AuthController
                                                  .user.value?.photoURL ??
                                              ''
                                          : '',
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        isUser
                                            ? Icons.person
                                            : Icons.auto_awesome,
                                        color: Colors.white,
                                      ),
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        radius: 17,
                                        backgroundImage: imageProvider,
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isUser
                                                ? AuthController.user.value
                                                        ?.displayName ??
                                                    "user"
                                                : "Patentify",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Html(
                                            data: message.text.toString(),
                                            style: {
                                              "body":
                                                  Style(color: Colors.white70),
                                              "a": Style(
                                                  color: Colors.blue,
                                                  textDecoration:
                                                      TextDecoration.none),
                                            },
                                            onLinkTap: (url, _, __) {
                                              if (url != null) {
                                                _launchUrl(url);
                                              }
                                            },
                                          ),
                                          // if (urls.isNotEmpty)
                                          //   ...urls.map((url) => Padding(
                                          //     padding: const EdgeInsets.symmetric(vertical: 8),
                                          //     child: _previewLink(url),
                                          //   )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      if (chatController.messages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color.fromRGBO(180, 180, 180, 1),
                                  width: 0.3,
                                ),
                                color: const Color.fromRGBO(66, 66, 66, 1),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(
                                    cursorColor: Colors.white,
                                    controller: messageController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Ask anything...',
                                      hintStyle: const TextStyle(
                                        color: Color.fromRGBO(180, 180, 180, 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.only(left: 5),
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2),
                                        child: IconButton(
                                          icon: const Icon(Icons.mic),
                                          color: const Color.fromRGBO(
                                              180, 180, 180, 1),
                                          onPressed: () {
                                            debugPrint('Mic button pressed');
                                          },
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (_) {
                                      final text =
                                          messageController.text.trim();
                                      if (text.isNotEmpty) {
                                        chatController.sendMessage(text);
                                        messageController.clear();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildButton(
                                        icon: Icons.attachment_rounded,
                                        text: 'Attach',
                                        onTap: () =>
                                            debugPrint('Attach button pressed'),
                                      ),
                                      const SizedBox(width: 11),
                                      _buildButton(
                                        icon: FontAwesomeIcons.mixer,
                                        text: 'Mashup',
                                        isSelected:
                                            selectedButton.value == 'mashup',
                                        onTap: () {
                                          selectedButton.value =
                                              selectedButton.value == 'mashup'
                                                  ? ''
                                                  : 'mashup';
                                        },
                                      ),
                                      const SizedBox(width: 11),
                                      _buildButton(
                                        icon: FontAwesomeIcons.clock,
                                        text: 'Timeline',
                                        isSelected:
                                            selectedButton.value == 'timeline',
                                        onTap: () {
                                          selectedButton.value =
                                              selectedButton.value == 'timeline'
                                                  ? ''
                                                  : 'timeline';
                                        },
                                      ),
                                      const Spacer(),
                                      Container(
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: IconButton(
                                          icon:
                                              const Icon(Icons.send, size: 19),
                                          color: const Color.fromRGBO(
                                              66, 66, 66, 1),
                                          onPressed: () {
                                            final text =
                                                messageController.text.trim();
                                            if (text.isNotEmpty) {
                                              chatController.sendMessage(text);
                                              messageController.clear();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 0.3,
          color: const Color.fromRGBO(180, 180, 180, 1),
        ),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color.fromRGBO(66, 66, 66, 1)
                    : const Color.fromRGBO(180, 180, 180, 1),
                size: 17,
              ),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? const Color.fromRGBO(66, 66, 66, 1)
                      : const Color.fromRGBO(180, 180, 180, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to launch URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  Widget _previewLink(String url) {
    return LinkPreview(
      linkStyle: const TextStyle(color: Colors.blue),
      metadataTextStyle: const TextStyle(fontSize: 14, color: Colors.white70),
      padding: const EdgeInsets.symmetric(vertical: 8),
      previewData: null, // Let it fetch automatically
      onPreviewDataFetched: (data) {
        print('Preview loaded for $data');
      },
      openOnPreviewImageTap: true,
      openOnPreviewTitleTap: true,
      text: url,
      hideImage: false,
      enableAnimation: true,
      width: MediaQuery.of(Get.context!).size.width * 0.8,
    );
  }
}
