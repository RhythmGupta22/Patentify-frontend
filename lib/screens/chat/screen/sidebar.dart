import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onToggle;
  final VoidCallback onNewChat;

  const Sidebar({
    super.key,
    required this.onToggle,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          right: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with Search Icon
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Recent Chats',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                      onPressed: () {
                        // Add your search functionality here
                        debugPrint('Search button pressed');
                      },
                      tooltip: 'Search chats',
                    ),
                    IconButton(
                      onPressed: onNewChat,
                      color: Colors.white,
                      icon: Icon(Icons.add),padding: EdgeInsets.all(0),
                    ),
                  ],
                ),

              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
          // New Chat Button
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ListTile(title: Text('Solar panel innovations'),contentPadding: EdgeInsets.all(0),),
                    ListTile(title: Text('Battery tech mashup'),contentPadding: EdgeInsets.all(0),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}