import 'dart:async';
import 'dart:convert';

import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const baseUrl = 'http://10.0.2.2:1337';
  static const _timeout = Duration(seconds: 15);

  static void Function()? onSessionExpired;
  static Future<bool>? _refreshing;

  static Future<http.Response> get(String path) {
    return _send(
      (token) => http.get(Uri.parse('$baseUrl$path'), headers: _headers(token)),
    );
  }

  static Future<http.Response> post(String path, {Object? body}) {
    return _send(
      (token) => http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(token),
        body: body == null ? null : json.encode(body),
      ),
    );
  }

  static Future<http.Response> put(String path, {Object? body}) {
    return _send(
      (token) => http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers(token),
        body: body == null ? null : json.encode(body),
      ),
    );
  }

   static Future<http.Response> delete(String path) {
    return _send(
      (token) => http.delete(
        Uri.parse('$baseUrl$path'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }

  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _send(
    Future<http.Response> Function(String? token) request,
  ) async {
    final token = await TokenStorage.readAccess();
    final response = await request(token).timeout(_timeout);
    if (response.statusCode != 401) return response;

    final refreshed = await _refresh();
    if (!refreshed) return response;

    final newToken = await TokenStorage.readAccess();
    return request(newToken).timeout(_timeout);
  }

  static Future<bool> _refresh() {
    return _refreshing ??= _doRefresh().then((ok) async {
      if (!ok) {
        await TokenStorage.clear();
        onSessionExpired?.call();
      }
      return ok;
    }).whenComplete(() => _refreshing = null);
  }

  static Future<bool> _doRefresh() async {
    final refreshToken = await TokenStorage.readRefresh();
    if (refreshToken == null) return false;

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) return false;

    final data = json.decode(response.body);
    await TokenStorage.save(
      jwt: data['jwt'],
      refreshToken: data['refreshToken'] ?? refreshToken,
    );
    return true;
  }
}