# AI Teacher — Complete Development Roadmap

**Document role:** पूरे development execution की single source of truth।  
**Branch:** `development`  
**Verification date:** 2026-08-01  
**Related documents:** [`README.md`](README.md), [`TECH_STACK.md`](TECH_STACK.md)

> Roadmap एक ही file में रहेगा। Phase-wise अलग planning files नहीं बनेंगी। कोई phase skip नहीं होगा। अगला phase तभी शुरू होगा जब पिछले phase के tests, deliverables, exit gate, documentation और rollback/fallback requirements पूरे हों।

---

## 1. Execution principles

1. सबसे risky realtime transport पहले prove होगा।
2. Avatar से पहले complete voice AI stable होगा।
3. Realtime avatar से पहले offline avatar quality pass होगी।
4. Django raw realtime media carry नहीं करेगा।
5. Every AI/runtime component separate compatible environment में रहेगा।
6. Exact versions benchmark/compatibility के बाद pin होंगी; production में floating versions नहीं।
7. Audio-only mode first-class fallback रहेगा।
8. No raw user audio/video recording by default.
9. Written-consent avatar assets के बिना avatar phase pass नहीं होगा।
10. “Code चलता है” phase completion नहीं है; tests, metrics, security, documentation और recovery भी आवश्यक हैं।

---

## 2. Final phase order

```text
Phase 0   Governance, scope, consent and compliance foundation
Phase 1   Flutter ↔ LiveKit ↔ Python feasibility spike
Phase 2   Monorepo scaffolding, environments, dependency locks and CI
Phase 3   Django backend foundation and authentication compatibility
Phase 4   Flutter production foundation
Phase 5   Secure session creation and LiveKit integration
Phase 6   Realtime AI-agent lifecycle skeleton
Phase 7   Speech-to-text benchmark and integration
Phase 8   LLM English-teacher brain
Phase 9   Text-to-speech benchmark and integration
Phase 10  Complete realtime voice AI
Phase 11  Offline consented MuseTalk avatar
Phase 12  Realtime avatar streaming
Phase 13  English-learning intelligence and reports
Phase 14  Product features, admin and usage limits
Phase 15  Security, privacy and commercial hardening
Phase 16  Observability, quality and cost instrumentation
Phase 17  Load, resilience, backup and disaster recovery
Phase 18  Closed staging beta
Phase 19  Controlled production launch
Phase 20  Post-launch scaling and evidence-based improvements
```

### Strict ordering rules

- Phase 1 fail होने पर product backend/UI expansion नहीं।
- Phase 10 pass होने से पहले avatar integration नहीं।
- Phase 11 pass होने से पहले realtime avatar नहीं।
- Phase 15 और 17 pass होने से पहले real-user public launch नहीं।
- Any model/framework replacement requires ADR and roadmap update.

---

## 3. Environments

| Environment | Purpose | Data | Media | AI/GPU | Release rule |
|---|---|---|---|---|---|
| Local | Daily coding | Synthetic/fake | Local LiveKit | Mock or remote dev GPU | Developer machine only |
| Development | Integrated work | Synthetic | Dedicated dev | Shared dev GPU | Auto/manual deploy |
| Staging | Production-like test | Synthetic/anonymized | Dedicated staging | Production-like GPU | Manual approval |
| Production | Real users | Real | Dedicated production | Production workers | Tagged immutable release |

Rules:

- Separate database, buckets, LiveKit keys, JWT keys and domains.
- Staging must never point to production services.
- `.env` never commit; `.env.example` only.
- Production data local laptop पर download नहीं।
- Local Windows machine Flutter/backend development के लिए; production AI Linux GPU पर।

---

## 4. Branch and delivery workflow

```text
main         Stable/release-ready
development  Integrated active development
feature/*    Individual feature
fix/*        Standard fixes
hotfix/*     Production emergency fixes
```

Every change:

1. Issue/ticket or clear scope.
2. Feature/fix branch from `development`.
3. Focused commits.
4. Tests and docs.
5. Pull request into `development`.
6. CI green.
7. Review when team size permits.
8. Staging validation.
9. Release PR from `development` to `main`.

Database/model/security changes must state migration, rollback and privacy/license impact.

---

## 5. Definition of Done for every ticket

A ticket is done only when:

- Acceptance criteria met.
- Code follows architecture boundaries.
- Unit/integration tests added where relevant.
- Loading, empty, error, cancellation and retry states handled.
- Security/privacy impact checked.
- Logs/metrics added without secrets or PII.
- API/schema documentation updated.
- Migration and rollback considered.
- New dependency/model license reviewed.
- Manual test evidence available.
- Relevant CI passes.

---

# PHASE 0 — Governance, scope, consent and compliance foundation

**Goal:** Coding से पहले product boundaries, rights, privacy और decision rules clear करना।  
**Expected effort:** 3–7 working days.

## 0.1 Product scope

- Android-first adult English-learning MVP define करें।
- Beginner और intermediate users define करें।
- One AI teacher, one voice, limited topics lock करें।
- Audio-only fallback product requirement बनाएं।
- Out-of-scope list README के अनुसार approve करें।
- Success metrics and initial latency goals approve करें।

## 0.2 Avatar/voice rights

- Avatar source strategy select करें: hired/authorized actor only.
- Written consent must cover face, voice if used, commercial use, territory, duration, storage, revocation and deletion.
- Internet-scraped/public-figure media prohibited.
- Raw asset access roles define करें।
- Asset hash and consent linkage design करें।

