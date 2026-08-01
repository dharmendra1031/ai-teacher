import 'package:ai_teacher_phase1_livekit/src/presentation/livekit_spike_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveKitSpikePage extends GetView<LiveKitSpikeController> {
  const LiveKitSpikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 1 • LiveKit Spike'),
        actions: <Widget>[
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _StatusChip(status: controller.status.value),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _RemoteVideoCard(track: controller.remoteVideoTrack.value),
              const SizedBox(height: 16),
              _ConnectionSummary(controller: controller),
              if (controller.errorMessage.value.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                _ErrorPanel(
                  message: controller.errorMessage.value,
                  onOpenSettings: controller.openPermissionSettings,
                ),
              ],
              const SizedBox(height: 16),
              if (!controller.isConnected)
                FilledButton.icon(
                  onPressed: controller.isBusy ? null : controller.connect,
                  icon: controller.isBusy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.link_rounded),
                  label: Text(
                    controller.isBusy ? 'Connecting…' : 'Join Phase 1 Room',
                  ),
                )
              else
                _CallControls(controller: controller),
              const SizedBox(height: 20),
              Text(
                'Diagnostic log',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              _LogPanel(logs: controller.logs),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoteVideoCard extends StatelessWidget {
  const _RemoteVideoCard({required this.track});

  final VideoTrack? track;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF171D34),
                Color(0xFF35286F),
                Color(0xFF123D6C),
              ],
            ),
          ),
          child: track == null
              ? const _WaitingForParticipant()
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    VideoTrackRenderer(track!),
                    const Positioned(
                      left: 12,
                      top: 12,
                      child: _MediaLabel(label: 'PYTHON TEST VIDEO'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _WaitingForParticipant extends StatelessWidget {
  const _WaitingForParticipant();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.smart_toy_outlined, size: 54, color: Color(0xFF16B8C8)),
          SizedBox(height: 12),
          Text(
            'Waiting for Python participant video',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Start participant.py in the same room',
            style: TextStyle(color: Color(0xFFAEB9D5), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MediaLabel extends StatelessWidget {
  const _MediaLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC11182A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x556E7DAA)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD7DEFF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _ConnectionSummary extends StatelessWidget {
  const _ConnectionSummary({required this.controller});

  final LiveKitSpikeController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Physical-device transport check',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text('Room: ${controller.roomName.value}'),
            const SizedBox(height: 4),
            Text('Identity: ${controller.identity.value}'),
            const SizedBox(height: 4),
            Text('State: ${controller.status.value.name}'),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.onOpenSettings,
  });

  final String message;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF3A1823),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.error_outline, color: Color(0xFFFF8098)),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: onOpenSettings,
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({required this.controller});

  final LiveKitSpikeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _ControlButton(
              icon: controller.microphoneEnabled.value
                  ? Icons.mic
                  : Icons.mic_off,
              label: controller.microphoneEnabled.value ? 'Mute' : 'Unmute',
              onPressed: controller.toggleMicrophone,
            ),
            _ControlButton(
              icon: controller.cameraEnabled.value
                  ? Icons.videocam
                  : Icons.videocam_off,
              label: controller.cameraEnabled.value ? 'Camera off' : 'Camera on',
              onPressed: controller.toggleCamera,
            ),
            _ControlButton(
              icon: Icons.cameraswitch,
              label: 'Switch',
              onPressed: controller.cameraEnabled.value
                  ? controller.switchCamera
                  : null,
            ),
            _ControlButton(
              icon: controller.speakerEnabled.value
                  ? Icons.volume_up
                  : Icons.hearing_disabled,
              label: controller.speakerEnabled.value ? 'Speaker' : 'Earpiece',
              onPressed: controller.toggleSpeaker,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: controller.disconnect,
            icon: const Icon(Icons.call_end),
            label: const Text('Leave and clean room state'),
            style: FilledButton.styleFrom(
              foregroundColor: const Color(0xFFFFB7C5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150, maxHeight: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF11182A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B3556)),
      ),
      child: logs.isEmpty
          ? const Center(child: Text('No events yet'))
          : ListView.separated(
              shrinkWrap: true,
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (BuildContext context, int index) {
                return SelectableText(
                  logs[index],
                  style: const TextStyle(
                    color: Color(0xFFB8C2DE),
                    fontFamily: 'monospace',
                    fontSize: 10,
                    height: 1.4,
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SpikeConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      SpikeConnectionStatus.connected => const Color(0xFF31D0AA),
      SpikeConnectionStatus.reconnecting => const Color(0xFFFFC65A),
      SpikeConnectionStatus.error => const Color(0xFFFF8098),
      _ => const Color(0xFF9CA8CA),
    };

    return Chip(
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text(status.name),
      visualDensity: VisualDensity.compact,
    );
  }
}
