import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:http/http.dart' as http;

class SigninExseption implements Exception {
  final String message;

  const SigninExseption(this.message);
}

class SigninRepository {
  static const _baseUrl = 'http://10.0.2.2:1337';

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/local'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'identifier': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      print('login status: ${response.statusCode}');
      print('login body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        await TokenStorage.save(
          jwt: data['jwt'],
          refreshToken: data['refreshToken'],
        );
        await TokenStorage.saveUser(
          id: data['user']['id'].toString(),
          documentId: data['user']['documentId']?.toString(),
        );
        return;
      }

      String message = 'Sign in failed (${response.statusCode})';
      try {
        final data = json.decode(response.body);
        message = data['error']?['message']?.toString() ?? message;
      } catch (_) {}
      throw SigninExseption(message);
    } on SocketException {
      throw const SigninExseption('Check your internet connection!');
    } on TimeoutException {
      throw const SigninExseption('Server took too long to respond');
    }
  }
}