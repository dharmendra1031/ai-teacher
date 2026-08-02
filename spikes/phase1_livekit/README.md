# Phase 1 — Flutter ↔ LiveKit ↔ Python Feasibility Spike

This directory proves the riskiest realtime media connection before Phase 2 begins.

The spike is isolated from the production app. It must work on a **physical Android device** before backend, complete UI or avatar expansion continues.

## Docker status

**Docker is not required for Phase 1.**

LiveKit Server runs directly as a native Windows executable. The setup script downloads the pinned official Windows release, verifies its SHA-256 checksum and stores it in the ignored `infrastructure/bin` folder.

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

## Directory layout

```text
phase1_livekit/
├── .env.example
├── infrastructure/
│   ├── install_livekit.ps1
│   ├── setup_windows.ps1
│   ├── start_livekit.ps1
│   ├── stop_livekit.ps1
│   ├── livekit.yaml
│   └── bin/                    # generated locally; not committed
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
├── validate.ps1
└── GO_NO_GO_REPORT.md
```

## Prerequisites

- Windows laptop.
- PowerShell.
- Internet connection for the one-time LiveKit download.
- Python 3.12.
- Flutter stable and Android toolchain.
- Physical Android phone with USB debugging.
- Laptop and phone on the same Wi-Fi for the first test.
- Headphones for echo-free audio verification.

## 1. One-time Windows setup

Open **PowerShell as Administrator**, then run:

```powershell
git checkout development
git pull origin development
cd spikes\phase1_livekit
powershell -ExecutionPolicy Bypass -File .\infrastructure\setup_windows.ps1
```

The setup script:

1. Downloads LiveKit Server `1.13.1` for Windows.
2. Verifies the official SHA-256 checksum.
3. Detects the laptop LAN IPv4 address.
4. Creates `.env` without committing secrets.
5. Adds the required local Windows Firewall rules.

Review `.env` after setup. It should look similar to:

```env
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
LIVEKIT_NODE_IP=192.168.1.20
LIVEKIT_PUBLIC_URL=ws://192.168.1.20:7880
TOKEN_SERVICE_PUBLIC_URL=http://192.168.1.20:8090
ROOM_NAME=phase1-room
PYTHON_PARTICIPANT_ID=python-test-participant
TOKEN_SERVICE_HOST=0.0.0.0
TOKEN_SERVICE_PORT=8090
```

The IP must match the laptop's active Wi-Fi IPv4 address shown by `ipconfig`.

## 2. Validate source and tools

From `spikes/phase1_livekit`:

```powershell
powershell -ExecutionPolicy Bypass -File .\validate.ps1
```

This checks:

- Python syntax.
- Native LiveKit installation and version.
- Required `.env` fields.
- Flutter dependency resolution.
- Flutter analysis and tests.

It does not replace the physical-device media test.

## 3. Start native LiveKit

Open Terminal 1 in `spikes/phase1_livekit`:

```powershell
powershell -ExecutionPolicy Bypass -File .\infrastructure\start_livekit.ps1
```

Keep this window open. LiveKit logs appear directly in the terminal.

Check the ports in another window:

```powershell
Test-NetConnection -ComputerName 127.0.0.1 -Port 7880
Test-NetConnection -ComputerName YOUR_LAPTOP_LAN_IP -Port 7880
Test-NetConnection -ComputerName YOUR_LAPTOP_LAN_IP -Port 7881
```

## 4. Start the development token service

Open Terminal 2 in `spikes/phase1_livekit`:

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

Open Terminal 3 in `spikes/phase1_livekit`:

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

Open Terminal 4 in `spikes/phase1_livekit/flutter_client`:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\bootstrap_android.ps1
flutter analyze
flutter test
flutter devices
flutter run --dart-define=TOKEN_SERVICE_URL=http://YOUR_LAPTOP_LAN_IP:8090
```

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

The local Windows setup proves LAN transport only. External/restrictive tests determine the TURN/TLS requirement for the next environment.

## 8. Required measurements

Capture at least:

- Connection time for 20 runs; calculate P50 and P95.
- Reconnect attempts and success count.
- Packet-loss/jitter observations from logs or diagnostics.
- Phone CPU, RAM and battery observation.
- Native LiveKit process CPU and RAM.
- Python worker CPU and RAM.
- Remaining participants/processes after leave.
- Any audio-route failure.

## 9. Stop and reset

Stop Flutter, the token service and Python participant with `Ctrl+C`.

If the LiveKit terminal is open, press `Ctrl+C` there too. To stop it from another terminal:

```powershell
powershell -ExecutionPolicy Bypass -File .\infrastructure\stop_livekit.ps1
```

Confirm the Phase 1 processes:

```powershell
Get-Process livekit-server -ErrorAction SilentlyContinue
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
