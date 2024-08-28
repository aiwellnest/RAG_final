import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _apiUrl;
  final FlutterTts _flutterTts = FlutterTts();

  ChatRepository() {
    _flutterTts.setCompletionHandler(() {
      onSpeechComplete?.call();
    });
    _fetchApiUrl();
  }

  Function? onSpeechComplete;

  /// Fetches the API URL from Firestore
  Future<void> _fetchApiUrl() async {
    try {
      final doc = await _firestore.collection('env').doc('api').get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('api_url')) {
          _apiUrl = data['api_url'];
        }
      }
    } catch (e) {
      debugPrint('Error fetching API URL: $e');
    }
  }

  /// Handles the text-to-speech functionality
  Future<void> speak(String message) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1);
    await _flutterTts.speak(message);
  }

  /// Stops any ongoing speech
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Fetches chat history for a specific user and session from Firestore
  Future<List<Map<String, String>>> fetchHistory(
      String userId, String sessionId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(sessionId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('history')) {
        final historyList = data['history'] as List<dynamic>;
        return historyList.map((item) {
          return Map<String, String>.from(item as Map<dynamic, dynamic>);
        }).toList();
      }
    }

    return [];
  }

  /// Sends a message to the backend and retrieves the AI's response
  Future<String?> sendMessage(
      String message, List<Map<String, String>> history) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl!),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({
          'question': message,
          'history': history,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['answer'];
      } else {
        debugPrint('Failed to send the message: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  /// Saves the chat history to Firestore
  Future<void> saveHistory(String userId, String sessionId,
      List<Map<String, String>> history) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(sessionId)
        .set({
      'history': history,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
