import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddCardException implements Exception {
  final String message;

  const AddCardException(this.message);
}

class AllCardsRepository {
  static const _baseUrl = 'http://10.0.2.2:1337';
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

  static Future<void> addCard({
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) async {
    try {
      final jwt = await const FlutterSecureStorage().read(key: 'jwt');
      final response = await ApiClient.post(
        '/api/kartalars',
        body: {
          'data': {
            _holderField: holder,
            _numberField: number,
            _expiryField: _toApiDate(expiry),
            _cvvField: cvv,
          },
        },
      ).timeout(const Duration(seconds: 15));

      print('add card status: ${response.statusCode}');
      print('add card body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      String message = 'Can not add the card (${response.statusCode})';
      try {
        final data = json.decode(response.body);
        message = data['error']?['message']?.toString() ?? message;
      } catch (_) {}
      throw AddCardException(message);
    } on SocketException {
      throw const AddCardException('Check your internet connection!');
    } on TimeoutException {
      throw const AddCardException('Server took too long to respond');
    }
  }
}
