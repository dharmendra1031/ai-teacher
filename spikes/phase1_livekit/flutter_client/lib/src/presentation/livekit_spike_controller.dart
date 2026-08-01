import 'dart:async';

import 'package:ai_teacher_phase1_livekit/src/data/livekit_token_repository.dart';
import 'package:ai_teacher_phase1_livekit/src/domain/livekit_credentials.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

enum SpikeConnectionStatus {
  idle,
  requestingPermissions,
  fetchingToken,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class LiveKitSpikeController extends GetxController
    with WidgetsBindingObserver {
  LiveKitSpikeController(this._tokenRepository);

  final LiveKitTokenRepository _tokenRepository;

  final Rx<SpikeConnectionStatus> status = SpikeConnectionStatus.idle.obs;
  final RxString errorMessage = ''.obs;
  final RxString roomName = 'phase1-room'.obs;
  final RxString identity = ''.obs;
  final RxBool microphoneEnabled = false.obs;
  final RxBool cameraEnabled = false.obs;
  final RxBool speakerEnabled = true.obs;
  final Rxn<VideoTrack> remoteVideoTrack = Rxn<VideoTrack>();
  final RxList<String> logs = <String>[].obs;

  Room? _room;
  EventsListener<RoomEvent>? _listener;

  bool get isConnected => status.value == SpikeConnectionStatus.connected;

  bool get isBusy => <SpikeConnectionStatus>{
        SpikeConnectionStatus.requestingPermissions,
        SpikeConnectionStatus.fetchingToken,
        SpikeConnectionStatus.connecting,
        SpikeConnectionStatus.reconnecting,
      }.contains(status.value);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    identity.value = 'flutter-${DateTime.now().millisecondsSinceEpoch}';
    _log('Controller ready identity=${identity.value}');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log('App lifecycle: ${state.name}');
  }

