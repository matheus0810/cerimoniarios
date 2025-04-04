import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingSetup {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    // ❌ Firebase já foi inicializado no main.dart, então REMOVIDO

    // Solicita permissões (iOS)
    await FirebaseMessaging.instance.requestPermission();

    // Inicializa flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Lida com notificações quando o app está em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Mensagem recebida em foreground: ${message.notification?.title}');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Notificações',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? 'Nova Notificação',
        message.notification?.body ?? '',
        platformDetails,
      );
    });

    // Exibe o token no console
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  }

  static void mostrarNotificacaoTeste() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notificações',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      1,
      'Teste de Notificação',
      'Esta é uma notificação de teste',
      platformDetails,
    );
  }
}