## 0.3 User privacy and age policy

- Initial beta adults-only या minor-support decision लिखें।
- AI disclosure wording.
- Microphone/camera purpose notice.
- Default recording policy: no raw user audio/video.
- Transcript retention and deletion policy.
- Optional recording/training consent separate रखें।
- Account export/deletion/grievance process define करें।
- India DPDP compliance checklist owner assign करें।
- Breach response contacts/process define करें।

## 0.4 Governance

- ADR template and approval rule define करें।
- Dependency/model version manifest format define करें।
- Risk register start करें।
- Security contact and incident severity levels define करें।
- Third-party notice process define करें।

## Deliverables

- Approved README scope.
- Avatar consent template/process.
- Data-retention matrix.
- Age/child-user policy.
- India DPDP compliance checklist.
- Breach response outline.
- ADR template/process.
- Initial risk register.

## Tests/review

- Product/engineering walkthrough.
- No ambiguous recording wording.
- No unlicensed avatar plan.
- Every collected data field has purpose and retention owner.

## Exit gate

- Scope approved.
- One legally usable avatar strategy exists.
- Age policy decided for beta.
- Data/consent behavior documented.
- Team accepts change-control process.

---

# PHASE 1 — Flutter ↔ LiveKit ↔ Python feasibility spike

**Goal:** Product architecture से पहले सबसे risky media connection prove करना।  
**Expected effort:** 7–14 days.

## 1.1 Local LiveKit

1. Pinned development LiveKit version select करें।
2. Local config with development key/secret.
3. Bind to LAN-accessible interface for physical device.
4. Document Windows firewall/LAN ports.
5. Confirm server logs and health.

## 1.2 Temporary Flutter spike

1. Minimal throwaway Flutter app.
2. Official LiveKit Flutter SDK.
3. Microphone/camera permissions.
4. Development token से join.
5. Publish local audio/video.
6. Render remote participant.
7. Mute/unmute.
8. Camera enable/disable/switch.
9. Join/leave/reconnect logs.
10. Foreground/background test.

## 1.3 Minimal Python participant

1. Minimal LiveKit Python worker/participant.
2. Join test room.
3. Subscribe to user audio.
4. Log track lifecycle without storing audio.
5. Publish generated test audio.
6. Publish static/test video frames.
7. Clean process on disconnect.
8. Simulate worker crash and restart behavior.

## 1.4 Network tests

- Same Wi-Fi.
- Separate network/mobile data.
- Restricted Wi-Fi/firewall scenario.
- Speaker, wired headset and Bluetooth audio routes.
- Temporary network loss and reconnect.

## Metrics

- Connection P50/P95.
- Reconnect success.
- Packet loss/jitter observations.
- Phone CPU/RAM/battery.
- Worker CPU/RAM.
- Ghost participant/process count after leave.

## Deliverables

- Spike code or retained proof branch.
- Tested commands.
- Network findings.
- TURN/TLS requirement notes.
- Go/No-Go report.

## Exit gate

- Physical Android device joins.
- Python participant receives user audio.
- Python participant publishes audio/video.
- Flutter renders remote media.
- Controls and reconnect work.
- No permanent ghost sessions/processes.

**No-Go:** Fail होने पर Phase 2 onward product build रोककर transport issue solve करें।

---

# PHASE 2 — Monorepo scaffolding, dependency locks and CI

**Goal:** Reproducible multi-service development foundation।  
**Expected effort:** 5–10 days.

**Implementation status (2026-08-02):** Scaffolding, locks, environment template, non-GPU Compose model, developer commands and CI jobs implemented. Local Python/Flutter/static checks pass. Final exit-gate evidence remains pending for an actual Docker Compose startup and hosted CI run because Docker is not installed on the current Windows workstation.

## 2.1 Repository structure

```text
mobile_app/
backend/
realtime_agent/
avatar_worker/
infrastructure/
scripts/
.github/workflows/
README.md
TECH_STACK.md
DEVELOPMENT_ROADMAP.md
```

Do not create duplicate roadmap/architecture planning files.

## 2.2 Tool/version capture

- Flutter stable and Dart version record.
- Python 3.12 backend version.
- Realtime-agent Python version.
- MuseTalk Python 3.10 plan.
- Docker Engine/Compose minimum versions.
- Ubuntu/NVIDIA target baseline.

## 2.3 Dependency locks

- Flutter `pubspec.lock` commit.
- Backend reproducible Python lock with hashes.
- Agent lock separate.
- Avatar image/digest and requirements separate.
- vLLM image by explicit tag/digest after benchmark.
- No `latest` production tag.

## 2.4 Local Compose

Non-GPU local profile:

- PostgreSQL.
- RabbitMQ.
- Django placeholder.
- LiveKit.
- Optional local object storage only when needed.

Each service:

- Health check.
- Named volume where required.
- Environment example.
- Non-default development credentials documented.
- Clean reset command.

## 2.5 CI

- Flutter format/analyze/test.
- Python lint/type strategy and unit tests.
- Django missing migration check.
- PostgreSQL integration test service.
- Authentication compatibility matrix job.
- Dockerfile build smoke tests.
- Secret scan.
- Dependency vulnerability scan.
- SBOM generation.
- License scan/report.
- Ordinary CI does not download huge GPU models.

## 2.6 Developer experience

- One setup guide inside README or scripts; no duplicate roadmap.
- `make`, task runner or scripts for common commands.
- Editor config and line endings.
- Pre-commit hooks if they improve consistency.
- Standard log and error formats.

