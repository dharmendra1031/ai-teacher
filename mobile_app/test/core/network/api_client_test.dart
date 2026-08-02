import 'package:ai_teacher/core/network/api_client.dart';
import 'package:ai_teacher/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('GET decodes a successful JSON object', () async {
    final MockClient mockClient = MockClient((http.Request request) async {
      expect(request.url.toString(), 'https://example.test/api/v1/health');
      return http.Response('{"status":"ok"}', 200);
    });

    final ApiClient apiClient = ApiClient(
      client: mockClient,
      baseUrl: 'https://example.test/api/v1',
    );

    final JsonMap result = await apiClient.getJson('/health');

    expect(result['status'], 'ok');
  });

  test('non-success response throws ApiException', () async {
    final MockClient mockClient = MockClient((http.Request request) async {
      return http.Response('{"detail":"Not allowed"}', 403);
    });

    final ApiClient apiClient = ApiClient(
      client: mockClient,
      baseUrl: 'https://example.test/api/v1',
    );

    expect(
      () => apiClient.getJson('/private'),
      throwsA(
        isA<ApiException>()
            .having((ApiException error) => error.statusCode, 'statusCode', 403)
            .having(
              (ApiException error) => error.message,
              'message',
              'Not allowed',
            ),
      ),
    );
  });
}
