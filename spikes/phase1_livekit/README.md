# Phase 1 — Flutter ↔ LiveKit ↔ Python Feasibility Spike

This directory implements the risky realtime transport proof required by `DEVELOPMENT_ROADMAP.md` before Phase 2 begins.

This is deliberately isolated from the production app. It must prove media transport on a **physical Android device** before backend, complete UI or avatar expansion continues.

## Pinned spike versions

| Component | Version |
|---|---:|
| LiveKit Server | `1.13.1` |
| LiveKit Flutter SDK | `2.8.1` |
| LiveKit Python RTC SDK | `1.1.13` |
| LiveKit Python API SDK | `1.2.0` |
| GetX | `4.7.3` |
| Dart `http` | `1.6.0` |
| permission_handler | `12.0.3` |
| python-dotenv | `1.2.2` |

The Flutter SDK is intentionally pinned to 2.8.1 for this spike rather than immediately adopting a newly published release without compatibility testing.

## Directory layout

```text
phase1_livekit/
├── .env.example
├── infrastructure/
│   ├── docker-compose.yml
│   └── livekit.yaml
├── token_service/
│   ├── requirements.txt
│   └── server.py
├── python_participant/
│   ├── requirements.txt
│   └── participant.py
├── flutter_client/
│   ├── lib/
│   ├── pubspec.yaml
│   └── tool/bootstrap_android.ps1
└── GO_NO_GO_REPORT.md
```

## Prerequisites

- Windows laptop with Docker Desktop.
- Python 3.12.
- Flutter stable and Android toolchain.
- Physical Android phone with USB debugging.
- Laptop and phone on the same Wi-Fi for the first test.
- Headphones for echo-free audio verification.

## 1. Create the local environment file

From `spikes/phase1_livekit`:

```powershell
Copy-Item .env.example .env
ipconfig
```

Edit `.env` and replace every example LAN IP with the laptop's active IPv4 address, for example `192.168.1.20`.

Do not commit `.env`.

## 2. Open Windows firewall ports

Run PowerShell as Administrator:

```powershell
New-NetFirewallRule -DisplayName "AI Teacher LiveKit Signaling" -Direction Inbound -Protocol TCP -LocalPort 7880,7881,8090 -Action Allow
New-NetFirewallRule -DisplayName "AI Teacher LiveKit Media" -Direction Inbound -Protocol UDP -LocalPort 50000-50020 -Action Allow
```

These rules are for the local feasibility test only. Production will require TLS, TURN and a separately reviewed firewall policy.

## 3. Start LiveKit

From `spikes/phase1_livekit`:

```powershell
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
docker logs -f ai-teacher-phase1-livekit
```

In another terminal:

```powershell
Test-NetConnection -ComputerName 127.0.0.1 -Port 7880
Test-NetConnection -ComputerName YOUR_LAPTOP_LAN_IP -Port 7880
Test-NetConnection -ComputerName YOUR_LAPTOP_LAN_IP -Port 7881
```

The container log must show a successful server start and the configured node IP.

## 4. Start the development token service

From `spikes/phase1_livekit`:

```powershell
py -3.12 -m venv token_service\.venv
.\token_service\.venv\Scripts\python.exe -m pip install --upgrade pip
.\token_service\.venv\Scripts\pip.exe install -r token_service\requirements.txt
.\token_service\.venv\Scripts\python.exe token_service\server.py
```

Health check:

```powershell
Invoke-RestMethod http://127.0.0.1:8090/health
Invoke-RestMethod http://YOUR_LAPTOP_LAN_IP:8090/health
```

The token service is development-only. The LiveKit API secret never goes into Flutter.

## 5. Start the Python test participant

Open another terminal in `spikes/phase1_livekit`:

```powershell
py -3.12 -m venv python_participant\.venv
.\python_participant\.venv\Scripts\python.exe -m pip install --upgrade pip
.\python_participant\.venv\Scripts\pip.exe install -r python_participant\requirements.txt
.\python_participant\.venv\Scripts\python.exe python_participant\participant.py
```

Expected behavior:

- Joins `phase1-room` as `python-test-participant`.
- Subscribes to Flutter microphone audio.
- Logs received audio frames without storing them.
- Publishes a periodic 440 Hz test tone.
- Publishes animated RGBA test video.
- Logs reconnect and participant lifecycle events.
- Cancels tasks and disconnects cleanly on shutdown.

## 6. Bootstrap and run the Flutter physical-device client

From `spikes/phase1_livekit/flutter_client`:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\bootstrap_android.ps1
flutter analyze
flutter test
flutter devices
flutter run --dart-define=TOKEN_SERVICE_URL=http://YOUR_LAPTOP_LAN_IP:8090
```

The bootstrap script adds the local-spike Android permissions and enables cleartext HTTP/WebSocket access. This is not a production network-security configuration.

On the phone:

1. Tap **Join Phase 1 Room**.
2. Allow microphone and camera.
3. Confirm the Python animated video appears.
4. Confirm the periodic test tone is audible.
5. Speak and confirm Python logs incoming audio frames.
6. Test mute/unmute.
7. Test camera off/on.
8. Test front/back camera switch.
9. Test speaker/earpiece route.
10. Leave and verify both sides clean up.

## 7. Required network matrix

Record each result in `GO_NO_GO_REPORT.md`:

- Same Wi-Fi.
- Phone on mobile data with a reachable test deployment later in Phase 1.
- Restricted Wi-Fi/firewall scenario.
- Temporary Wi-Fi loss and recovery.
- App foreground → background → foreground.
- Phone speaker.
- Wired headset.
- Bluetooth headset.

The local Docker setup alone cannot prove mobile-data or restrictive-network success. Those tests will determine the TURN/TLS requirement for the next environment.

## 8. Required measurements

Capture at least:

- Connection time for 20 runs; calculate P50 and P95.
- Reconnect attempts and success count.
- Packet-loss/jitter observations from logs or diagnostics.
- Phone CPU, RAM and battery observation.
- Python worker CPU and RAM.
- Remaining participants/processes after leave.
- Any audio-route failure.

## 9. Stop and reset

Stop Flutter and Python with `Ctrl+C`, then:

```powershell
docker compose --env-file .env -f infrastructure/docker-compose.yml down
```

Confirm:

```powershell
docker ps --filter name=ai-teacher-phase1-livekit
Get-Process python -ErrorAction SilentlyContinue
```

Do not kill unrelated Python processes blindly.

## Phase 1 exit gate

Phase 1 passes only when all are true:

- Physical Android device joins.
- Flutter publishes microphone and camera.
- Python receives user audio.
- Python publishes generated audio and video.
- Flutter renders remote video and plays remote audio.
- Mute, camera controls and camera switch work.
- Reconnect works under temporary network loss.
- Foreground/background behavior is documented.
- No permanent ghost participant or worker process remains.

If any core transport condition fails, the result is **No-Go** and Phase 2 must not start until the transport issue is resolved.
