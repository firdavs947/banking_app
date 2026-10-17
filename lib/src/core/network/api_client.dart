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

    print('api 401 body: ${response.body}');

    final refreshed = await _refresh();
    if (!refreshed) return response;

    final newToken = await TokenStorage.readAccess();
    return request(newToken).timeout(_timeout);
  }

  static Future<bool> _refresh() {
    return _refreshing ??= _doRefresh()
        .then((ok) async {
          if (!ok) {
            print('refresh failed: session cleared');
            await TokenStorage.clear();
            onSessionExpired?.call();
          }
          return ok;
        })
        .whenComplete(() => _refreshing = null);
  }

  static Future<bool> _doRefresh() async {
    final refreshToken = await TokenStorage.readRefresh();
    print('refresh token saved: ${refreshToken != null}');
    if (refreshToken == null) return false;

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        )
        .timeout(_timeout);

    print('refresh status: ${response.statusCode}');
    print('refresh body: ${response.body}');

    if (response.statusCode >= 500) {
      throw http.ClientException('Server error ${response.statusCode}');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) return false;

    final data = json.decode(response.body);
    await TokenStorage.save(
      jwt: data['jwt'],
      refreshToken: data['refreshToken'] ?? refreshToken,
    );
    return true;
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:http_interceptor/http_interceptor.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class ApiClient {
//   static const String baseUrl = "http://localhost:1337";
//   static const _storage = FlutterSecureStorage();

//   late final http.Client client;
//   // * client -> api object | 1. baseurl | 2. interceptor (api refresh token control)

//   static bool isAuthEndpoint(Uri url) => url.path.startsWith('/api/auth/');

//   ApiClient() {
//     client = InterceptedClient.build(
//       interceptors: [AuthorizationInterceptor()],
//       retryPolicy: ExpiredTokenRetryPolicy(),
//     );
//   }
// }

// class AuthorizationInterceptor implements HttpInterceptor {
//   final _storage = const FlutterSecureStorage();

//   @override
//   FutureOr<bool> shouldInterceptRequest({required http.BaseRequest request}) {
//     return true; 
//   }

//   @override
//   FutureOr<bool> shouldInterceptResponse({
//     required http.BaseResponse response,
//   }) {
//     return true; 
//   }

//   @override
//   FutureOr<http.BaseRequest> interceptRequest({
//     required http.BaseRequest request,
//   }) async {
//     // ! A sent request is finalized and cannot be sent again, and the retry
//     // ! policy hands us the same object on a retry, so always send a fresh copy.
//     final outgoing = _copyRequest(request); // * eng oxirigi request get qiladi
//     try {
//       final accessToken = await _storage.read(key: "jwt");
//       // Always overwrite: on a retry the copy still carries the expired token.
//       outgoing.headers.remove('Authorization');
//       if (accessToken != null && !ApiClient.isAuthEndpoint(outgoing.url)) {
//         outgoing.headers['Authorization'] = 'Bearer $accessToken';
//       }
//       outgoing.headers['Content-Type'] = 'application/json';
//       outgoing.headers['Accept'] = 'application/json';
//     } catch (e) {
//       print("Error injecting token: $e");
//     }
//     return outgoing;
//   }

//   http.BaseRequest _copyRequest(http.BaseRequest request) {
//     if (request is! http.Request) return request;
//     return http.Request(request.method, request.url)
//       ..headers.addAll(request.headers)
//       ..bodyBytes = request.bodyBytes
//       ..followRedirects = request.followRedirects
//       ..maxRedirects = request.maxRedirects
//       ..persistentConnection = request.persistentConnection;
//   }

//   @override
//   FutureOr<http.BaseResponse> interceptResponse({
//     required http.BaseResponse response,
//   }) async => response;
// }

// // 2. THIS CATCHES 401s, REFRESHES THE TOKEN, AND RETRIES AUTOMATICALLY
// class ExpiredTokenRetryPolicy implements RetryPolicy {
//   final _storage = const FlutterSecureStorage();

//   // Shared by every ApiClient so parallel 401s trigger only one refresh call.
//   static Future<bool>? _ongoingRefresh;

//   @override
//   int get maxRetryAttempts => 1;

//   @override
//   Future<bool> shouldAttemptRetryOnResponse(http.BaseResponse response) async {
//     if (response.statusCode != 401) return false;

//     final request = response.request;
//     // Only plain requests can be resent, and login/register 401s are not
//     // caused by an expired token.
//     if (request is! http.Request || ApiClient.isAuthEndpoint(request.url)) {
//       return false;
//     }

//     print("token eskirdi (401)");

//     // ! Another request already refreshed the token while this one was in
//     // ! flight: just resend with the new token instead of refreshing again.
//     final currentToken = await _storage.read(key: "jwt");
//     if (currentToken != null &&
//         request.headers['Authorization'] != 'Bearer $currentToken') {
//       return true;
//     }

//     final isRefreshed = await (_ongoingRefresh ??= _refreshAccessToken()
//         .whenComplete(() => _ongoingRefresh = null));
//     print('token yengilandi $isRefreshed');
//     return isRefreshed;
//   }

//   // Pure refresh logic hitting your authentication endpoint
//   Future<bool> _refreshAccessToken() async {
//     try {
//       // Must be the same key the login/register flow writes to.
//       final currentRefreshToken = await _storage.read(key: "refresh_token");
//       if (currentRefreshToken == null) return false;

//       final response = await http.post(
//         Uri.parse("${ApiClient.baseUrl}/api/auth/refresh"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'refreshToken': currentRefreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final String? newAccessToken = data['jwt'];
//         final String? newRefreshToken = data['refreshToken'];
//         if (newAccessToken == null) return false;

//         await _storage.write(key: "jwt", value: newAccessToken);
//         // Writing null would delete the key, so keep the old refresh token
//         // when the server does not rotate it.
//         if (newRefreshToken != null) {
//           await _storage.write(key: "refresh_token", value: newRefreshToken);
//         }
//         print("Token refresh successful!");
//         return true;
//       }

//       print(
//         'Refresh token ishlamadi ${response.statusCode} | ${response.body}',
//       );

//       // Log out only when the server actually rejected the refresh token.
//       if (response.statusCode == 400 ||
//           response.statusCode == 401 ||
//           response.statusCode == 403) {
//         print("Refresh token expired or invalid. Logging user out.");
//         await _storage.deleteAll();
//       }
//     } catch (e) {
//       // Network/parsing problem: keep the tokens so the next request can retry.
//       print("Failed to refresh token: $e");
//     }
//     return false;
//   }

//   @override
//   FutureOr<bool> shouldAttemptRetryOnException(
//     Exception reason,
//     http.BaseRequest request,
//   ) {
//     return false; // FIXED: Handled instead of leaving UnimplementedError
//   }

//   @override
//   Duration delayRetryAttemptOnException({required int retryAttempt}) {
//     return Duration
//         .zero; // FIXED: Handled instead of leaving UnimplementedError
//   }

//   @override
//   Duration delayRetryAttemptOnResponse({required int retryAttempt}) {
//     return Duration
//         .zero; // FIXED: Handled instead of leaving UnimplementedError
//   }
// }
