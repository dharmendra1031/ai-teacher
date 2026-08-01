import 'dart:convert';

import 'package:ai_teacher_phase1_livekit/src/domain/livekit_credentials.dart';
import 'package:http/http.dart' as http;

class LiveKitTokenRepository {
  LiveKitTokenRepository({
    http.Client? client,
    String? tokenServiceUrl,
  })  : _client = client ?? http.Client(),
        _tokenServiceUrl = tokenServiceUrl ??
            const String.fromEnvironment('TOKEN_SERVICE_URL');

  final http.Client _client;
  final String _tokenServiceUrl;

  Future<LiveKitCredentials> fetchCredentials({
    required String room,
    required String identity,
    required String displayName,
  }) async {
    final String baseUrl = _tokenServiceUrl.trim();
    if (baseUrl.isEmpty) {
      throw StateError(
        'TOKEN_SERVICE_URL is missing. Use '
        '--dart-define=TOKEN_SERVICE_URL=http://LAN_IP:8090',
      );
    }

    final Uri uri = Uri.parse(baseUrl).replace(
      path: '/token',
      queryParameters: <String, String>{
        'room': room,
        'identity': identity,
        'name': displayName,
      },
    );

    final http.Response response = await _client
        .get(
          uri,
          headers: const <String, String>{
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    final Object? decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = decoded is Map<String, dynamic>
          ? (decoded['message'] ?? 'Token request failed').toString()
          : 'Token request failed';
      throw StateError('$message (${response.statusCode})');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Token service did not return a JSON object.');
    }

    return LiveKitCredentials.fromJson(decoded);
  }

  void close() {
    _client.close();
  }
}
