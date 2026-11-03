import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages(String requestId) async {
    _setLoading(true);
    _error = null;
    try {
      _messages = await _firestoreService.getMessages(requestId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String receiverId,
  }) async {
    if (text.trim().isEmpty) return;

    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      text: text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add locally immediately for instant UI update
    _messages = [..._messages, message];
    notifyListeners();

    try {
      await _firestoreService.sendMessage(message);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void markAsRead() {
    _messages = _messages.map((m) => MessageModel(
      id: m.id,
      senderId: m.senderId,
      receiverId: m.receiverId,
      text: m.text,
      timestamp: m.timestamp,
      isRead: true,
    )).toList();
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
