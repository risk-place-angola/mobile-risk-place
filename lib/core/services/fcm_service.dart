import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background message received: ${message.messageId}', name: 'FCM');

  if (message.notification != null) {
    log('Background notification: ${message.notification!.title}', name: 'FCM');
  }

  if (message.data.isNotEmpty) {
    log('Background data: ${message.data}', name: 'FCM');
  }
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  Function(RemoteMessage)? _onMessageReceived;
  Function(RemoteMessage)? _onMessageOpenedApp;

  Future<void> initialize({
    Function(RemoteMessage)? onMessageReceived,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    try {
      _onMessageReceived = onMessageReceived;
      _onMessageOpenedApp = onMessageOpenedApp;

      await _requestPermissions();
      await _getToken();
      _setupMessageHandlers();
      _setupTokenRefreshListener();

      log('FCM initialized successfully', name: 'FCMService');
    } catch (e) {
      log('FCM initialization error: $e', name: 'FCMService');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
      announcement: false,
      carPlay: false,
    );

    log('Permission status: ${settings.authorizationStatus}',
        name: 'FCMService');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission', name: 'FCMService');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission', name: 'FCMService');
    } else {
      log('User declined permission', name: 'FCMService');
    }
  }

  Future<String?> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (_fcmToken == null) {
        log('Waiting for APNS token...', name: 'FCMService');
        await Future.delayed(const Duration(seconds: 2));
        _fcmToken = await _messaging.getToken();

        if (_fcmToken == null) {
          log('Retrying FCM token...', name: 'FCMService');
          await Future.delayed(const Duration(seconds: 3));
          _fcmToken = await _messaging.getToken();
        }
      }

      if (_fcmToken != null) {
        log('FCM Token: $_fcmToken', name: 'FCMService');
      } else {
        log('Failed to get FCM token', name: 'FCMService');
      }

      return _fcmToken;
    } catch (e) {
      log('Error getting FCM token: $e', name: 'FCMService');
      return null;
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message: ${message.messageId}', name: 'FCMService');

      if (message.notification != null) {
        log('Notification title: ${message.notification!.title}',
            name: 'FCMService');
        log('Notification body: ${message.notification!.body}',
            name: 'FCMService');
      }

      if (message.data.isNotEmpty) {
        log('Message data: ${message.data}', name: 'FCMService');
      }

      _onMessageReceived?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Message opened app: ${message.messageId}', name: 'FCMService');
      _onMessageOpenedApp?.call(message);
    });
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String newToken) {
      log('FCM token refreshed: $newToken', name: 'FCMService');
      _fcmToken = newToken;
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic', name: 'FCMService');
    } catch (e) {
      log('Error subscribing to topic: $e', name: 'FCMService');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic', name: 'FCMService');
    } catch (e) {
      log('Error unsubscribing from topic: $e', name: 'FCMService');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      log('FCM token deleted', name: 'FCMService');
    } catch (e) {
      log('Error deleting FCM token: $e', name: 'FCMService');
    }
  }

  String? get token => _fcmToken;

  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}
