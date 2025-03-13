import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // Initialize local notifications
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          try {
            // Handle notification tap
            final payload = details.payload;
            if (payload != null) {
              // Navigate to specific screen based on payload
            }
          } catch (error, stackTrace) {
            FirebaseCrashlytics.instance.recordError(
              error,
              stackTrace,
              reason: 'Erro ao processar resposta de notificação',
              fatal: false,
            );
          }
        },
      );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        _showNotification(message);
      },
      onError: (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Erro ao processar mensagem em primeiro plano',
          fatal: false,
        );
      },
    );

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        try {
          // Navigate to specific screen based on message
        } catch (error, stackTrace) {
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: 'Erro ao processar abertura do app a partir de notificação',
            fatal: false,
          );
        }
      },
      onError: (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Erro no fluxo onMessageOpenedApp',
          fatal: false,
        );
      },
    );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Erro ao inicializar serviço de notificações',
        fatal: true,
      );
      rethrow;
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Handle background messages
    _showNotification(message);
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}