## Exit gate

- Fresh clone starts non-GPU stack with documented commands.
- CI green.
- No committed secret.
- Lockfiles committed.
- Health checks pass.
- Auth matrix test job exists even if backend implementation follows next.

---

# PHASE 3 — Django backend foundation and authentication compatibility

**Goal:** Secure control plane and database baseline।  
**Expected effort:** 2–4 weeks.

## 3.1 Django foundation

1. Django 5.2 current security patch pin.
2. Python 3.12 current patch.
3. Settings: base/local/test/staging/production.
4. PostgreSQL connection.
5. UTC timestamps.
6. JSON structured logging.
7. Correlation/request ID.
8. Standard API error envelope.
9. `/health/live` and `/health/ready`.
10. OpenAPI generation.

## 3.2 Custom User model

Before first migration:

- UUID or safe public identifier.
- Name.
- Email/mobile choice finalized.
- Active/staff flags.
- English level and basic preferences.
- Timestamps.
- No sensitive data in JWT claims.

## 3.3 Authentication matrix

Run Matrix A and fallback Matrix B from `TECH_STACK.md`.

Test:

- Register.
- Login/token obtain.
- Access token.
- Refresh.
- Rotation.
- Blacklist/revoke.
- Logout.
- Concurrent refresh.
- Password reset.
- Password change policy.
- Expired/malformed tokens.
- Permission behavior.

Pin only passing combination.

## 3.4 Core models

- UserDevice.
- ConsentRecord.
- AiTeacher.
- AvatarProfile.
- VoiceProfile.
- PracticeTopic.
- LessonObjective.
- PracticeSession.
- SessionTurn.
- SessionTranscript.
- SessionReport.
- SessionMistake.
- UsageRecord/DailyProgress.
- AuditLog.

Keep early schema minimal; migrations evolve through reviewed changes.

## 3.5 API foundation

```text
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
POST /api/v1/auth/password-reset/request
POST /api/v1/auth/password-reset/confirm
GET  /api/v1/auth/me
PATCH /api/v1/auth/me
```

Requirements:

- Validation.
- Rate limits.
- Permission tests.
- Error contracts.
- Audit events.
- PII-safe logs.

## 3.6 Admin

- Non-obvious admin path.
- Staff permissions/least privilege.
- Users, teachers, topics, sessions and consents.
- Secrets/tokens hidden.
- Bulk destructive actions restricted.
- Admin actions audited.

## 3.7 Migration policy

- Every schema change migration.
- CI missing-migration check.
- PostgreSQL tests only.
- Expand-migrate-contract for destructive change.
- Backup/rollback note for production migration.
- Idempotent seed commands.

## Exit gate

- Auth matrix passes and exact versions pinned.
- API integration tests pass.
- Custom user model and migrations stable.
- Object-level permissions baseline works.
- Admin least privilege works.
- Django deploy checks reviewed.

---

# PHASE 4 — Flutter production foundation

**Goal:** Maintainable app shell and authentication flow।  
**Expected effort:** 2–4 weeks.

## 4.1 Architecture

Create feature-first structure from `TECH_STACK.md`.

- App routes.
- Bindings.
- Theme.
- Environment/flavor config.
- Core network/errors/storage/logging.
- Auth, dashboard, settings initial features.

## 4.2 Networking

- Dio client.
- Timeouts.
- Request IDs.
- Auth interceptor.
- Single-flight refresh logic.
- Non-idempotent requests no blind retry.
- Unified error mapping.
- Sensitive log redaction.
- Dev/staging/prod base URLs.

## 4.3 Secure storage

- Refresh token secure storage.
- Logout clears relevant secrets.
- Corrupted/missing token recovery.
- App reinstall behavior documented.
- No keys in source/build config shipped to client.

## 4.4 Screens

- Splash/bootstrap.
- AI/privacy onboarding.
- Register.
- Login.
- Password reset.
- Dashboard shell.
- Profile.
- Settings/logout.

## 4.5 GetX discipline

- Route bindings.
- Controllers presentation only.
- Use cases/repositories outside controllers.
- No API calls in widgets.
- Controller disposal tests.
- Global services minimized.

## Tests

- Use-case unit tests.
- Repository tests.
- Controller tests.
- Widget tests.
- Physical-device integration: register/login/refresh/logout.
- Offline/timeout/expired token.

## Exit gate

- Auth persists/recover correctly.
- Dev/staging flavors work.
- Flutter analyze/tests pass.
- UI has loading/error/empty states.
- Architecture boundaries reviewed.

---

# PHASE 5 — Secure session creation and LiveKit integration

**Goal:** Authenticated learner को backend-created room में safely join कराना।  
**Expected effort:** 2–3 weeks.

## 5.1 Backend content APIs

```text
GET /api/v1/teachers
GET /api/v1/topics
GET /api/v1/topics/{id}
```

Only active/eligible teacher and topic returned.

## 5.2 Start-session API

```text
POST /api/v1/practice-sessions/start
```

Steps:

1. Authenticate user.
2. Check active status.
3. Validate teacher/topic/level/mode.
4. Check daily/session/concurrency limits.
5. Prevent duplicate active session via transaction/locking.
6. Create `CREATING` session.
7. Create unguessable room name.
8. Generate short-lived minimal-grant participant token.
9. Dispatch named AI agent with validated metadata.
10. Return room URL/token/session/expiry.

## 5.3 Webhook/session lifecycle

