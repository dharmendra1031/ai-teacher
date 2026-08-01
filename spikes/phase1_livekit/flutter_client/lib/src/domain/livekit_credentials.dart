class LiveKitCredentials {
  const LiveKitCredentials({
    required this.url,
    required this.token,
    required this.room,
    required this.identity,
  });

  final String url;
  final String token;
  final String room;
  final String identity;

  factory LiveKitCredentials.fromJson(Map<String, dynamic> json) {
    final String url = (json['url'] ?? '').toString().trim();
    final String token = (json['token'] ?? '').toString().trim();
    final String room = (json['room'] ?? '').toString().trim();
    final String identity = (json['identity'] ?? '').toString().trim();

    if (url.isEmpty || token.isEmpty || room.isEmpty || identity.isEmpty) {
      throw const FormatException('Token service response is incomplete.');
    }

    return LiveKitCredentials(
      url: url,
      token: token,
      room: room,
      identity: identity,
    );
  }
}
