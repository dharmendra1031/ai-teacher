# Phase 1 Bug Audit

**Audit date:** 2026-08-02  
**Branch:** `development`  
**Scope:** Native Windows LiveKit setup, PowerShell automation, Flutter client, token service and Python participant.

## Status

- Static source audit pass 1: **COMPLETE**
- Static source audit pass 2: **COMPLETE**
- Identified source/configuration defects: **FIXED**
- Total fixed defects: **32**
- Physical Android runtime verification: **PENDING**
- Final Phase 1 GO decision: **PENDING**

A source fix is not runtime proof. `validate.ps1` must pass on the Windows laptop and the physical-device checks in `GO_NO_GO_REPORT.md` must be completed.

## Fixed defects

| ID | Severity | Defect | Resolution |
|---|---|---|---|
| P1-BUG-001 | High | `flutter create` generated a default test referencing `MyApp`, causing `flutter test` failure. | Bootstrap removes generated tests and restores reviewed tests. |
| P1-BUG-002 | High | Android manifest lacked network and Bluetooth declarations needed for device/audio-route testing. | Added camera features plus network, camera, microphone, audio and Bluetooth permissions. |
| P1-BUG-003 | High | LiveKit WebRTC plugin was not explicitly initialized before Flutter startup. | `LiveKitClient.initialize()` now runs before `runApp`. |
| P1-BUG-004 | Medium | Room options were supplied through a deprecated connection path. | `RoomOptions` now configure the `Room` constructor. |
| P1-BUG-005 | High | Signal-only resume events were not reflected in reconnect state. | Added resuming and reconnect-attempt event handling. |
| P1-BUG-006 | Medium | Remote-video assignment had unsafe type promotion. | Added an explicit checked `RemoteVideoTrack` cast. |
| P1-BUG-007 | Medium | Media-control failures could escape as unhandled async errors. | Added a shared guarded control executor and user-visible errors. |
| P1-BUG-008 | Critical | A stale Windows PID record could target an unrelated process after PID reuse. | Start/stop scripts verify executable path and command-line marker before stopping a PID. |
| P1-BUG-009 | High | Status checker could report processes alive using reused PIDs. | Checker validates process identity, expected names and command markers. |
| P1-BUG-010 | High | Service startup could fail when the repository path contained spaces. | Config and Python script arguments are explicitly quoted. |
| P1-BUG-011 | Critical | PowerShell could continue after failed Flutter, pip, Python or Git commands. | External command exit codes are enforced. |
| P1-BUG-012 | High | Existing `.env` retained an old LAN IP after network changes. | Setup refreshes LAN-derived values while preserving secrets. |
| P1-BUG-013 | High | Windows PowerShell 5.1 could write `.env` with a UTF-8 BOM and corrupt the first dotenv key. | `.env` is written as UTF-8 without BOM. |
| P1-BUG-014 | Medium | Flutter token parsing could crash on invalid URLs, empty bodies or non-JSON errors. | Added URL validation, timeout handling and safe JSON/error parsing. |
| P1-BUG-015 | High | Python video source was not explicitly closed and early failures could bypass cleanup. | Media setup is inside `try/finally`; sources and room close deterministically. |
| P1-BUG-016 | High | Python publisher-task failures could become silent task exceptions. | Background failures are logged and stop the participant cleanly. |
| P1-BUG-017 | High | Native LiveKit startup did not explicitly enforce LAN binding. | Both start paths pass `--bind 0.0.0.0`. |
| P1-BUG-018 | Medium | Checker validated health but not real token generation. | Added a complete credential-generation smoke request. |
| P1-BUG-019 | Medium | Installer did not fail on an empty archive or failed version command. | Added archive and executable exit-code verification. |
| P1-BUG-020 | Medium | Flutter speaker routing used deprecated SDK methods. | Migrated to `AudioManager`. |
| P1-BUG-021 | High | Existing Android wrappers skipped new manifest fixes during setup. | Setup runs the idempotent Android bootstrap every time. |
| P1-BUG-022 | High | `flutter_lints 6.0.0` required Dart 3.8, while pubspec allowed Dart 3.6. | Minimum Dart SDK is now 3.8.0. |
| P1-BUG-023 | High | Existing manifest with `usesCleartextTraffic="false"` was not corrected. | Bootstrap now replaces any existing value with `true` for the LAN-only spike. |
| P1-BUG-024 | Critical | Static LiveKit YAML could use a different API secret than `.env`, making issued tokens invalid. | Runtime YAML is generated from `.env` on every start. |
| P1-BUG-025 | High | Previous-run logs could make the evidence checker report a false PASS. | Startup clears all service logs before every run. |
| P1-BUG-026 | High | Automatic LAN detection could select VPN, WSL or another virtual adapter. | Setup prefers active physical Wi-Fi/Ethernet and supports `-LanIp`. |
| P1-BUG-027 | Medium | Top-level setup could not forward a manually selected LAN IP. | Added `setup_phase1.ps1 -LanIp ...` forwarding. |
| P1-BUG-028 | High | Checker tested only localhost ports, not addresses reachable by the phone. | Checker now verifies LiveKit and token-service LAN ports and LAN health. |
| P1-BUG-029 | High | Development token service could issue tokens for arbitrary rooms and identities to LAN callers. | Restricted issuance to the configured room and approved Phase 1 identity prefixes. |
| P1-BUG-030 | High | Obsolete static YAML retained hardcoded development credentials and could be used accidentally. | Removed the static YAML; only ignored runtime config is used. |
| P1-BUG-031 | Critical | Generated runtime YAML contains the API secret but `.runtime/` was not ignored by Git. | Added `.runtime/` to `.gitignore`; generated Android wrapper is also ignored. |
| P1-BUG-032 | High | Validation did not prove pinned Python SDK imports or LiveKit/token credential synchronization. | Added venv SDK/version checks and generated-config secret consistency validation. |

## Automated coverage after both audits

- PowerShell parser validation for project-owned scripts
- Python 3.12 syntax checks
- Pinned Python LiveKit package import/version checks
- Native LiveKit executable/version check
- Exact environment and URL consistency checks
- Environment-derived LiveKit config generation and key/secret synchronization
- Android permission and cleartext checks
- Dart SDK constraint check
- Flutter dependency resolution, analysis and tests
- Credential model parsing and incomplete-response rejection
- JSON and non-JSON token-service errors
- Invalid token-service URL handling
- Localhost and LAN service checks
- Runtime token-generation smoke check
- Process identity verification
- Current-run generated-media and microphone evidence

## Required local validation

```powershell
git checkout development
git pull origin development
cd spikes\phase1_livekit

powershell -ExecutionPolicy Bypass -File .\setup_phase1.ps1
powershell -ExecutionPolicy Bypass -File .\validate.ps1
powershell -ExecutionPolicy Bypass -File .\start_phase1.ps1 -RunFlutter
powershell -ExecutionPolicy Bypass -File .\check_phase1.ps1
```

When auto-detection selects the wrong interface:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_phase1.ps1 -LanIp 192.168.x.x
```

Stop the verified Phase 1 processes with:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_phase1.ps1
```

## Remaining runtime-only risks

These cannot be closed by repository review:

- Exact Flutter/Android compilation on the developer laptop
- Native LiveKit process startup on that Windows build
- Same-Wi-Fi WebRTC candidate routing
- Physical phone microphone and camera publication
- Remote generated audio/video playback
- Bluetooth, wired headset, speaker and earpiece routing
- Temporary network-loss reconnect
- Foreground/background behavior
- Clean leave with no ghost participant or process

Record those results in `GO_NO_GO_REPORT.md` before marking Phase 1 as GO.