- Signed LiveKit webhook endpoint.
- Signature validation.
- Idempotent event processing.
- Participant/room event mapping.
- Session state machine.
- Orphan/expired cleanup.
- App-killed recovery.

## 5.4 Flutter practice setup

- Teacher/topic/level selection.
- Permission pre-check.
- Start request.
- Join room.
- Local preview.
- Remote AI tile.
- Mic/camera/speaker controls.
- Network/reconnect status.
- End call and cleanup.

## Tests

- Expired token rejected.
- Another user cannot join room.
- Duplicate start does not bypass limits.
- Duplicate webhook safe.
- Agent missing handled.
- App killed mid-call.
- Network reconnect.
- Permissions denied.

## Exit gate

- Physical device end-to-end secure session works.
- LiveKit secret backend only.
- Session states correct after failures.
- No unauthorized room access.

---

# PHASE 6 — Realtime AI-agent lifecycle skeleton

**Goal:** Models से independent reliable participant lifecycle।  
**Expected effort:** 1–2 weeks.

## Tasks

1. Separate realtime-agent service.
2. Register fixed agent name.
3. Validate dispatch metadata.
4. Join assigned room.
5. Subscribe only required learner audio track.
6. Session context and per-turn context.
7. States:

```text
STARTING → IDLE → LISTENING → THINKING → SPEAKING
                                      ↘ INTERRUPTED
                                      ↘ ENDING
```

8. Unique turn IDs.
9. Cancellation token per turn.
10. Structured logs with session/room/turn IDs.
11. Hard session timeout.
12. Graceful shutdown/drain policy.
13. User leave cancels work.
14. Dummy echo/test response.
15. Internal signed callback/status event to backend if needed.
16. Health/readiness endpoints.

## Failure tests

- Worker killed mid-session.
- User leaves during thinking/speaking.
- Duplicate dispatch.
- Invalid metadata.
- Backend callback unavailable.
- Graceful deploy/restart.

## Exit gate

- Worker crash does not leave permanent active state.
- Cancellation skeleton reliable.
- Trace IDs work across app/backend/room/agent.
- Dummy audio response works without memory leak.

---

# PHASE 7 — Speech-to-text benchmark and integration

**Goal:** Indian English speech का reliable low-latency transcript।  
**Expected effort:** 2–3 weeks.

## 7.1 Evaluation dataset

- 20–50 consented/synthetic benchmark speakers.
- Male/female variety.
- Indian accent variety.
- Quiet and moderate-noise sets.
- Short and longer turns.
- Human-correct reference transcript.
- No production recording reuse without consent.

## 7.2 Candidate benchmark

- faster-whisper model candidates.
- FP16/INT8.
- WER.
- Silence hallucination.
- First partial latency.
- End-of-turn final latency.
- Real-time factor.
- VRAM/CPU.
- Model revision/hash.
- CTranslate2/CUDA/cuDNN versions.

Initial targets:

- Quiet median WER ≤ 15% goal.
- Moderate-noise median WER ≤ 25% goal.
- End-of-turn to final transcript P95 ≤ 1.5 seconds goal.

Targets can change only through documented benchmark decision.

## 7.3 Realtime integration

- Audio format/resampling.
- VAD/turn detection strategy.
- Partial transcript events.
- Final transcript trigger.
- Minimum/maximum utterance.
- Sequence numbers.
- Silence/noise handling.
- Cancellation clears stale results.
- Store final transcript by default, not raw audio.

## Tests

- Silence.
- Background speech/noise.
- Rapid short utterance.
- Long turn.
- Network jitter.
- Two sessions isolation.
- Out-of-order partials.

## Exit gate

- Selected model and runtime pinned.
- Benchmark report approved.
- No cross-session leak.
- Transcript order correct.
- Quality acceptable for teacher pipeline.

---

# PHASE 8 — LLM English-teacher brain

**Goal:** Safe, short, consistent and useful teacher responses।  
**Expected effort:** 2–3 weeks.

## 8.1 vLLM/Qwen setup

- Separate vLLM Linux GPU service.
- Qwen3-8B exact checkpoint/revision.
- BF16 vs quantized benchmark.
- Warmup/readiness.
- Private network/API authentication.
- Context and concurrency limits.
- Timeouts.
- Explicit generation parameters.

## 8.2 Provider abstraction

Interface:

- `stream_teacher_turn()`.
- `generate_session_report()`.
- `health()`.
- usage/latency metrics.

Agent must not depend directly on one API response shape outside provider adapter.

## 8.3 Teacher policy

- Prompt version stored in code/release manifest.
- Level-aware language.
- Short spoken reply.
- One question at a time.
- Important corrections only.
- Optional simple Hindi explanation.
- Encourage speaking.
- No official certification claims.
- Unsafe/inappropriate boundary.
- Prompt injection resistance.
- Conversation memory limit and summarization policy.

## 8.4 Structured output

Validate response schema before TTS.

- Spoken reply.
- Optional correction.
- Explanation.
- End-session flag.
- Safety/fallback fields if needed.

Invalid JSON:

1. Controlled repair once.
2. Safe fallback.
3. Never crash session.
4. Never speak raw malformed payload.

## Evaluation

At least 100 scripted turns:

- Grammar correction correctness.
- Shortness.
- Repetition.
- Hallucination.
- Hindi explanation clarity.
- Prompt injection.
- Unsafe conversation.
- Topic adherence.
- Beginner/intermediate behavior.

## Exit gate

- Exact model/runtime pinned.
- Streaming works.
- Evaluation report approved.
- Schema failures safe.
- Latency acceptable for voice pipeline.

