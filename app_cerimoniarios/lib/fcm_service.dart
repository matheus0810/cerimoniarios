import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMService {
  static const String serverKey = 'COLE_AQUI_SUA_SERVER_KEY';

  static Future<void> enviarNotificacao({
    required String token,
    required String titulo,
    required String corpo,
  }) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': titulo,
          'body': corpo,
        },
        'priority': 'high',
      }),
    );

    print('FCM response: ${response.statusCode} - ${response.body}');
  }
}