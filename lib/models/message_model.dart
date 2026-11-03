class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  static List<MessageModel> mockMessages(String userId, String mechanicId) => [
        MessageModel(
          id: 'msg_001',
          senderId: mechanicId,
          receiverId: userId,
          text: 'Hello! I have received your request. I am on my way to help you.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          isRead: true,
        ),
        MessageModel(
          id: 'msg_002',
          senderId: userId,
          receiverId: mechanicId,
          text: 'Thank you! I am near the main gate of the society.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
          isRead: true,
        ),
        MessageModel(
          id: 'msg_003',
          senderId: mechanicId,
          receiverId: userId,
          text: 'Got it! I will be there in approximately 5 minutes. Please keep the car accessible.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          isRead: true,
        ),
        MessageModel(
          id: 'msg_004',
          senderId: mechanicId,
          receiverId: userId,
          text: 'I can see your location on the map. Almost there! 🚗',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isRead: false,
        ),
      ];
}
