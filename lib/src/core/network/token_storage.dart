import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _jwtKey = 'jwt';
  static const _refreshKey = 'refreshToken';

  static Future<String?> readAccess() => _storage.read(key: _jwtKey);

  static Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  static Future<void> save({required String jwt, String? refreshToken}) async {
    await _storage.write(key: _jwtKey, value: jwt);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  static Future<void> clear() async {
    await _storage.delete(key: _jwtKey);
    await _storage.delete(key: _refreshKey);
  }

  static Future<bool> hasSession() async {
    return await readRefresh() != null || await readAccess() != null;
  }
}