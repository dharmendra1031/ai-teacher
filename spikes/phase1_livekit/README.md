# Phase 1 — Flutter ↔ LiveKit ↔ Python Feasibility Spike

This isolated spike proves realtime media transport before Phase 2 begins.

## Current status

- Implementation and Windows automation: **COMPLETE**
- Docker dependency: **REMOVED**
- Two-pass static bug audit: **COMPLETE**
- Physical Android verification: **PENDING**
- Final Phase 1 decision: **NOT YET GO**

Phase 1 is not passed until physical Android media, controls, reconnect and cleanup evidence is recorded in `GO_NO_GO_REPORT.md`.

## Included files

```text
phase1_livekit/
├── setup_phase1.ps1
├── start_phase1.ps1
├── check_phase1.ps1
├── stop_phase1.ps1
├── validate.ps1
├── BUG_AUDIT.md
├── infrastructure/
│   ├── install_livekit.ps1
│   ├── setup_windows.ps1
│   ├── new_runtime_config.ps1
│   ├── start_livekit.ps1
│   ├── stop_livekit.ps1
│   └── bin/                  # generated locally; ignored
├── token_service/
├── python_participant/
├── flutter_client/
└── GO_NO_GO_REPORT.md
```

Docker Desktop and Docker Compose are not required. LiveKit runs as a native Windows executable. Its runtime YAML is generated from the ignored `.env` file, so LiveKit and the token service always use the same API key and secret.

## Pinned versions

| Component | Version |
|---|---:|
| Native LiveKit Server | `1.13.1` |
| LiveKit Flutter SDK | `2.8.1` |
| LiveKit Python RTC SDK | `1.1.13` |
| LiveKit Python API SDK | `1.2.0` |
| GetX | `4.7.3` |
| Dart `http` | `1.6.0` |
| permission_handler | `12.0.3` |
| python-dotenv | `1.2.2` |
| Minimum Dart SDK | `3.8.0` |

## Prerequisites

- Windows laptop
- Administrator PowerShell for the first setup
- Python 3.12
- Flutter stable with Dart 3.8 or newer
- Android toolchain
- Physical Android phone with USB debugging
- Laptop and phone on the same Wi-Fi
- Headphones for echo-free audio verification

## 1. Setup

Open PowerShell as Administrator:

```powershell
git checkout development
git pull origin development
cd spikes\phase1_livekit
powershell -ExecutionPolicy Bypass -File .\setup_phase1.ps1
```

The setup prefers an active physical Wi-Fi adapter, then Ethernet. VPN and virtual adapters are not preferred. Check the selected interface printed by the script.

To force the correct laptop IPv4 address:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_phase1.ps1 -LanIp 192.168.1.20
```

Setup performs these operations:

1. Downloads and checksum-verifies LiveKit Server 1.13.1.
2. Creates or refreshes the ignored `.env` file.
3. Adds local Windows Firewall rules.
4. Creates both Python virtual environments.
5. Installs pinned Python dependencies.
6. Generates or refreshes the Flutter Android wrapper.
7. Applies required Android permissions and local cleartext settings.
8. Installs Flutter dependencies.

## 2. Validate

```powershell
powershell -ExecutionPolicy Bypass -File .\validate.ps1
```

Validation checks:

- Project PowerShell syntax
- Python 3.12 source syntax
- Pinned Python SDK imports and versions
- Native LiveKit installation
- `.env` IP and URL consistency
- Environment-derived LiveKit credential synchronization
- Android permissions and cleartext setting
- Dart SDK constraint
- `flutter pub get`
- `flutter analyze`
- `flutter test`

## 3. Start services and app

Connect the physical Android phone, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\start_phase1.ps1 -RunFlutter
```

This starts:

- Native LiveKit Server
- Development token service
- Python test participant
- Flutter run terminal

Every start clears previous service logs. Runtime logs and the generated LiveKit config are stored under ignored `.runtime/`.

## 4. Test on the phone

1. Tap **Join Phase 1 Room**.
2. Allow microphone and camera.
3. Confirm the animated Python video appears.
4. Confirm the periodic test tone is audible.
5. Speak and confirm Python receives microphone frames.
6. Test mute and unmute.
7. Test camera off and on.
8. Test front and back camera switching.
9. Test speaker and earpiece routing.
10. Test a wired or Bluetooth headset when available.
11. Turn Wi-Fi off for 10 seconds and verify reconnect.
12. Send the app to background and return.
13. Leave and verify clean cleanup.

Raw microphone audio is not stored by the Python participant.

## 5. Check current-run evidence

```powershell
powershell -ExecutionPolicy Bypass -File .\check_phase1.ps1
```

The checker verifies localhost and LAN ports, token health and real credential generation, process identity, generated media publication, Flutter participant connection and received microphone frames.

The checker cannot prove that the client was a physical phone or that video/audio was visibly/audibly correct. Those checks remain manual.

## 6. Stop

Close the Flutter run terminal with `Ctrl+C`, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_phase1.ps1
```

The stop script verifies process identity before terminating recorded Phase 1 processes.

## Exit gate

Phase 1 passes only when all are true:

- Physical Android device joins.
- Flutter publishes microphone and camera.
- Python receives user audio.
- Python publishes generated audio and video.
- Flutter renders remote video and plays remote audio.
- Mute, camera controls and camera switch work.
- Audio routes are tested.
- Reconnect works after temporary network loss.
- Foreground/background behavior is documented.
- No ghost participant or process remains.

Record evidence in `GO_NO_GO_REPORT.md`. Until then the status remains **implementation complete, physical verification pending**.
