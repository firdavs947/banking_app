import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/api_client.dart';
import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:banking_app22/src/features/profile/repository/profile_model.dart';
import 'package:http/http.dart' as http;

class ProfileException implements Exception {
  final String message;

  const ProfileException(this.message);
}

class ProfileRepository {
  static String _message(http.Response response, String fallback) {
    try {
      final data = json.decode(response.body);
      return data['error']?['message']?.toString() ??
          '$fallback (${response.statusCode})';
    } catch (_) {
      return '$fallback (${response.statusCode})';
    }
  }

  static Future<ProfileModel> getProfile() async {
    try {
      final response = await ApiClient.get(
        '/api/users/me?populate=${ProfileModel.avatarField}',
      );

      print('profile status: ${response.statusCode}');
      print('profile body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ProfileModel.fromJson(json.decode(response.body));
      }
      throw ProfileException(_message(response, 'Can not load the profile'));
    } on SocketException {
      throw const ProfileException('Check your internet connection!');
    } on TimeoutException {
      throw const ProfileException('Server took too long to respond');
    }
  }

  static Future<void> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    try {
      final token = await TokenStorage.readAccess();
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('${ApiClient.baseUrl}/api/upload'),
            )
           ..headers['Authorization'] = 'Bearer $token'
            ..fields['ref'] = 'plugin::users-permissions.user'
            ..fields['refId'] = userId
            ..fields['field'] = ProfileModel.avatarField
            ..files.add(await http.MultipartFile.fromPath('files', file.path));

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);

      print('avatar status: ${response.statusCode}');
      print('avatar body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProfileException(_message(response, 'Can not upload the photo'));
      }
    } on SocketException {
      throw const ProfileException('Check your internet connection!');
    } on TimeoutException {
      throw const ProfileException('Server took too long to respond');
    }
  }
}