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
    speakerEnabled.value = Hardware.instance.preferSpeakerOutput;
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
      await _disposeRoom();

      status.value = SpikeConnectionStatus.requestingPermissions;
      _log('Requesting microphone, camera and Bluetooth permissions');

      final Map<Permission, PermissionStatus> permissions = await <Permission>[
        Permission.microphone,
        Permission.camera,
        Permission.bluetooth,
        Permission.bluetoothConnect,
      ].request();

      final PermissionStatus microphoneStatus =
          permissions[Permission.microphone] ?? PermissionStatus.denied;
      final PermissionStatus cameraStatus =
          permissions[Permission.camera] ?? PermissionStatus.denied;
      final PermissionStatus bluetoothStatus =
          permissions[Permission.bluetooth] ?? PermissionStatus.denied;
      final PermissionStatus bluetoothConnectStatus =
          permissions[Permission.bluetoothConnect] ?? PermissionStatus.denied;

      if (!microphoneStatus.isGranted) {
        throw StateError('Microphone permission is required for Phase 1.');
      }

      if (!bluetoothStatus.isGranted && !bluetoothConnectStatus.isGranted) {
        _log(
          'Bluetooth permission not granted; headset test may be unavailable',
        );
      }

      status.value = SpikeConnectionStatus.fetchingToken;
      _log('Fetching development room token');

      final LiveKitCredentials credentials = await _tokenRepository
          .fetchCredentials(
            room: roomName.value,
            identity: identity.value,
            displayName: 'Flutter Physical Device',
          );

      status.value = SpikeConnectionStatus.connecting;
      _log('Preparing LiveKit connection url=${credentials.url}');

      const RoomOptions roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      );
      final Room room = Room(roomOptions: roomOptions);
      _room = room;
      _attachRoomEvents(room);

      await room.prepareConnection(credentials.url, credentials.token);
      await room.connect(credentials.url, credentials.token);

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
      _log(
        'Connected room=${credentials.room} identity=${credentials.identity}',
      );
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      status.value = SpikeConnectionStatus.error;
      _log('Connect failed: ${errorMessage.value}');
      await _disposeRoom();
    }
  }

  Future<void> toggleMicrophone() async {
    await _runControl('microphone', () async {
      final LocalParticipant? participant = _room?.localParticipant;
      if (participant == null) return;

      final bool nextValue = !microphoneEnabled.value;
      await participant.setMicrophoneEnabled(nextValue);
      microphoneEnabled.value = nextValue;
      _log('Microphone ${nextValue ? 'enabled' : 'muted'}');
    });
  }

  Future<void> toggleCamera() async {
    await _runControl('camera', () async {
      final LocalParticipant? participant = _room?.localParticipant;
      if (participant == null) return;

      final bool nextValue = !cameraEnabled.value;
      if (nextValue) {
        final PermissionStatus permissionStatus = await Permission.camera
            .request();
        if (!permissionStatus.isGranted) {
          throw StateError('Camera permission was not granted.');
        }
      }

      await participant.setCameraEnabled(nextValue);
      cameraEnabled.value = nextValue;
      _log('Camera ${nextValue ? 'enabled' : 'disabled'}');
    });
  }

  Future<void> switchCamera() async {
    await _runControl('camera switch', () async {
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
        if (track != null && publication.source == TrackSource.camera) {
          cameraTrack = track;
          break;
        }
      }

      if (cameraTrack == null) {
        _log('Camera switch skipped: local camera track not found');
        return;
      }

      final String? selectedId = cameraTrack.currentOptions.deviceId;
      int currentIndex = cameras.indexWhere(
        (MediaDevice device) => device.deviceId == selectedId,
      );
      if (currentIndex < 0) currentIndex = 0;

      final MediaDevice nextCamera =
          cameras[(currentIndex + 1) % cameras.length];
      await cameraTrack.switchCamera(nextCamera.deviceId, fastSwitch: true);
      _log('Switched camera to ${nextCamera.label}');
    });
  }

  Future<void> toggleSpeaker() async {
    await _runControl('speaker route', () async {
      if (!Hardware.instance.canSwitchSpeakerphone) {
        _log('Speakerphone switching is not supported on this device');
        return;
      }

      final bool nextValue = !speakerEnabled.value;
      final Room? room = _room;
      if (room == null) return;
      await room.setSpeakerOn(nextValue);
      speakerEnabled.value = nextValue;
      _log('Speakerphone ${nextValue ? 'enabled' : 'disabled'}');
    });
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
          remoteVideoTrack.value = event.track as RemoteVideoTrack;
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
        _log('Room performing full reconnect');
      })
      ..on<RoomResumingEvent>((RoomResumingEvent event) {
        status.value = SpikeConnectionStatus.reconnecting;
        _log('Room resuming signaling connection');
      })
      ..on<RoomAttemptReconnectEvent>((RoomAttemptReconnectEvent event) {
        _log(
          'Reconnect attempt ${event.attempt}/${event.maxAttemptsRetry}; '
          'next delay ${event.nextRetryDelaysInMs} ms',
        );
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
        _log('Room disconnected reason=${event.reason}');
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

  Future<void> _runControl(
    String controlName,
    Future<void> Function() action,
  ) async {
    try {
      errorMessage.value = '';
      await action();
    } catch (error) {
      errorMessage.value = _friendlyError(error);
      _log('$controlName failed: ${errorMessage.value}');
    }
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
        message.contains('Connection refused') ||
        message.contains('Cannot reach token service')) {
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
