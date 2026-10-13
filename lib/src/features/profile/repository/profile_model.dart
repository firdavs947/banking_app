import 'package:banking_app22/src/core/network/api_client.dart';

class ProfileModel {
  static const avatarField = 'Avatar';

  final String id;
  final String username;
  final String email;
  final String? avatarUrl;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  static ProfileModel fromJson(Map json) {
    final avatar = json[avatarField];
    String? url;
    if (avatar is Map && avatar['url'] != null) {
      final raw = avatar['url'].toString();
      url = raw.startsWith('http') ? raw : '${ApiClient.baseUrl}$raw';
    }
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: url,
    );
  }
}