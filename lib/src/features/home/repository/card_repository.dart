import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class AddCardException implements Exception {
  final String message;

  const AddCardException(this.message);
}

class CardRepository {
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

  static Future<void> deleteCard({required String documentId}) {
    return _run(
      () => ApiClient.delete('/api/kartalars/$documentId'),
      'Can not delete the card',
    );
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

  static Future<void> addCard({
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) {
    return _run(
      () => ApiClient.post(
        '/api/kartalars',
        body: _payload(
          holder: holder,
          number: number,
          expiry: expiry,
          cvv: cvv,
        ),
      ),
      'Can not add the card',
    );
  }

  static Future<void> updateCard({
    required String documentId,
    required String holder,
    required String number,
    required String expiry,
    required String cvv,
  }) {
    return _run(
      () => ApiClient.put(
        '/api/kartalars/$documentId',
        body: _payload(
          holder: holder,
          number: number,
          expiry: expiry,
          cvv: cvv,
        ),
      ),
      'Can not update the card',
    );
  }

  static Future<void> _run(
    Future<http.Response> Function() request,
    String fallback,
  ) async {
    try {
      final response = await request();

      print('card status: ${response.statusCode}');
      print('card body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      String message = '$fallback (${response.statusCode})';
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