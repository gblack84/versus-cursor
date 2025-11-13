import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/logging/logger_service.dart';

/// Firebase Cloud Messaging Service
///
/// Handles FCM token management, message reception, and notification processing.
/// Works in conjunction with NotificationQueueService for in-app display.
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Stream controller for incoming FCM messages
  final _messageController = StreamController<RemoteMessage>.broadcast();

  /// Stream of incoming FCM messages
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  /// Current FCM token
  String? _currentToken;
  String? get currentToken => _currentToken;

  /// Whether FCM is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize FCM
  ///
  /// Requests notification permissions and sets up message handlers.
  /// Must be called before using FCM features.
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.warning('FCMService already initialized', tag: 'FCMService');
      return;
    }

    try {
      Logger.info('Initializing FCM Service', tag: 'FCMService');

      // Request notification permissions
      final settings = await _requestPermission();

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        Logger.warning(
          'Notification permission not granted: ${settings.authorizationStatus}',
          tag: 'FCMService',
        );
        return;
      }

      // Get FCM token
      _currentToken = await _messaging.getToken();
      Logger.info('FCM Token: $_currentToken', tag: 'FCMService');

      // Save token to Firestore
      if (_currentToken != null) {
        await _saveTokenToFirestore(_currentToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        Logger.info('FCM Token refreshed: $newToken', tag: 'FCMService');
        _currentToken = newToken;
        _saveTokenToFirestore(newToken);
      });

      // Set up message handlers
      _setupMessageHandlers();

      _isInitialized = true;
      Logger.info('FCM Service initialized successfully', tag: 'FCMService');
    } catch (e) {
      Logger.error('Failed to initialize FCM Service', error: e, tag: 'FCMService');
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Logger.info(
      'Notification permission: ${settings.authorizationStatus}',
      tag: 'FCMService',
    );

    return settings;
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages (app is active)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.debug(
        'Foreground message received: ${message.notification?.title}',
        tag: 'FCMService',
      );
      _handleForegroundMessage(message);
    });

    // Background messages (app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.debug(
        'Background message opened: ${message.notification?.title}',
        tag: 'FCMService',
      );
      _handleBackgroundMessage(message);
    });

    // Check for initial message (app opened from terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Logger.debug(
          'Initial message: ${message.notification?.title}',
          tag: 'FCMService',
        );
        _handleBackgroundMessage(message);
      }
    });
  }

  /// Handle foreground message (app is active)
  ///
  /// Emits message to stream for NotificationQueueService to handle.
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      Logger.debug(
        'Processing foreground message: ${message.messageId}',
        tag: 'FCMService',
      );

      // Emit to stream
      _messageController.add(message);

      // Log notification data
      if (message.notification != null) {
        Logger.debug(
          'Title: ${message.notification!.title}',
          tag: 'FCMService',
        );
        Logger.debug(
          'Body: ${message.notification!.body}',
          tag: 'FCMService',
        );
      }

      if (message.data.isNotEmpty) {
        Logger.debug('Data: ${message.data}', tag: 'FCMService');
      }
    } catch (e) {
      Logger.error(
        'Error handling foreground message',
        error: e,
        tag: 'FCMService',
      );
    }
  }

  /// Handle background message (app opened from notification)
  ///
  /// User tapped on notification, app is now active.
  void _handleBackgroundMessage(RemoteMessage message) {
    try {
      Logger.debug(
        'Processing background message: ${message.messageId}',
        tag: 'FCMService',
      );

      // Emit to stream for app to handle
      _messageController.add(message);

      // TODO: Navigate to appropriate screen based on message data
      final notificationType = message.data['type'];
      Logger.debug('Notification type: $notificationType', tag: 'FCMService');
    } catch (e) {
      Logger.error(
        'Error handling background message',
        error: e,
        tag: 'FCMService',
      );
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic', tag: 'FCMService');
    } catch (e) {
      Logger.error('Failed to subscribe to topic: $topic', error: e, tag: 'FCMService');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic', tag: 'FCMService');
    } catch (e) {
      Logger.error('Failed to unsubscribe from topic: $topic', error: e, tag: 'FCMService');
    }
  }

  /// Save FCM token to Firestore
  ///
  /// Stores the token in the user's document so Firebase Functions can send
  /// push notifications even when the app is closed.
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Logger.warning('Cannot save FCM token: user not logged in', tag: 'FCMService');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});

      Logger.info('FCM token saved to Firestore for user: ${user.uid}', tag: 'FCMService');
    } catch (e) {
      Logger.error('Failed to save FCM token to Firestore', error: e, tag: 'FCMService');
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _isInitialized = false;
    Logger.info('FCM Service disposed', tag: 'FCMService');
  }
}

/// NOTE: Background message handler is defined in main.dart
/// as _firebaseMessagingBackgroundHandler() to avoid duplication.
