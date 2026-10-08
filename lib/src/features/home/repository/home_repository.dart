import 'dart:convert';
import 'dart:io';

import 'package:banking_app22/src/features/home/repository/card_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HomeRepository {
  static Future<List<CardModel>> getCards() async {
    try {
      final userToken = await FlutterSecureStorage().read(key: 'jwt');
      final url = Uri.parse('http://10.0.2.2:1337/api/kartalars');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((e) => CardModel.fromJson(e))
            .toList();
      } else {
        throw HttpException(json.decode(response.body)['error']['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
