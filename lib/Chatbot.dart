import 'package:feelings/Chatservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// ✅ 1. Re-introduced a type-safe ChatMessage class for better code quality.
enum ChatUser { user, bot }

class ChatMessage {
  final String text;
  final ChatUser author;

  ChatMessage({required this.text, required this.author});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isBotResponding = false;
  // ✅ 2. Removed the '_mode' state variable as it's no longer needed.

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, author: ChatUser.user));
      _isBotResponding = true;
      _controller.clear();
    });

    // ✅ 3. Simplified the API call to match the latest ChatService.
    final response = await _chatService.getAIResponse(text);

    setState(() {
      _messages.add(ChatMessage(text: response, author: ChatUser.bot));
      _isBotResponding = false;
    });
  }

  // ✅ 4. Themed the message bubbles to match our app's aesthetic.
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.author == ChatUser.user;

    // Define separate text styles for user (white) and bot (dark)
    final userTextStyle = TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.95));
    final botTextStyle = TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8));

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6B5B95) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: MarkdownBody(
          data: message.text,
          selectable: true,
          // ✅ 5. Correctly applied the stylesheet for Markdown.
          styleSheet: MarkdownStyleSheet(
            p: isUser ? userTextStyle : botTextStyle,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the gradient to flow behind the AppBar
      appBar: AppBar(
        title: const Text("Chat with Manas"),
        backgroundColor: Colors.transparent, // ✅ Themed AppBar
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        // ✅ 6. Applied the calming gradient background.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0BBE4), // Light Violet
              Color(0xFF957DAD), // Medium Violet
              Color(0xFFD291BC), // Pinkish Violet
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
              if (_isBotResponding)
                 Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                      const SizedBox(width: 10),
                      Text("Manas is thinking...", style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    // ✅ 7. Themed the text input area.
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Talk about what's on your mind...",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Removed the mode toggle button
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF6B5B95)),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9)),
                      onPressed: _isBotResponding ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}