import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AuthRepository {
 static Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('http://localhost:1337/api/auth/local/register');
      final response = await http.post(
        url,
        body: {"email": email, "password": password, "username": username},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Register worked: ${response.body}');
      } else {
      final data =  json.decode(response.body);
        throw HttpException(data['error']['message']);
      }
    } on SocketException catch (e) {
      throw SocketException('Check your internet connction!');
    } on TimeoutException catch (e) {
      throw TimeoutException('Took way too long be patient');
    } catch (e) {
      throw Exception('Something went wrong!');
    }
  }
}
