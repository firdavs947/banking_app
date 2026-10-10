import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}

class AuthRepository {
  static const _baseUrl = 'http://10.0.2.2:1337';

  static Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/local/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'password': password,
              'username': username,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('register status: ${response.statusCode}');
      print('register body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        await TokenStorage.save(
          jwt: data['jwt'],
          refreshToken: data['refreshToken'],
        );
        return;
      }
      String message = 'Registration failed (${response.statusCode})';
      try {
        final data = json.decode(response.body);
        message = data['error']?['message']?.toString() ?? message;
      } catch (_) {}
      throw AuthException(message);
    } on SocketException {
      throw const AuthException('Check your internet connection!');
    } on TimeoutException {
      throw const AuthException('Server took too long to respond');
    }
  }
}
