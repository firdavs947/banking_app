import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SigninExseption implements Exception {
  final String message;

  const SigninExseption(this.message);
}

class SigninRepository {
  static const _baseUrl = 'http://localhost:1337';

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/local'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'identifier': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        await const FlutterSecureStorage().write(
          key: 'jwt',
          value: data['jwt'],
        );
        return;
      }

      final data = json.decode(response.body);
      throw SigninExseption(data['error']?['message'] ?? 'Sign in failed');
    } on SocketException {
      throw const SigninExseption('Check your internet connection!');
    } on TimeoutException {
      throw const SigninExseption('Server took too long to respond');
    }
  }
}