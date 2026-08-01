import 'package:ai_teacher_phase1_livekit/src/data/livekit_token_repository.dart';
import 'package:ai_teacher_phase1_livekit/src/domain/livekit_credentials.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('fetchCredentials maps the development token response', () async {
    final MockClient client = MockClient((http.Request request) async {
      expect(request.url.path, '/token');
      expect(request.url.queryParameters['room'], 'phase1-room');
      expect(request.url.queryParameters['identity'], 'flutter-test');

      return http.Response(
        '{'
        '"url":"ws://192.168.1.20:7880",'
        '"token":"test-token",'
        '"room":"phase1-room",'
        '"identity":"flutter-test"'
        '}',
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });

    final LiveKitTokenRepository repository = LiveKitTokenRepository(
      client: client,
      tokenServiceUrl: 'http://192.168.1.20:8090',
    );

    final LiveKitCredentials credentials = await repository.fetchCredentials(
      room: 'phase1-room',
      identity: 'flutter-test',
      displayName: 'Physical Device',
    );

    expect(credentials.url, 'ws://192.168.1.20:7880');
    expect(credentials.token, 'test-token');
    expect(credentials.room, 'phase1-room');
    expect(credentials.identity, 'flutter-test');

    repository.close();
  });

  test('fetchCredentials exposes server error text', () async {
    final MockClient client = MockClient((http.Request request) async {
      return http.Response('{"message":"identity is invalid"}', 400);
    });

    final LiveKitTokenRepository repository = LiveKitTokenRepository(
      client: client,
      tokenServiceUrl: 'http://192.168.1.20:8090',
    );

    expect(
      repository.fetchCredentials(
        room: 'phase1-room',
        identity: 'bad',
        displayName: 'Bad',
      ),
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          contains('identity is invalid'),
        ),
      ),
    );

    repository.close();
  });
}