---

# PHASE 9 — Text-to-speech benchmark and integration

**Goal:** Natural, cancellable and streaming-friendly English voice।  
**Expected effort:** 1–3 weeks.

## 9.1 Kokoro selection

- Exact model revision/hash.
- Selected voice.
- License snapshot.
- Audio sample rate/format.
- CPU/GPU decision.

## 9.2 Short-utterance benchmark

Test:

- 1–5 tokens.
- 6–10 tokens.
- 11–20 tokens.
- 21–50 tokens.
- Questions.
- Corrections.
- Encouragement.
- Numbers/abbreviations.
- Indian names/locations.

Measure:

- First playable audio.
- Clipping.
- Empty output.
- Mispronunciation.
- Unnatural rushing.
- Voice consistency.

## 9.3 Integration

- Text normalization.
- Sentence/chunk boundaries.
- Silence padding/click prevention.
- Fixed phrase cache.
- Cancellation on barge-in.
- Bounded queue.
- LiveKit audio publication format.

Initial goals:

- First playable audio P95 ≤ 1 second after text chunk on target hardware.
- Cancellation reaction target ≤ 300 ms after interruption signal.

## Fallback

If short utterances poor:

- Controlled grouping.
- Punctuation/pause normalization.
- Cached common phrases.
- ADR-reviewed alternative TTS.

## Exit gate

- Voice approved on phone speaker/headphones.
- Short phrases acceptable.
- No clipping/empty output pattern.
- Cancellation reliable.
- Exact revision pinned.

---

# PHASE 10 — Complete realtime voice AI

**Goal:** Avatar के बिना production-like English teacher conversation।  
**Expected effort:** 3–5 weeks.

## Pipeline

```text
User audio
→ VAD/turn detection
→ final STT
→ validated LLM turn
→ streaming TTS
→ LiveKit AI audio
```

## Tasks

1. Turn coordinator.
2. Partial captions to Flutter.
3. Final transcript triggers LLM.
4. Stream response at natural sentence boundaries.
5. TTS chunk queue.
6. Audio timestamps.
7. Echo/self-listening prevention.
8. User barge-in detection.
9. Barge-in cancels LLM/TTS/queue.
10. Old turn cannot speak after new turn.
11. Timeout/fallback messages.
12. Async transcript persistence.
13. Usage seconds.
14. End-session handling.
15. Per-stage latency metrics.
16. 20-minute soak test.

Initial goals:

- User end-of-turn to first AI audio P95 ≤ 4 seconds.
- Barge-in success ≥ 95% scripted tests.
- Controlled staging session start ≥ 99%.
- No stale reply after newer turn.

## Tests

- 50 scripted end-to-end sessions.
- 10 human pilot voice sessions.
- Rapid interruptions.
- Silence/timeouts.
- Network drop/reconnect.
- Model timeout/OOM.
- Concurrent session isolation.
- Memory/queue growth.

## Exit gate

- Voice AI genuinely usable.
- Human pilot feedback reviewed.
- Metrics and bottlenecks documented.
- Audio-only product mode stable.
- Only now Phase 11 starts.

---

# PHASE 11 — Offline consented MuseTalk avatar

**Goal:** Realtime streaming से पहले repeatable lip-synced file output।  
**Expected effort:** 2–4 weeks.

## 11.1 Asset capture

- Written consent verified.
- Stable frontal 1080p capture.
- Controlled lighting/background.
- Idle/listening/thinking/ending clips.
- No third-party logos/copyrighted content.
- Restricted raw asset storage.
- Hash and consent record linkage.

## 11.2 Runtime setup

- Separate Python 3.10/CUDA container.
- MuseTalk exact commit/model revision.
- Model download inventory.
- Transitive license audit:
  - Whisper model.
  - VAE.
  - DWPose.
  - SyncNet.
  - Face parsing/detection.
  - Restoration.
  - FFmpeg.
- Repository test media prohibited.

## 11.3 Offline generation

- Avatar preprocessing cache.
- Input validation.
- Kokoro audio input.
- MP4 output.
- A/V sync measurement.
- Flicker, mouth/teeth, identity drift review.
- GPU VRAM and real-time factor.
- Reproducibility from pinned image/weights.

## Tests

- At least 20 varied sentences.
- Short/long speech.
- Questions/numbers/names.
- Repeated generation stability.
- Corrupt input.
- Worker restart.

Initial goal:

- Offline A/V sync within approximately ±100 ms.

## Exit gate

- Output quality accepted for beta direction.
- Complete model manifest approved.
- No unclear/non-commercial component.
- No sample/test asset.
- Reproducible pinned build.

---

# PHASE 12 — Realtime avatar streaming

**Goal:** MuseTalk speaking frames को LiveKit AI video track में publish करना।  
**Expected effort:** 4–8+ weeks; highest-risk phase.

## 12.1 State renderer

- Idle loop.
- Listening loop.
- Thinking loop.
- Speaking frames.
- Ending loop.
- Cross-fade/transition rules.
- LivePortrait not used.

## 12.2 Streaming pipeline

1. TTS chunks carry timestamps.
2. Audio is master clock.
3. Bounded avatar input queue.
4. MuseTalk chunk inference.
5. Frame conversion.
6. Monotonic video timestamps.
7. Short frame buffer.
8. Backpressure strategy.
9. Drop/adapt frames rather than unlimited memory.
10. Barge-in cancels generation.
11. Switch to listening immediately.
12. Worker crash fallback to idle/static + audio.
13. Resolution/FPS profiles.
14. Flutter remote rendering and state UI.

