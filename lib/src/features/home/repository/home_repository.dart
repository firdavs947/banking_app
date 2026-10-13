import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/api_client.dart';
import 'package:banking_app22/src/features/home/repository/card_model.dart';
import 'package:banking_app22/src/features/home/repository/card_repository.dart';

class HomeRepository {
  static List _asList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is Map && value['data'] != null) return _asList(value['data']);
    if (value is Map) return [value];
    return [];
  }

  static Future<List<CardModel>> getCards() async {
    final response = await ApiClient.get(
      '/api/users/me?populate=${CardRepository.userRelation}',
    );

    print('cards status: ${response.statusCode}');
    print('cards body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return _asList(
        data[CardRepository.userRelation],
      ).map((e) => CardModel.fromJson(e)).toList();
    }

    String message = 'Can not load the cards (${response.statusCode})';
    try {
      message =
          json.decode(response.body)['error']?['message']?.toString() ??
          message;
    } catch (_) {}
    throw HttpException(message);
  }
}