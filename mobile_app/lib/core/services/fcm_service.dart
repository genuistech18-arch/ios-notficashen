import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? get _messaging {
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  Future<void> requestPermission() async {
    try {
      await _messaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(initSettings);

      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      await _messaging?.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}
  }

  Future<void> showDirectNotification({
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
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
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
      );
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      await requestPermission();
      final token = await _messaging?.getToken();
      print('FCM TOKEN OBTAINED: $token');
      return token;
    } catch (e, st) {
      print('FCM TOKEN ERROR: $e\n$st');
      return null;
    }
  }

  void showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    showDirectNotification(
      title: notification.title ?? 'متابعة الطالب',
      body: notification.body ?? '',
    );
  }

  void onForegroundMessage(void Function(RemoteMessage) handler) {
    try {
      FirebaseMessaging.onMessage.listen((message) {
        showLocalNotification(message);
        handler(message);
      });
    } catch (_) {}
  }

  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen(handler);
    } catch (_) {}
  }

  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _messaging?.getInitialMessage();
    } catch (_) {
      return null;
    }
  }
}
