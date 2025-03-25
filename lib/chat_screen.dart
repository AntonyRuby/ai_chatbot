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
  final List<Map<String, String>> _messages = []; // Storing sender info & message
  bool _isListening = false;

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
      });
      _controller.clear();

      try {
        String response = await _apiService.getResponse(userInput);
        setState(() {
          _messages.add({"sender": "AI", "message": response});
        });
        _speechService.speak(response);
      } catch (e) {
        setState(() {
          _messages.add({"sender": "AI", "message": "Oops! Something went wrong."});
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
    setState(() => _isListening = false);
    await _speechService.stopListening();
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
                    child: Text(
                      _messages[index]["message"]!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
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
                      fillColor: Colors.grey[200], // Better than solid grey
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
        ],
      ),
    );
  }
}