## 12.3 GPU compatibility/capacity

Record:

- GPU model/VRAM.
- Host driver.
- Container CUDA/cuDNN/PyTorch.
- STT peak.
- vLLM peak/KV cache.
- TTS peak.
- MuseTalk peak/FPS.
- Combined one-session peak.
- Two-session contention.
- 20-minute soak.
- OOM behavior.

Do not assume all components fit one 24 GB GPU. Split LLM/avatar GPU services if measured requirement demands.

Initial goals:

- Sustained ≥20 FPS at selected beta resolution.
- A/V sync around ±120 ms P95.
- First speaking frame P95 ≤ 5 seconds.
- 15-minute stable session.
- No unbounded queue/VRAM/RAM growth.

## Tests

- 30 realtime avatar sessions.
- Rapid interrupt.
- Long AI reply limit.
- Avatar worker crash.
- Frame slowdown.
- Network impairment.
- Audio-only fallback.

## Exit gate

- Measured performance/cost documented.
- Fallback works.
- Known visual artifacts accepted/documented.
- Safe concurrency cap established.

---

# PHASE 13 — English-learning intelligence and reports

**Goal:** Talking avatar को useful structured teacher बनाना।  
**Expected effort:** 2–4 weeks.

## 13.1 Curriculum/content

- Levels.
- Topics.
- Objectives.
- Vocabulary.
- Scenario instructions.
- Opening prompts.
- Completion conditions.
- Correction policy.

## 13.2 Session learning data

- Final turns.
- Selected corrections.
- Important vocabulary.
- Objective outcome.
- Report prompt/model/rubric versions.

## 13.3 Report generation

Structured report:

- Summary.
- Grammar feedback.
- Vocabulary feedback.
- Fluency practice feedback.
- Corrected sentences.
- Useful words.
- Strengths.
- Focus area.
- Next lesson.

No numerical pronunciation score without validated acoustic evaluation.

## 13.4 Progress

- Practice minutes.
- Session count.
- Streak.
- Topic progress.
- Repeated mistake categories.
- Revision queue.
- Trends only across compatible rubric versions.

## Evaluation

- Human English teacher reviews sample reports.
- Consistency tests.
- Accent fairness review.
- Beginner readability.
- Helpful/not-helpful feedback.

## Exit gate

- Stable versioned report schema.
- Teacher-reviewed quality accepted.
- No unsupported scoring claims.
- Progress logic tested.

---

# PHASE 14 — Product features, admin and usage limits

**Goal:** Controlled beta-ready complete product।  
**Expected effort:** 2–4 weeks.

## Learner features

- Dashboard.
- Recommended topic.
- Teacher/topic selection.
- Session history.
- Report detail.
- Mistake revision.
- Progress summary.
- Settings/privacy.
- Account deletion/export request.

## Limits

- Daily minutes.
- Per-session duration.
- One active session.
- GPU concurrency.
- Plan/feature flags.
- Controlled capacity-full response.

## Admin

- Manage teacher/topic/objectives.
- Inspect failed sessions.
- Usage summaries.
- Limit configuration.
- Consent status.
- Deletion/export workflow.
- Feature flags.
- Audit actions.

## Celery/RabbitMQ

- Reports.
- Email/notification.
- Cleanup/retention.
- Progress aggregation.
- Export/deletion tasks.
- Avatar preprocessing.

Rules:

- Idempotent tasks.
- Bounded retries.
- Dead-letter/failure handling.
- Large files use object-storage reference.
- Realtime unaffected by broker outage.

## Exit gate

- Limits resistant to concurrent bypass.
- Admin least privilege/audit works.
- Background failures recover.
- Product flows complete for beta.

---

# PHASE 15 — Security, privacy and commercial hardening

**Goal:** Closed beta से पहले security, consent, legal and supply-chain readiness।  
**Expected effort:** 2–4 weeks.

## Threat model

Review Flutter, Django, LiveKit, agent, models, storage and admin for:

- Account takeover.
- Token theft.
- IDOR.
- Room hijacking.
- Webhook spoof/replay.
- Prompt injection.
- GPU/cost abuse.
- Malicious upload.
- Cross-user data leak.
- Avatar/voice misuse.
- Supply-chain/model tampering.

## Backend/security controls

- HTTPS/WSS.
- Exact hosts/CORS.
- Secure proxy settings.
- Strong external secrets.
- Rate limits.
- Object-level authorization.
- Input/file limits.
- Internal-service authentication.
- Database/storage least privilege.
- Signed/idempotent webhooks.
- Short-lived room-scoped tokens.
- Audit logs.

## Privacy/compliance

- Visible AI label.
- Correct recording indicator.
- Default no raw recording.
- Consent versions/timestamps.
- Retention/deletion implementation.
- Data export/account deletion.
- India DPDP mapping.
- Age/minor policy and legal review.
- Breach response drill/tabletop.
- Processor/vendor review.

## Supply chain

- SBOM.
- Container scan.
- Secret scan.
- Dependency license report.
- Model source/license/hash manifest.
- FFmpeg build configuration record.
- No automatic major update.
- Third-party notices.

## Exit gate

- Critical/high risks resolved or formally accepted.
- Commercial avatar/model chain audit complete.
- Privacy/deletion paths tested.
- Legal review before minor users or public launch.

---

# PHASE 16 — Observability, quality and cost instrumentation

**Goal:** Failures diagnose करना और GPU cost control करना।  
**Expected effort:** 1–3 weeks.

