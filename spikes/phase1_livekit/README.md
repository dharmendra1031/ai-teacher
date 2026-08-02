# Phase 1 — Flutter ↔ LiveKit ↔ Python Feasibility Spike

This directory contains the isolated realtime transport proof required before Phase 2.

## Current status

- Implementation and Windows automation: **COMPLETE**
- Docker dependency: **REMOVED**
- Physical Android verification: **PENDING**
- Final Phase 1 decision: **NOT YET GO**

Phase 1 is not marked passed until the physical Android media, controls, reconnect and cleanup checks are recorded in `GO_NO_GO_REPORT.md`.

## What is included

```text
phase1_livekit/
├── setup_phase1.ps1          # one-time complete setup
├── start_phase1.ps1          # starts all local services
├── check_phase1.ps1          # automatic readiness/evidence checks
├── stop_phase1.ps1           # stops recorded Phase 1 processes
├── validate.ps1              # syntax, dependency and Flutter checks
├── infrastructure/
│   ├── install_livekit.ps1
│   ├── setup_windows.ps1
│   ├── start_livekit.ps1
│   ├── stop_livekit.ps1
│   ├── livekit.yaml
│   └── bin/                  # generated locally; ignored by Git
├── token_service/
├── python_participant/
├── flutter_client/
└── GO_NO_GO_REPORT.md
```

Docker Desktop and Docker Compose are not required. LiveKit Server runs directly as a native Windows executable.

## Pinned spike versions

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

## Prerequisites

- Windows laptop
- Administrator PowerShell for the first setup
- Python 3.12
- Flutter stable with Android toolchain
- Physical Android phone with USB debugging
- Laptop and phone on the same Wi-Fi for the first test
- Headphones for echo-free audio verification

## 1. One-time setup

Open **PowerShell as Administrator**:

```powershell
git checkout development
git pull origin development
cd spikes\phase1_livekit
powershell -ExecutionPolicy Bypass -File .\setup_phase1.ps1
```

This command:

1. Downloads and checksum-verifies native LiveKit Server.
2. Detects the laptop LAN IPv4 address.
3. Creates the ignored `.env` file.
4. Adds local Windows Firewall rules.
5. Creates both Python virtual environments.
6. Installs pinned Python dependencies.
7. Generates the Flutter Android wrapper.
8. Installs Flutter dependencies.

Review `.env` after setup. The LAN IP must match the active Wi-Fi IPv4 shown by `ipconfig`.

## 2. Validate before device testing

```powershell
powershell -ExecutionPolicy Bypass -File .\validate.ps1
```

This checks Python syntax, native LiveKit installation, required environment values, Flutter dependency resolution, Flutter analysis and Flutter tests.

## 3. Start Phase 1 services

Start LiveKit, token service and Python participant:

```powershell
powershell -ExecutionPolicy Bypass -File .\start_phase1.ps1
```

With the Android phone connected, start all services and open a Flutter run terminal:

```powershell
powershell -ExecutionPolicy Bypass -File .\start_phase1.ps1 -RunFlutter
```

Generated service logs are stored in:

```text
.runtime/
```

## 4. Test on the phone

In the Flutter app:

1. Tap **Join Phase 1 Room**.
2. Allow microphone and camera.
3. Confirm the Python animated video appears.
4. Confirm the periodic test tone is audible.
5. Speak and confirm Python receives microphone frames.
6. Test mute and unmute.
7. Test camera off and on.
8. Test front and back camera switching.
9. Test speaker and earpiece routing.
10. Turn Wi-Fi off for 10 seconds and verify reconnect.
11. Send the app to background and return.
12. Leave the room and verify clean cleanup.

Raw microphone audio is not stored by the Python participant.

## 5. Check automatic evidence

After joining from the physical phone:

```powershell
powershell -ExecutionPolicy Bypass -File .\check_phase1.ps1
```

The checker reports:

- Native LiveKit installation
- Python environments
- Flutter Android generation
- LiveKit and token-service ports
- Token-service health
- Required processes
- Generated audio publication
- Generated video publication
- Physical Flutter participant connection
- Incoming phone microphone frames

Visual remote-video rendering, audible test tone, control behavior, reconnect and clean leave still require manual confirmation.

## 6. Stop everything

Stop Flutter with `Ctrl+C`, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_phase1.ps1
```

The stop script only terminates Phase 1 processes recorded by the startup script and the native LiveKit executable from this project.

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
- No permanent ghost participant or process remains.

Record evidence in `GO_NO_GO_REPORT.md`. Until those checks are complete, the status remains **implementation complete, verification pending**.
