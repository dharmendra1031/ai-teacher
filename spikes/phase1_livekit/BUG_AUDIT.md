# Phase 1 Bug Audit

**Audit date:** 2026-08-02  
**Branch:** `development`  
**Scope:** Native Windows LiveKit setup, PowerShell automation, Flutter client, token service and Python participant.

## Status

- Static source audit: **COMPLETE**
- Identified source/configuration defects: **FIXED**
- Physical Android runtime verification: **PENDING**
- Final Phase 1 GO decision: **PENDING**

A source fix is not treated as runtime proof. `validate.ps1` must pass on the Windows laptop, and the physical-device checks in `GO_NO_GO_REPORT.md` must still be completed.

## Fixed defects

| ID | Severity | Defect | Resolution |
|---|---|---|---|
| P1-BUG-001 | High | `flutter create` generated a default widget test referencing `MyApp`, causing `flutter test` failure. | Bootstrap removes generated tests and restores reviewed tests. |
| P1-BUG-002 | High | Android manifest was missing LiveKit network and Bluetooth declarations required for full device/audio-route testing. | Added camera features plus network, camera, microphone, audio and Bluetooth permissions. |
| P1-BUG-003 | High | LiveKit WebRTC plugin was not explicitly initialized before Flutter UI startup. | `LiveKitClient.initialize()` now runs before `runApp`. |
| P1-BUG-004 | Medium | Room options were supplied through a deprecated connection path. | `RoomOptions` now configure the `Room` constructor. |
| P1-BUG-005 | High | Signal-only resume events were not reflected in reconnect state. | Added resuming and reconnect-attempt event handling. |
| P1-BUG-006 | Medium | Remote-video assignment had unsafe type promotion. | Added an explicit checked `RemoteVideoTrack` cast. |
| P1-BUG-007 | Medium | Mic, camera, switch-camera and speaker failures could escape as unhandled async errors. | Added a shared guarded control executor and user-visible errors. |
| P1-BUG-008 | Critical | A stale Windows PID record could target an unrelated process after PID reuse. | Start/stop scripts now verify executable path and command-line marker before stopping a PID. |
| P1-BUG-009 | High | Status checker could report processes alive using reused PIDs. | Checker now validates process identity, expected names and command markers. |
| P1-BUG-010 | High | Service startup could break when the repository path contained spaces. | LiveKit config and Python script arguments are explicitly quoted. |
| P1-BUG-011 | Critical | PowerShell could continue after failed `flutter`, `pip`, Python compile or Git commands. | Every external command now has an enforced exit-code check. |
| P1-BUG-012 | High | Existing `.env` retained an old LAN IP after Wi-Fi/network changes. | Setup refreshes only the three LAN-derived environment values while preserving secrets. |
| P1-BUG-013 | High | Windows PowerShell 5.1 could write `.env` with a UTF-8 BOM, corrupting the first dotenv key. | `.env` is now written as UTF-8 without BOM. |
| P1-BUG-014 | Medium | Flutter token parsing could crash on invalid URLs, empty bodies or non-JSON server errors. | Added URL validation, timeout handling and safe JSON/error parsing. |
| P1-BUG-015 | High | Python video source was not explicitly closed and early publish failures could bypass cleanup. | Media setup is inside `try/finally`; audio/video sources and room are closed deterministically. |
| P1-BUG-016 | High | Python publisher-task failures could become silent/unretrieved task exceptions. | Background failures are logged and stop the participant cleanly. |
| P1-BUG-017 | High | Direct native LiveKit startup did not explicitly enforce LAN binding. | Both start paths pass `--bind 0.0.0.0`. |
| P1-BUG-018 | Medium | Checker validated token-service health but not real token generation. | Added a complete credential-generation smoke request. |
| P1-BUG-019 | Medium | LiveKit installer did not fail on an empty archive or failed binary version command. | Added archive and executable exit-code verification. |
| P1-BUG-020 | Medium | Flutter speaker routing used deprecated SDK methods. | Migrated to `AudioManager`. |

## Added automated coverage

- Credential model parsing and incomplete-response rejection.
- Token repository success response.
- JSON server error.
- Non-JSON server error.
- Invalid token-service URL.
- Project-owned PowerShell syntax parsing.
- Python syntax checks.
- Exact environment and URL consistency checks.
- Android manifest requirements.
- Flutter dependency resolution, analysis and tests.
- Runtime token-generation smoke check.
- Process identity verification.

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

Stop the verified Phase 1 processes with:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_phase1.ps1
```

## Remaining runtime-only risks

These cannot be closed by static review:

- Exact Flutter/Android compilation on the developer machine.
- Native LiveKit server startup on the selected Windows build.
- Same-Wi-Fi WebRTC candidate routing.
- Phone microphone and camera publication.
- Remote generated audio/video playback.
- Bluetooth, wired headset, speaker and earpiece routing.
- Temporary network-loss reconnect.
- Foreground/background behavior.
- Clean leave with no ghost participant or process.

Record those results in `GO_NO_GO_REPORT.md` before marking Phase 1 as GO.
