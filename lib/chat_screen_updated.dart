import 'package:flutter/material.dart';
import 'api_service.dart';
import 'speech_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final SpeechService _speechService = SpeechService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isListening = false;
  bool _isTTSActive = true; // Toggle for TTS functionality
  bool _isTyping = false; // Typing indicator

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initializeSpeech();
  }

  void _sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "You", "message": userInput});
        _isTyping = true; // Show typing indicator
        _isListening = false; // Ensure mic icon resets
      });
      _controller.clear();

      await Future.delayed(const Duration(seconds: 1));

      try {
        String response = await _apiService.getResponse(userInput);
        setState(() {
          _messages.add({"sender": "AI", "message": response});
          _isTyping = false; // Hide typing indicator
        });
        if (_isTTSActive) {
          _speechService.speak(response);
        }
      } catch (e) {
        setState(() {
          _messages.add({"sender": "AI", "message": "Oops! Something went wrong."});
          _isTyping = false;
        });
      }
    }
  }

  void _startListening() async {
    setState(() => _isListening = true);
    await _speechService.startListening((result) {
      setState(() {
        _controller.text = result; // Updates when the user speaks
      });
    });
  }

  void _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false); // Revert to mic icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isAI = _messages[index]["sender"] == "AI";
                return Align(
                  alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAI ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAI) ...[
                          const CircleAvatar(
                            backgroundColor: Colors.blue, // Distinct color for AI
                            child: Icon(Icons.android, color: Colors.white), // AI Avatar
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _messages[index]["message"]!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (!isAI) ...[
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            backgroundColor: Colors.green, // Distinct color for User
                            child: Icon(Icons.person, color: Colors.white), // User Avatar
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping) // Typing indicator
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("AI is typing...", style: TextStyle(color: Colors.grey)),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.red),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text("Enable AI Voice Response"),
            value: _isTTSActive,
            onChanged: (value) {
              setState(() {
                _isTTSActive = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
