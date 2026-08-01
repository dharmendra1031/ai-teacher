import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_teacher/core/config/app_environment.dart';
import 'package:ai_teacher/core/network/api_exception.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

class ApiClient extends GetxService {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 20);

  Future<JsonMap> getJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'GET',
      uri: _buildUri(path, queryParameters),
      headers: headers,
    );
  }

  Future<JsonMap> postJson(
    String path, {
    JsonMap? body,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'POST',
      uri: _buildUri(path),
      headers: headers,
      body: body,
    );
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final String baseUrl = AppEnvironment.apiBaseUrl.trim();
    if (baseUrl.isEmpty) {
      throw const ApiConfigurationException(
        'API_BASE_URL is missing. Start the app with --dart-define=API_BASE_URL=...',
      );
    }

    final String normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final String normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse(normalizedBase)
        .resolve(normalizedPath)
        .replace(queryParameters: queryParameters);
  }

  Future<JsonMap> _send({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    JsonMap? body,
  }) async {
    final Map<String, String> requestHeaders = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      ...?headers,
    };

    try {
      late final http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: requestHeaders)
              .timeout(_timeout);
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: requestHeaders,
                body: jsonEncode(body ?? <String, dynamic>{}),
              )
              .timeout(_timeout);
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return _decodeResponse(response);
    } on TimeoutException catch (error) {
      throw ApiException('The request timed out.', cause: error);
    } on SocketException catch (error) {
      throw ApiException('No internet connection.', cause: error);
    } on FormatException catch (error) {
      throw ApiException('The server returned invalid JSON.', cause: error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Unexpected network error.', cause: error);
    }
  }

  JsonMap _decodeResponse(http.Response response) {
    final bool isSuccessful = response.statusCode >= 200 && response.statusCode < 300;
    final Object? decoded = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (!isSuccessful) {
      final String message = decoded is JsonMap
          ? (decoded['message'] ?? decoded['detail'] ?? 'Request failed').toString()
          : 'Request failed';

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    if (decoded is! JsonMap) {
      throw const ApiException('Expected a JSON object from the server.');
    }

    return decoded;
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