## Correlation and traces

Trace identifiers across:

- Flutter request.
- Backend session.
- LiveKit room.
- Agent job.
- Turn.
- STT/LLM/TTS/avatar stages.

Never log raw audio, JWT or unnecessary transcript.

## Metrics

- Active rooms/sessions.
- Start success/failure.
- Reconnect rate.
- STT latency and periodic WER benchmark.
- LLM first token/tokens.
- TTS first audio.
- Avatar FPS/queue depth/A-V sync.
- GPU utilization/VRAM/OOM.
- RabbitMQ queue depth.
- Database latency/connections.
- Webhook failures.
- Practice minutes.
- Compute cost per successful minute/session.

## Alerts

- Session failure spike.
- No AI worker.
- GPU OOM.
- Database down.
- Broker backlog.
- Storage/disk capacity.
- TURN/connectivity failures.
- Backup failure.

## Exit gate

- One failed session traceable end-to-end.
- Dashboards in staging.
- Alerts actually tested.
- Cost/minute measurable.

---

# PHASE 17 — Load, resilience, backup and disaster recovery

**Goal:** Real capacity and recovery prove करना।  
**Expected effort:** 2–5 weeks.

## Load tests

- REST endpoints.
- Session-start races.
- LiveKit benchmark methodology.
- Target concurrent rooms.
- Agent saturation.
- STT/LLM/TTS/avatar contention.
- Avatar queue backpressure.
- PostgreSQL pool saturation.
- RabbitMQ backlog.
- Network latency/loss/disconnect.

## Failure injection

- Kill agent mid-session.
- Kill avatar worker; verify audio-only.
- vLLM timeout/OOM.
- Restart Django.
- Restart RabbitMQ; realtime unaffected.
- Object storage unavailable.
- LiveKit restart behavior.
- Database temporary failure.

## Backup/restore

- Automated PostgreSQL backup.
- Object-storage backup/replication.
- Restore into clean staging.
- Validate accounts/reports/assets.
- RPO/RTO record.
- Rollback previous app/model release.

## Dependency re-verification

Before beta/release:

- Django/DRF/JWT supported/security status.
- PostgreSQL current minor/support.
- RabbitMQ supported series and Erlang.
- LiveKit server/SDK/agent compatibility.
- NVIDIA driver/CUDA matrix.
- Model licenses/hashes.

## LiveKit scaling decision

Single-node capacity insufficient होने पर only then:

- Official coordination requirement verify.
- Store/license/compatibility ADR.
- Multi-node staging.
- Rolling restart/node loss tests.

## Exit gate

- Safe concurrency limit documented.
- Graceful overload, no cascading crash.
- Backup restore succeeds.
- Rollback succeeds.
- Failure fallbacks validated.

---

# PHASE 18 — Closed staging beta

**Goal:** Small real-user group से usability, quality and cost validate करना।  
**Expected effort:** 2–5 weeks.

## Beta setup

- 10–25 consented testers.
- Adults-only unless minor policy/legal gate complete.
- One avatar/voice.
- Daily minute cap.
- Support/feedback channel.
- In-app issue report with session ID, no sensitive transcript by default.
- Staged feature flags.

## Measure

- Session start success.
- Crash-free sessions.
- Latency.
- Barge-in success.
- Avatar/voice rating.
- Correction helpfulness.
- Report helpfulness.
- Cost per minute.
- Audio-only fallback frequency.
- Network-specific failures.

## Operations

- Weekly bug triage.
- Security/privacy issue immediate escalation.
- No exaggerated marketing claims.
- Beta data deletion/retention according to policy.
- Capacity limit enforced.

Initial exit goals:

- Zero open critical security/privacy defects.
- Crash-free sessions ≥98% target.
- Session start ≥98% target in beta networks.
- Unit economics understood.
- Known avatar limitations documented.

## Exit gate

- Beta metrics accepted.
- Blocking defects fixed.
- Cost/limits viable.
- Support and incident process works.

---

# PHASE 19 — Controlled production launch

**Goal:** Safe staged Android release।

## Pre-launch

- Production domains/DNS/TLS.
- TURN/TLS tested.
- Production secrets rotated.
- Database migration rehearsed.
- Backups enabled and restored once.
- Monitoring/alerts/on-call contacts.
- Privacy policy/terms/AI disclosure.
- Consent and avatar rights records.
- Model manifest/SBOM/notices.
- Signed Android build and Play Console.
- Feature flags: avatar, model, audio-only.
- GPU concurrency hard cap.
- Incident/rollback runbook.
- Immutable tag/artifact digests.

## Rollout

1. Internal testing.
2. Closed Play testing.
3. Very small production percentage.
4. Observe 24–72 hours.
5. Expand gradually only within error/latency/cost thresholds.
6. Roll back or disable avatar independently if needed.

## Exit gate

- Stable staged launch.
- No critical privacy/security incident.
- Capacity and support manageable.
- Release manifest complete.

---

# PHASE 20 — Post-launch scaling and evidence-based improvements

**Goal:** Real metrics के आधार पर improve/scale करना, premature complexity नहीं।

Possible work only after evidence:

- Prompt and response-length optimization.
- STT improvement using lawful consented evaluation data.
- More topics.
- Second avatar/voice after consent/license/GPU test.
- Hindi TTS after quality/license benchmark.
- Payments after cost economics stable.
- Horizontal agent/avatar worker pool.
- Separate LLM/avatar GPU fleets.
- Multi-node LiveKit after ADR.
- Kubernetes only after measured operational need.
- Fine-tuning only with lawful, consented, quality-controlled data.
- Every model update full regression against baseline.

