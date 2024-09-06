import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendEmailSignUp(String to, String subject, String code) async {
  final baseUrl = Uri.parse('http://192.168.254.187:3000/api/send_email');

  try {
    final response = await http.post(
      baseUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'to': to,
        'subject': subject,
        'code': code,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Email sent successfully: ${responseData['messageId']}');
    } else {
      print('Failed to send email: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> sendEmailForgotPass(String to, String subject, String code) async {
  final baseUrl = Uri.parse('http://192.168.254.187:3000/api/send_email_forgotpass');

  try {
    final response = await http.post(
      baseUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'to': to,
        'subject': subject,
        'code': code,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Email sent successfully: ${responseData['messageId']}');
    } else {
      print('Failed to send email: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
