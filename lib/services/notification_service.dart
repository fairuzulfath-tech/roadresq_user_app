class NotificationService {
  Future<void> initialize() async {
    // Stub: In real app, initialize Firebase Messaging
    // FirebaseMessaging.instance.requestPermission()
    // etc.
  }

  Future<void> subscribeToTopic(String topic) async {
    // Stub: FirebaseMessaging.instance.subscribeToTopic(topic)
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // Stub: FirebaseMessaging.instance.unsubscribeFromTopic(topic)
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Stub: In real app, use flutter_local_notifications
    // Show a local notification
  }

  Future<String?> getToken() async {
    // Stub: return FirebaseMessaging.instance.getToken()
    return 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}
