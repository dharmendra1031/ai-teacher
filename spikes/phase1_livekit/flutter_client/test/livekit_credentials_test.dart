import 'package:ai_teacher_phase1_livekit/src/domain/livekit_credentials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveKitCredentials', () {
    test('parses a complete token-service response', () {
      final LiveKitCredentials credentials = LiveKitCredentials.fromJson(
        <String, dynamic>{
          'url': 'ws://192.168.1.20:7880',
          'token': 'test-token',
          'room': 'phase1-room',
          'identity': 'flutter-test',
        },
      );

      expect(credentials.url, 'ws://192.168.1.20:7880');
      expect(credentials.token, 'test-token');
      expect(credentials.room, 'phase1-room');
      expect(credentials.identity, 'flutter-test');
    });

    test('rejects an incomplete token-service response', () {
      expect(
        () => LiveKitCredentials.fromJson(<String, dynamic>{
          'url': 'ws://192.168.1.20:7880',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
