import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/core/network/api_client.dart';
import 'package:banking_app22/src/features/home/repository/card_model.dart';

class HomeRepository {
  static Future<List<CardModel>> getCards() async {
    final response = await ApiClient.get('/api/kartalars');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((e) => CardModel.fromJson(e)).toList();
    }
    throw HttpException(json.decode(response.body)['error']['message']);
  }
}