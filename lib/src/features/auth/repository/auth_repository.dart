import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:banking_app22/src/features/profile/repository/profile_model.dart';
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
    File? avatar,
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
        final jwt = data['jwt'] as String;

        await TokenStorage.save(
          jwt: jwt,
          refreshToken: data['refreshToken'],
        );
                await TokenStorage.saveUser(
          id: data['user']['id'].toString(),
          documentId: data['user']['documentId']?.toString(),
        );

        if (avatar != null) {
                 final user = data['user'];
          await _uploadAvatar(
            file: avatar,
            userId: (user['documentId'] ?? user['id']).toString(),
            jwt: jwt,
          );
        }
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

    static Future<void> _uploadAvatar({
    required File file,
    required String userId,
    required String jwt,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'))
          ..headers['Authorization'] = 'Bearer $jwt'
          ..fields['ref'] = 'plugin::users-permissions.user'
          ..fields['refId'] = userId
          ..fields['field'] = ProfileModel.avatarField
          ..files.add(await http.MultipartFile.fromPath('files', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    print('avatar status: ${response.statusCode}');
    print('avatar body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Photo upload failed (${response.statusCode})';
      try {
        final data = json.decode(response.body);
        message = data['error']?['message']?.toString() ?? message;
      } catch (_) {}
      throw AuthException(message);
    }
  }
}