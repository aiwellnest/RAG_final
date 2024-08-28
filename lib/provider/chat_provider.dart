import 'package:ai_wellnest_frontend/provider/auth_provider.dart';
import 'package:ai_wellnest_frontend/repository/chat_repository.dart';
import 'package:ai_wellnest_frontend/screen/main_screen/widgets/message_chat.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatProvider extends ChangeNotifier {
  final ChatRepository chatRepository;
  String? _currentlySpeakingMessageId;
  final List<MessageChat> _messages = [];
  late String _sessionId = DateTime.now().toIso8601String();
  String? _selectedSessionId;
  final TextEditingController _messageController = TextEditingController();
  bool _isListening = false;
  late stt.SpeechToText _speechToText;

  ChatProvider(this.chatRepository) {
    chatRepository.onSpeechComplete = _onSpeechComplete;
  }

  String? get currentlySpeakingMessageId => _currentlySpeakingMessageId;
  String get sessionId => _sessionId;
  String? get selectedSessionId => _selectedSessionId;
  List<MessageChat> get messages => _messages;
  TextEditingController get messageController => _messageController;
  bool get isListening => _isListening;

  void startSpeaking(String messageId) {
    _currentlySpeakingMessageId = messageId;
    notifyListeners();
  }

  void stopSpeaking() {
    _currentlySpeakingMessageId = null;
    notifyListeners();
  }

  Future<void> speak(String message, String messageId) async {
    startSpeaking(messageId);
    await chatRepository.speak(message);
  }

  Future<void> stop() async {
    await chatRepository.stop();
    stopSpeaking();
  }

  void _onSpeechComplete() {
    stopSpeaking();
  }

  void startNewSession() {
    _sessionId = DateTime.now().toIso8601String();
    _messages.clear();
    notifyListeners();
  }

  Future<void> loadSession(String sessionId, AuthProvider authProvider) async {
    final history = await chatRepository.fetchHistory(
        authProvider.currentUser!.uid, sessionId);

    _sessionId = sessionId;
    _selectedSessionId = sessionId;
    _messages.clear();

    for (int i = history.length - 1; i >= 0; i--) {
      final item = history[i];
      final answer = item['answer'];
      final question = item['question'];

      if (answer != null && question != null) {
        _messages.add(MessageChat(
          message: answer,
          isSentByUser: false,
          username: 'AI Wellnest',
          id: UniqueKey(),
        ));
        _messages.add(MessageChat(
          message: question,
          isSentByUser: true,
          username: authProvider.currentUser!.username,
          id: UniqueKey(),
        ));
      } else {
        debugPrint('History is not a valid list');
      }
    }

    notifyListeners();
  }

  Future<void> sendMessage(AuthProvider authProvider) async {
    final message = _messageController.text.trim();

    if (message.isNotEmpty) {
      for (int i = 0; i < _messages.length; i++) {
        _messages[i] = MessageChat(
          message: _messages[i].message,
          isSentByUser: _messages[i].isSentByUser,
          username: _messages[i].username,
          animate: false,
          id: _messages[i].id,
        );
      }

      _messages.insert(
        0,
        MessageChat(
          message: message,
          isSentByUser: true,
          username: authProvider.currentUser!.username,
          animate: false,
          id: UniqueKey(),
        ),
      );
      _messageController.clear();
      notifyListeners();

      try {
        final history = await chatRepository.fetchHistory(
            authProvider.currentUser!.uid, _sessionId);

        final answer = await chatRepository.sendMessage(message, history);

        if (answer != null) {
          history.add({
            'question': message,
            'answer': answer,
          });

          await chatRepository.saveHistory(
              authProvider.currentUser!.uid, _sessionId, history);

          _messages.insert(
            0,
            MessageChat(
              message: answer,
              isSentByUser: false,
              username: 'AI Wellnest',
              animate: true,
              id: UniqueKey(),
            ),
          );
          notifyListeners();
        } else {
          debugPrint('Failed to get a valid response from the backend.');
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(onStatus: (val) {
        _isListening = val == 'listening';
        notifyListeners();
      }, onError: (val) {
        _isListening = false;
        notifyListeners();
      });

      if (available) {
        _isListening = true;
        notifyListeners();

        _speechToText.listen(onResult: (val) {
          _messageController.text = _formatText(val.recognizedWords);
          notifyListeners();
        });
      }
    } else {
      _isListening = false;
      notifyListeners();
      _speechToText.stop();
    }
  }

  String _formatText(String input) {
    final pattern = RegExp(r'([.!?])');
    return input
        .replaceAllMapped(pattern, (Match match) {
          return '${match.group(0)} ';
        })
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