  Future<void> connect() async {
    if (isBusy || isConnected) return;

    errorMessage.value = '';
    remoteVideoTrack.value = null;

    try {
      status.value = SpikeConnectionStatus.requestingPermissions;
      _log('Requesting microphone and camera permissions');

      final Map<Permission, PermissionStatus> permissions =
          await <Permission>[
        Permission.microphone,
        Permission.camera,
      ].request();

      final PermissionStatus microphoneStatus =
          permissions[Permission.microphone] ?? PermissionStatus.denied;
      final PermissionStatus cameraStatus =
          permissions[Permission.camera] ?? PermissionStatus.denied;

      if (!microphoneStatus.isGranted) {
        throw StateError('Microphone permission is required for Phase 1.');
      }

      status.value = SpikeConnectionStatus.fetchingToken;
      _log('Fetching development room token');

      final LiveKitCredentials credentials =
          await _tokenRepository.fetchCredentials(
        room: roomName.value,
        identity: identity.value,
        displayName: 'Flutter Physical Device',
      );

      status.value = SpikeConnectionStatus.connecting;
      _log('Preparing LiveKit connection url=${credentials.url}');

      final Room room = Room();
      _room = room;
      _attachRoomEvents(room);

      const RoomOptions roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      );

      await room.prepareConnection(credentials.url, credentials.token);
      await room.connect(
        credentials.url,
        credentials.token,
        roomOptions: roomOptions,
      );

      final LocalParticipant? participant = room.localParticipant;
      if (participant == null) {
        throw StateError('LiveKit connected without a local participant.');
      }

      await participant.setMicrophoneEnabled(true);
      microphoneEnabled.value = true;
      _log('Local microphone published');

      if (cameraStatus.isGranted) {
        await participant.setCameraEnabled(true);
        cameraEnabled.value = true;
        _log('Local camera published');
      } else {
        cameraEnabled.value = false;
        _log('Camera denied; continuing audio-only for this run');
      }

      status.value = SpikeConnectionStatus.connected;
      _refreshRemoteVideo();
      _log('Connected room=${credentials.room} identity=${credentials.identity}');
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      status.value = SpikeConnectionStatus.error;
      _log('Connect failed: ${errorMessage.value}');
      await _disposeRoom();
    }
  }

  Future<void> toggleMicrophone() async {
    final LocalParticipant? participant = _room?.localParticipant;
    if (participant == null) return;

    final bool nextValue = !microphoneEnabled.value;
    await participant.setMicrophoneEnabled(nextValue);
    microphoneEnabled.value = nextValue;
    _log('Microphone ${nextValue ? 'enabled' : 'muted'}');
  }

  Future<void> toggleCamera() async {
    final LocalParticipant? participant = _room?.localParticipant;
    if (participant == null) return;

    final bool nextValue = !cameraEnabled.value;
    if (nextValue) {
      final PermissionStatus status = await Permission.camera.request();
      if (!status.isGranted) {
        errorMessage.value = 'Camera permission was not granted.';
        _log(errorMessage.value);
        return;
      }
    }

    await participant.setCameraEnabled(nextValue);
    cameraEnabled.value = nextValue;
    _log('Camera ${nextValue ? 'enabled' : 'disabled'}');
  }

  Future<void> switchCamera() async {
    final LocalParticipant? participant = _room?.localParticipant;
    if (participant == null || !cameraEnabled.value) return;

    final List<MediaDevice> cameras = await Hardware.instance.videoInputs();
    if (cameras.length < 2) {
      _log('Camera switch skipped: fewer than two cameras found');
      return;
    }

    LocalVideoTrack? cameraTrack;
    for (final LocalTrackPublication<LocalVideoTrack> publication
        in participant.videoTrackPublications) {
      final LocalVideoTrack? track = publication.track;
      if (track != null) {
        cameraTrack = track;
        break;
      }
    }

    if (cameraTrack == null) {
      _log('Camera switch skipped: local camera track not found');
      return;
    }

    final String? selectedId = Hardware.instance.selectedVideoInput?.deviceId;
    int currentIndex = cameras.indexWhere(
      (MediaDevice device) => device.deviceId == selectedId,
    );
    if (currentIndex < 0) currentIndex = 0;

    final MediaDevice nextCamera = cameras[(currentIndex + 1) % cameras.length];
    await cameraTrack.switchCamera(nextCamera.deviceId, fastSwitch: true);
    Hardware.instance.selectedVideoInput = nextCamera;
    _log('Switched camera to ${nextCamera.label}');
  }

  Future<void> toggleSpeaker() async {
    final bool nextValue = !speakerEnabled.value;
    await Hardware.instance.setSpeakerphoneOn(nextValue);
    speakerEnabled.value = nextValue;
    _log('Speakerphone ${nextValue ? 'enabled' : 'disabled'}');
  }

  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  Future<void> disconnect() async {
    _log('Leaving LiveKit room');
    await _disposeRoom();
    status.value = SpikeConnectionStatus.disconnected;
    microphoneEnabled.value = false;
    cameraEnabled.value = false;
    remoteVideoTrack.value = null;
    _log('Disconnected cleanly');
  }

  void _attachRoomEvents(Room room) {
    _listener = room.createListener()
      ..on<ParticipantConnectedEvent>((ParticipantConnectedEvent event) {
        _log('Participant joined: ${event.participant.identity}');
        _refreshRemoteVideo();
      })
      ..on<ParticipantDisconnectedEvent>((ParticipantDisconnectedEvent event) {
        _log('Participant left: ${event.participant.identity}');
        _refreshRemoteVideo();
      })
      ..on<TrackSubscribedEvent>((TrackSubscribedEvent event) {
        _log(
          'Track subscribed participant=${event.participant.identity} '
          'kind=${event.track.kind}',
        );
        if (event.track is RemoteVideoTrack) {
          remoteVideoTrack.value = event.track;
        }
      })
      ..on<TrackUnsubscribedEvent>((TrackUnsubscribedEvent event) {
        _log(
          'Track unsubscribed participant=${event.participant.identity} '
          'kind=${event.track.kind}',
        );
        _refreshRemoteVideo();
      })
      ..on<RoomReconnectingEvent>((RoomReconnectingEvent event) {
        status.value = SpikeConnectionStatus.reconnecting;
        _log('Room reconnecting');
      })
      ..on<RoomReconnectedEvent>((RoomReconnectedEvent event) {
        status.value = SpikeConnectionStatus.connected;
        _log('Room reconnected');
        _refreshRemoteVideo();
      })
      ..on<RoomDisconnectedEvent>((RoomDisconnectedEvent event) {
        if (status.value != SpikeConnectionStatus.error) {
          status.value = SpikeConnectionStatus.disconnected;
        }
        microphoneEnabled.value = false;
        cameraEnabled.value = false;
        remoteVideoTrack.value = null;
        _log('Room disconnected');
      });
  }

  void _refreshRemoteVideo() {
    final Room? room = _room;
    if (room == null) {
      remoteVideoTrack.value = null;
      return;
    }

    for (final RemoteParticipant participant
        in room.remoteParticipants.values) {
      for (final RemoteTrackPublication<RemoteVideoTrack> publication
          in participant.videoTrackPublications) {
        final RemoteVideoTrack? track = publication.track;
        if (track != null && publication.subscribed && !publication.muted) {
          remoteVideoTrack.value = track;
          return;
        }
      }
    }

    remoteVideoTrack.value = null;
  }

  Future<void> _disposeRoom() async {
    final EventsListener<RoomEvent>? listener = _listener;
    _listener = null;
    if (listener != null) {
      await listener.dispose();
    }

    final Room? room = _room;
    _room = null;
    if (room != null) {
      await room.disconnect();
      await room.dispose();
    }
  }

  String _friendlyError(Object error) {
    final String message = error.toString();
    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      return 'Cannot reach the token service or LiveKit server. Check LAN IP and firewall.';
    }
    if (message.startsWith('Bad state: ')) {
      return message.substring('Bad state: '.length);
    }
    return message;
  }

  void _log(String message) {
    final String timestamp = DateTime.now().toIso8601String();
    logs.insert(0, '$timestamp  $message');
    if (logs.length > 80) logs.removeLast();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeRoom());
    _tokenRepository.close();
    super.onClose();
  }
}