---

## 6. API implementation sequence

### Foundation

```text
GET  /api/v1/health/live
GET  /api/v1/health/ready
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
GET  /api/v1/auth/me
PATCH /api/v1/auth/me
```

### Content and sessions

```text
GET  /api/v1/teachers
GET  /api/v1/topics
GET  /api/v1/topics/{id}
POST /api/v1/practice-sessions/start
POST /api/v1/practice-sessions/{id}/end
GET  /api/v1/practice-sessions
GET  /api/v1/practice-sessions/{id}
POST /api/v1/webhooks/livekit
```

### Learning

```text
GET  /api/v1/reports/{session_id}
GET  /api/v1/progress/summary
GET  /api/v1/mistakes
POST /api/v1/reports/{id}/feedback
```

### Privacy/account

```text
GET    /api/v1/account/consents
POST   /api/v1/account/consents
POST   /api/v1/account/data-export
DELETE /api/v1/account
```

Every API requires validation, permission, error contract, OpenAPI schema and tests.

---

## 7. Mandatory test matrix

| Layer | Required tests |
|---|---|
| Flutter domain/data | Unit and repository tests |
| Flutter presentation | Controller and widget tests |
| Flutter app | Physical-device integration |
| Django | Unit + PostgreSQL integration |
| API | Contract, auth, IDOR, rate-limit |
| Database | Constraints, migrations, backup/restore |
| LiveKit | Join, reconnect, TURN, webhook, load |
| Agent | Lifecycle, cancellation, isolation, timeout |
| STT | WER, latency, noise, silence |
| LLM | Prompt regression, schema, safety, consistency |
| TTS | Short phrases, latency, clipping, cancellation |
| Avatar | Offline quality, FPS, A/V sync, identity stability |
| E2E | Scripted sessions and human pilots |
| Security | Threat model, scans, abuse tests |
| Operations | Failure injection, rollback, restore, alerts |

---

## 8. Major risks and prevention

| Risk | Prevention/fallback |
|---|---|
| Flutter/WebRTC integration fails | Phase 1 No-Go gate |
| Models conflict in one environment | Separate containers/runtime matrix |
| One GPU insufficient | Benchmark, split LLM/avatar, concurrency cap |
| High latency | Streaming, short replies, warm models, per-stage metrics |
| STT poor for Indian accent | Project benchmark and candidate selection |
| Stale AI speech | Turn IDs, cancellation, queue flush |
| Avatar blocks launch | Audio-only first-class product |
| Avatar artifacts | Offline gate, quality review, honest beta disclosure |
| Cross-user leak | Session isolation, authorization and concurrent tests |
| License issue | Model manifest, transitive audit, no sample data |
| Face/voice misuse | Written consent, restricted assets, AI disclosure |
| GPU cost explosion | Minute/concurrency limits, cost metrics |
| RabbitMQ support expires | Support calendar, reselect supported release |
| LiveKit restricted networks | TURN/TLS and real-network tests |
| Database data loss | Migrations, backups, restore drills |
| Storage loss/public exposure | Private S3 abstraction, checksums, restore tests |
| Minor-user legal risk | Age policy and legal compliance gate |
| Dependency update breaks system | Locks, digests, staging regression, ADR |

---

## 9. Realistic timeline

Assuming one developer, 2–4 focused hours/day:

| Milestone | Expected range |
|---|---:|
| Phase 0–2 feasibility/foundation | 3–5 weeks |
| Phase 3–5 backend/mobile/session | 5–8 additional weeks |
| Phase 6–10 stable voice AI | 7–11 additional weeks |
| Phase 11–12 avatar | 6–12 additional weeks |
| Phase 13–17 product/hardening | 8–13 additional weeks |
| Phase 18–19 beta/launch | 4–8 additional weeks |
| Usable closed beta | approximately 6–9 months |
| Controlled commercial launch | approximately 9–12+ months |

Calendar is an estimate. Exit gates take priority over deadlines.

---

## 10. Version and release verification

Before every public release:

1. Verify Django security patch/support.
2. Verify DRF/JWT compatibility/security.
3. Upgrade PostgreSQL to current minor in locked major.
4. Verify RabbitMQ support date and Erlang compatibility.
5. Verify LiveKit server/Flutter SDK/Agents compatibility.
6. Verify NVIDIA driver/CUDA/PyTorch/CTranslate2 matrix.
7. Re-run STT/LLM/TTS/avatar regression benchmarks.
8. Re-check every model card/license/hash.
9. Regenerate SBOM and third-party notices.
10. Review changed privacy/data flows.
11. Run backup restore and app rollback.
12. Verify feature flags and audio-only emergency fallback.

---

## 11. Roadmap change rule

This file remains the only roadmap. Change is allowed only through reviewed commit/PR containing:

- Reason.
- Alternatives.
- Dependency/order impact.
- Compatibility evidence.
- Benchmark where relevant.
- Security/privacy/license impact.
- Migration and rollback.
- Updated phase tasks and exit gate.

Do not create `*_LOCK.md`, separate final-verification documents, or duplicate phase roadmap files.

---

## 12. Final execution statement

```text
Transport first.
Voice intelligence second.
Offline avatar third.
Realtime avatar fourth.
Learning quality and scale after measured stability.
```

Development begins with Phase 0, then Phase 1 feasibility. Login/dashboard coding must not replace the mandatory realtime feasibility spike.
