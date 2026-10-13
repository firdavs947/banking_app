import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/api_client.dart';
import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:http/http.dart' as http;

class AddCardException implements Exception {
  final String message;

  const AddCardException(this.message);
}

class CardRepository {
  static const userRelation = 'kartalar';
  static const _holderField = 'Holder_name';
  static const _numberField = 'Card_number';
  static const _expiryField = 'Expire_date';
  static const _cvvField = 'CVV';

  static String _toApiDate(String expiry) {
    final month = int.parse(expiry.substring(0, 2));
    final year = 2000 + int.parse(expiry.substring(3, 5));
    final lastDay = DateTime(year, month + 1, 0);
    final mm = lastDay.month.toString().padLeft(2, '0');
    final dd = lastDay.day.toString().padLeft(2, '0');
    return '${lastDay.year}-$mm-$dd';
  }

  static Map<String, dynamic> _payload({
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) {
    return {
      'data': {
        _holderField: holder,
        _numberField: number,
        _expiryField: _toApiDate(expiry),
        _cvvField: cvv,
      },
    };
  }
  static void _check(http.Response response, String fallback) {
    print('card status: ${response.statusCode}');
    print('card body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String reason = '${response.statusCode}';
    try {
      final data = json.decode(response.body);
      reason = data['error']?['message']?.toString() ?? reason;
    } catch (_) {}
    throw AddCardException('$fallback: $reason');
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SocketException {
      throw const AddCardException('Check your internet connection!');
    } on TimeoutException {
      throw const AddCardException('Server took too long to respond');
    }
  }

  static Future<String> _currentUserId() async {
    final saved = await TokenStorage.readUserId();
    if (saved != null) return saved;

    final response = await ApiClient.get('/api/users/me');
    _check(response, 'Can not load the user');
    final id = json.decode(response.body)['id'].toString();
    await TokenStorage.saveUser(id: id);
    return id;
  }

  static Future<void> addCard({
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) {
    return _guard(() async {
      final userId = await _currentUserId();

      final created = await ApiClient.post(
        '/api/kartalars',
        body: _payload(
          holder: holder,
          number: number,
          expiry: expiry,
          cvv: cvv,
        ),
      );
      _check(created, 'Can not add the card');

      final card = json.decode(created.body)['data'];

      try {
        final linked = await ApiClient.put(
          '/api/users/$userId',
          body: {
            userRelation: {
              'connect': [
                {'id': card['id']},
              ],
            },
          },
        );
        _check(linked, 'Can not attach the card to the user');
      } catch (_) {
        await ApiClient.delete('/api/kartalars/${card['documentId']}');
        rethrow;
      }
    });
  }

  static Future<void> updateCard({
    required String documentId,
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) {
    return _guard(() async {
      final response = await ApiClient.put(
        '/api/kartalars/$documentId',
        body: _payload(
          holder: holder,
          number: number,
          expiry: expiry,
          cvv: cvv,
        ),
      );
      _check(response, 'Can not update the card');
    });
  }

  static Future<void> deleteCard({required String documentId}) {
    return _guard(() async {
      final response = await ApiClient.delete('/api/kartalars/$documentId');
      _check(response, 'Can not delete the card');
    });
  }
}