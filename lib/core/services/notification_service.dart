import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/routes/app_routers_import.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showLocalNotificationFromMessage(message);
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static NotificationsCubit? _notificationsCubit;
  static bool _notificationsInitialized = false;

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High importance notifications';
  static const String _channelDescription =
      'Notifications for reservation reminders and app alerts';

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) =>
          handleNotificationClick(const <String, dynamic>{}),
    );
    _notificationsInitialized = true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
    }

    final NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Disable automatic foreground presentation to prevent duplicate notifications.
    // We manually show notifications via onMessage.listen → showLocalNotificationFromMessage.
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      await showLocalNotificationFromMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print('Opened notification: ${message.messageId}');
      }
      handleNotificationClick(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        handleNotificationClick(initialMessage.data);
      });
    }

    final String? token = await getFCMToken();
    if (kDebugMode) {
      print('FCM token: $token');
    }

    if (kDebugMode) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    }
  }

  static void bindNotificationsCubit(NotificationsCubit cubit) {
    _notificationsCubit = cubit;
  }

  static Future<void> showReservationCreatedNotification({required String carName}) async {
    await showLocalNotification(
      title: 'تم الحجز بنجاح',
      body: 'تم حجز سيارة $carName بنجاح وسيظهر لك تذكير قبل انتهاء الحجز.',
    );

    try {
      _notificationsCubit?.addReservationNotification(
        title: 'تم الحجز بنجاح',
        body: 'تم حجز سيارة $carName بنجاح وسيظهر لك تذكير قبل انتهاء الحجز.',
      );
    } catch (_) {}
  }

  static Future<void> showReservationCancelledNotification({required String carName}) async {
    await showLocalNotification(title: 'تم إلغاء الحجز', body: 'تم إلغاء حجز سيارة $carName.');

    try {
      _notificationsCubit?.addReservationNotification(
        title: 'تم إلغاء الحجز',
        body: 'تم إلغاء حجز سيارة $carName.',
      );
    } catch (_) {}
  }

  static Future<void> showReservationReminder({required String carName}) async {
    await showLocalNotification(
      title: 'الحجز قريب من الانتهاء',
      body: 'سيارة $carName ستنتهي صلاحية حجزها خلال ساعة',
    );

    try {
      _notificationsCubit?.addReservationNotification(
        title: 'الحجز قريب من الانتهاء',
        body: 'سيارة $carName ستنتهي صلاحية حجزها خلال ساعة',
      );
    } catch (_) {}
  }

  static Future<void> showLocalNotification({required String title, required String body}) async {
    if (!_notificationsInitialized) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'FCM',
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show local notification: $e');
      }
    }
  }

  static Future<void> showLocalNotificationFromMessage(RemoteMessage message) async {
    final String title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final String body =
        message.notification?.body ?? message.data['body'] ?? 'لديك إشعار جديد من التطبيق';
    await showLocalNotification(title: title, body: body);

    try {
      _notificationsCubit?.addReservationNotification(title: title, body: body);
    } catch (_) {}
  }


  static Future<String?> getFCMToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Wait for APNs token to be available before fetching FCM token
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          // Add a short delay to allow APNs token to be generated
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _firebaseMessaging.getAPNSToken();
        }

        if (apnsToken != null) {
          return await _firebaseMessaging.getToken();
        } else {
          return null; // Silently return null for Simulators
        }
      } else {
        return await _firebaseMessaging.getToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get FCM token: $e");
      }
      return null;
    }
  }

  static void handleNotificationClick(Map<String, dynamic> data) {
    try {
      final role = HiveMethods.getRole();
      final bool isAgent = role == '2' || role == 'agent';
      final bool isAdmin = !isAgent && role != '1' && role != 'user';

      String routeName = RoutesName.cartScreen;
      if (isAgent) {
        routeName = RoutesName.agentMyBookingsScreen;
      } else if (isAdmin) {
        routeName = RoutesName.manageBookings;
      }

      AppRouters.navigatorKey.currentState?.pushNamed(routeName);
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating on notification click: $e');
      }
    }
  }
}
