import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lapor_balongmojo/main.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/screens/masyarakat/berita_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // WAJIB IMPORT INI

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String _topicName = 'emergency_alerts';

  Future<void> initialize() async {
    try {
      // 1. Setup Local Notification
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            _navigateToDetail(response.payload!);
          }
        },
      );

      // 2. Setup Channel
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      // 3. LOGIKA SUBSCRIBE: HANYA MASYARAKAT
      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('userRole'); 
      
      if (role == 'masyarakat') {
         await _firebaseMessaging.subscribeToTopic(_topicName);
         print('>>> [FCM] User Masyarakat -> SUBSCRIBE $_topicName');
      } else {
         await _firebaseMessaging.unsubscribeFromTopic(_topicName);
         print('>>> [FCM] User Admin/Perangkat -> UNSUBSCRIBE $_topicName');
      }

      // 4. Listen Message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          String payloadData = jsonEncode({
            'judul': notification.title ?? 'Darurat',
            'isi': notification.body ?? 'Isi berita tidak tersedia',
          });

          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
            ),
            payload: payloadData,
          );
        }
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      print('Error inisialisasi FCM: $e');
    }
  }

  void _navigateToDetail(String payload) {
    try {
      final data = jsonDecode(payload);
      BeritaModel berita = BeritaModel(
        id: 0,
        judul: data['judul'],
        isi: data['isi'],
        gambarUrl: null,
        authorName: "Peringatan Darurat",
        createdAt: DateTime.now(),
        isPeringatanDarurat: true,
      );
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => BeritaDetailScreen(berita: berita)),
      );
    } catch (e) {
      print('Gagal parsing payload: $e');
    }
  }

  Future<void> unsubscribeFromTopic() async {
    await _firebaseMessaging.unsubscribeFromTopic(_topicName);
  }
}