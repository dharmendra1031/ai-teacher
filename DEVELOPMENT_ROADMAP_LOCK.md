# AI Teacher — Complete Development Roadmap Lock

**Status:** LOCKED FOR DEVELOPMENT  
**Roadmap version:** 1.0  
**Verification date:** 2026-08-01  
**Repository:** `dharmendra1031/ai-teacher`  
**Architecture baseline:** `ARCHITECTURE_LOCK.md`

> यह document project का execution source of truth है। किसी phase को skip नहीं किया जाएगा। अगला phase तभी शुरू होगा जब पिछले phase का exit gate, tests, documentation और rollback plan पूरा हो।

---

## 1. Roadmap को पाँच बार कैसे verify किया गया

यह roadmap पाँच independent verification passes के बाद lock किया गया है:

### Pass 1 — Architecture and dependency order

- Flutter को REST control path और WebRTC media path में अलग रखा गया।
- Django audio/video bytes carry नहीं करेगा; वह users, sessions, limits, reports और LiveKit dispatch संभालेगा।
- AI agent LiveKit room में participant बनेगा।
- Avatar से पहले voice pipeline mandatory है।
- Offline avatar से पहले realtime avatar शुरू नहीं होगा।

### Pass 2 — Runtime and dependency compatibility

- Django backend, LiveKit agent, MuseTalk worker और vLLM अलग containers/environments में रहेंगे।
- Exact package/model versions benchmark के बाद pin होंगे।
- Flutter `pubspec.lock`, Python hash-locked requirements, Docker image digests और model SHA-256 repository records में रखे जाएंगे।
- एक Python environment में Django, CUDA, vLLM और MuseTalk install करना prohibited है।

### Pass 3 — Realtime media and latency

- पहले Flutter ↔ LiveKit transport proof होगा।
- फिर dummy AI participant audio/video publish करेगा।
- फिर STT, LLM और TTS अलग-अलग benchmark होंगे।
- फिर interruption, cancellation और turn detection सहित voice pipeline बनेगी।
- अंत में MuseTalk frames को LiveKit video track पर publish किया जाएगा।

### Pass 4 — Security, privacy and licensing

- API secrets mobile app में नहीं होंगे।
- LiveKit tokens short-lived और room-scoped होंगे।
- Raw user audio/video default रूप से record नहीं होगा।
- Avatar और voice केवल written consent वाले व्यक्ति से बनेंगे।
- MuseTalk sample/test internet data production में prohibited है।
- LivePortrait production से excluded है जब तक InsightFace detection models पूरी तरह replace और re-audit न हों।
- हर runtime dependency के लिए SBOM और third-party notice बनेगा।

### Pass 5 — Testing, deployment and scaling

- Local, development, staging और production environments अलग होंगे।
- Unit, integration, contract, device, media, model-quality, load, security और disaster-recovery tests defined हैं।
- Single-node LiveKit से शुरुआत होगी। Multi-node scaling से पहले Redis-compatible coordination dependency का अलग compatibility और license ADR होगा।
- Production launch से पहले backup restore, rollback और incident runbook test होगा।

---

## 2. Final delivery order — पहले क्या बनेगा और बाद में क्या

```text
0. Governance, scope, consent and repo rules
1. Technical feasibility spike: Flutter ↔ LiveKit ↔ Python participant
2. Monorepo scaffolding, environments and CI
3. Django control backend foundation
4. Flutter application foundation
5. Practice-session control + LiveKit token/dispatch
6. Realtime AI agent skeleton
7. Speech-to-text
8. LLM teacher brain
9. Text-to-speech
10. Complete voice AI with interruption and transcript
11. Offline MuseTalk avatar
12. Realtime avatar video streaming
13. English-learning intelligence and reports
14. Product features, usage limits and admin
15. Privacy, security and commercial-release hardening
16. Observability, quality and cost instrumentation
17. Load, resilience and disaster-recovery verification
18. Closed staging beta
19. Production launch
20. Post-launch scaling and model improvement
```

### Strict rule

- Phase 10 से पहले avatar development नहीं।
- Phase 11 offline avatar pass किए बिना realtime avatar नहीं।
- Phase 17 load and recovery pass किए बिना public launch नहीं।
- किसी upstream model को केवल नाम देखकर update नहीं करना; benchmark + license review + ADR mandatory है।

---

## 3. Locked project structure

```text
ai-teacher/
├── mobile_app/                    # Flutter + GetX
├── backend/                       # Django control backend
├── realtime_agent/                # LiveKit Python voice agent
├── avatar_worker/                 # MuseTalk GPU worker
├── infrastructure/
│   ├── compose/
│   ├── livekit/
│   ├── rabbitmq/
│   ├── postgres/
│   ├── storage/
│   └── monitoring/
├── docs/
│   ├── adr/
│   ├── api/
│   ├── database/
│   ├── operations/
│   ├── privacy/
│   ├── testing/
│   └── benchmarks/
├── scripts/
├── .github/workflows/
├── ARCHITECTURE_LOCK.md
├── DEVELOPMENT_ROADMAP_LOCK.md
├── THIRD_PARTY_NOTICES.md
├── SECURITY.md
└── README.md
```

---

## 4. Environment strategy

| Environment | Purpose | Data | LiveKit | AI/GPU | Deployment rule |
|---|---|---|---|---|---|
| Local | Daily coding | Fake/local | Local dev server | Mock or remote dev GPU | No production secrets |
| Development | Team integration | Synthetic | Dedicated dev | Shared dev GPU | Auto deploy allowed |
| Staging | Production-like validation | Anonymized test | Dedicated staging | Production-like GPU | Manual approval |
| Production | Real users | Real | Dedicated production | Production workers | Tagged release only |

### Environment rules

1. Separate database, bucket, LiveKit keys and JWT signing keys.
2. Staging must never point to production database or production bucket.
3. `.env` files never commit होंगे; केवल `.env.example` commit होगा।
4. Secrets secret manager या protected deployment variables में होंगे।
5. Development में generated dummy identities और synthetic audio/video use होंगे।
6. Production data local laptop पर download नहीं होगा।

---

## 5. Git and release workflow

### Branches

- `main`: production-ready, protected.
- `develop`: integrated staging branch, coding शुरू होने पर create होगी।
- `feature/<ticket>-<name>`: feature work.
- `fix/<ticket>-<name>`: non-production fixes.
- `hotfix/<ticket>-<name>`: urgent production fix.

### Pull-request requirements

- At least one review when team has more than one developer.
- CI green.
- Database migration reviewed.
- API contract updated.
- Tests included.
- Security/privacy impact stated.
- New dependency has license and maintenance review.

### Release rules

- Semantic versioning: `vMAJOR.MINOR.PATCH`.
- Release tag points to tested commit.
- Docker image pinned by digest.
- Database migration and rollback instructions included.
- Model ID, revision and SHA-256 included in release manifest.

---

# PHASE 0 — Governance, scope, consent and product definition

**Goal:** Coding से पहले project boundaries और legal/ethical rules clear करना।  
**Estimated time:** 3–5 working days.

## Detailed steps

1. Product statement लिखें: self-hosted AI English teacher with live voice and realistic consented avatar.
2. MVP audience तय करें: Android, Indian English learners, beginner/intermediate.
3. MVP में एक teacher, एक English voice और limited topics रखें।
4. Out-of-scope list lock करें:
   - Full-body avatar नहीं।
   - Voice cloning नहीं।
   - Multiple avatars नहीं।
   - iOS launch first release में नहीं।
   - User emotion diagnosis नहीं।
   - Official IELTS/TOEFL scoring claim नहीं।
5. Actor consent template बनाएं जिसमें face, voice, duration, territory, commercial use, revocation और deletion terms हों।
6. User consent text बनाएं: AI disclosure, microphone/camera permission, recording status और deletion rights.
7. Data-retention matrix बनाएं:
   - Account data.
   - Transcript.
   - Optional audio/video.
   - Logs.
   - Payment records.
8. Architecture Decision Record template `docs/adr/ADR-TEMPLATE.md` बनाएं।
9. Risk register शुरू करें: GPU cost, latency, model licensing, face artifacts, WebRTC connectivity, privacy.
10. Product acceptance definitions लिखें: teacher listens, responds, corrects and produces session summary.

## Deliverables

- `docs/product/MVP_SCOPE.md`
- `docs/privacy/AVATAR_CONSENT_REQUIREMENTS.md`
- `docs/privacy/DATA_RETENTION_MATRIX.md`
- `docs/adr/ADR-TEMPLATE.md`
- `docs/RISK_REGISTER.md`

## Exit gate

- Scope approved.
- One legally usable avatar source strategy selected.
- No disputed or internet-scraped identity asset.
- Data retention and deletion behavior documented.

---

# PHASE 1 — Technical feasibility spike

**Goal:** सबसे risky media flow को product code से पहले prove करना।  
**Estimated time:** 7–14 days.

## Step 1.1 — Local LiveKit server

1. Pinned LiveKit server image/local binary select करें।
2. Local dev key/secret only development के लिए configure करें।
3. Server को LAN-accessible bind करें ताकि physical Android device connect कर सके।
4. Health/log verification करें।
5. Ports और Windows firewall behavior document करें।

## Step 1.2 — Minimal Flutter client

1. Temporary Flutter spike app बनाएं; production architecture अभी नहीं।
2. Official LiveKit Flutter SDK add करें।
3. Microphone और camera permissions implement करें।
4. Hard-coded development room token से connect करें।
5. Local audio/video publish करें।
6. Remote participant tiles render करें।
7. Join, leave, mute, camera switch और reconnect events log करें।

## Step 1.3 — Minimal Python participant

1. LiveKit Python agent/server starter बनाएं।
2. Named agent register करें।
3. Explicit dispatch या direct test join implement करें।
4. User audio track subscribe करें।
5. Dummy generated/sine/test audio publish करें।
6. Static test video frames publish करें।
7. Participant disconnect पर worker cleanup करें।

## Step 1.4 — Network verification

1. Same Wi-Fi test.
2. Mobile data test.
3. NAT/firewall-restricted network test.
4. TURN/TLS requirement note करें।
5. Audio route speaker/headset/Bluetooth test करें।
6. Background/foreground app transition test करें।

## Measurements

- Room connect P50 and P95.
- Reconnect success.
- Audio packet loss.
- Video frame reception.
- CPU/RAM on phone and agent.

## Exit gate

- Physical Android phone room join करता है।
- Python participant joins and publishes audio/video.
- Flutter remote media renders.
- Mic/camera controls work.
- Clean leave के बाद ghost participant/process नहीं रहता।
- Known firewall/TURN requirements documented.

**No-Go rule:** यह phase fail होने पर Django, auth या avatar work शुरू नहीं होगा।

---

# PHASE 2 — Monorepo scaffolding, dependency lock and CI

**Goal:** सभी services के लिए reproducible foundation।  
**Estimated time:** 5–7 days.

## Detailed steps

1. Final folders create करें।
2. Root `.editorconfig`, `.gitignore`, contribution guide और coding rules जोड़ें।
3. Flutter stable version record करें using `flutter --version`.
4. `pubspec.yaml` में only required packages add करें; `pubspec.lock` commit करें।
5. Django Python minor version lock करें।
6. Backend requirements source और hash-locked output बनाएं।
7. Realtime agent requirements अलग lock करें।
8. MuseTalk worker official tested CUDA/PyTorch matrix के आधार पर अलग image बनाएं।
9. vLLM official image tag और digest benchmark branch में record करें।
10. Docker Compose local profile बनाएं:
    - PostgreSQL.
    - RabbitMQ.
    - Django.
    - LiveKit.
    - Optional SeaweedFS later.
11. Health checks define करें।
12. GitHub Actions workflows:
    - Flutter format/analyze/test.
    - Python lint/unit tests.
    - Django migration consistency check.
    - Dockerfile build smoke test.
    - Secret scan.
    - Dependency/SBOM generation.
13. CI में GPU models download न करें; GPU tests separate/manual runner पर होंगे।
14. `THIRD_PARTY_NOTICES.md` और `MODEL_MANIFEST.md` templates बनाएं।

## Exit gate

- Fresh clone से documented commands द्वारा local non-GPU stack start होता है।
- CI passes.
- No secrets committed.
- Lockfiles committed.
- All containers have health checks.

---

# PHASE 3 — Django control backend foundation

**Goal:** Business control plane बनाना, media pipeline नहीं।  
**Estimated time:** 2–3 weeks.

## Step 3.1 — Project setup

1. Django 5.2 LTS current security patch select और pin करें।
2. Django REST Framework और SimpleJWT configure करें।
3. Settings split करें: base, local, test, staging, production.
4. PostgreSQL connection and connection health endpoint बनाएं।
5. UTC database/application timestamps enforce करें।
6. Structured JSON logging and correlation ID middleware बनाएं।
7. Standard API error envelope define करें।
8. `/api/v1/health/live` और `/api/v1/health/ready` endpoints बनाएं।

## Step 3.2 — Accounts and authentication

1. Custom User model first migration से पहले बनाएं।
2. Email normalization और uniqueness rule define करें।
3. Password validation and secure hashing use करें।
4. Register API.
5. Login API.
6. Access/refresh JWT.
7. Refresh rotation and blacklist.
8. Logout/revoke API.
9. Current-user API.
10. Password reset flow with expiring single-use token.
11. Login rate limits.
12. Audit events: login success/failure, logout, password change.

## Step 3.3 — Core domain models

Create and document:

- `User`
- `UserDevice`
- `AiTeacher`
- `AvatarProfile`
- `VoiceProfile`
- `PracticeTopic`
- `PracticeSession`
- `SessionTurn`
- `SessionTranscript`
- `SessionReport`
- `SessionMistake`
- `DailyUsage`
- `UserProgress`
- `ConsentRecord`
- `AuditLog`

## Step 3.4 — Migration policy

1. Every schema change gets migration.
2. Destructive migration must be expand-migrate-contract pattern.
3. Production migration backup and rollback note required.
4. CI checks missing migrations.
5. Seed data only idempotent management commands से।

## Step 3.5 — Admin

1. Secure Django Admin route.
2. Staff roles and least privilege.
3. User, teacher, topic, session and consent views.
4. Sensitive tokens/passwords never display.
5. Bulk destructive actions restricted.

## Backend testing

- Model tests.
- Service/use-case tests.
- API auth tests.
- Permission/IDOR tests.
- Token rotation/revocation tests.
- Migration from empty database test.
- PostgreSQL integration tests; SQLite-only testing prohibited.

## Exit gate

- Auth flows pass integration tests.
- Database schema documented.
- Admin works with least privilege.
- `manage.py check --deploy` issues documented/resolved for production settings.
- OpenAPI schema generated and reviewed.

---

# PHASE 4 — Flutter production foundation

**Goal:** Maintainable Android app shell और auth flow।  
**Estimated time:** 2–3 weeks.

## Step 4.1 — Architecture

Feature-first structure:

```text
lib/
├── app/
├── core/
└── features/
    ├── auth/
    ├── dashboard/
    ├── teachers/
    ├── practice_session/
    ├── video_call/
    ├── reports/
    ├── progress/
    └── settings/
```

Each feature:

```text
data/
domain/
presentation/
```

## Step 4.2 — Core services

1. Dio HTTP client.
2. Request ID headers.
3. Auth interceptor.
4. Single-flight token refresh to avoid multiple simultaneous refresh calls.
5. Secure token storage.
6. Network timeout and retry policy; non-idempotent requests auto-retry नहीं।
7. Unified error mapping.
8. App config by flavor: dev/staging/prod.
9. Logging redaction: JWT, email and secrets masked.

## Step 4.3 — GetX rules

1. GetX presentation state, navigation and DI तक सीमित।
2. Domain and data layers में GetX import prohibited.
3. Each route has Binding.
4. Permanent/global controllers minimized.
5. Controllers disposed and tested.
6. Business operations use cases/repositories में रहें।

## Step 4.4 — Screens

1. Splash/bootstrap.
2. Register.
3. Login.
4. Forgot/reset password.
5. Dashboard placeholder.
6. Profile.
7. Settings and logout.

## Step 4.5 — Mobile security

1. Refresh token secure storage में।
2. Screenshots/recording policy sensitive screens पर evaluate करें।
3. No backend, LiveKit or model secrets in APK.
4. Certificate pinning को first release में blindly enable नहीं करना; rotation strategy के बाद ADR करें।
5. Root/jailbreak detection security boundary नहीं माना जाएगा।

## Tests

- Use-case unit tests.
- Repository tests with mocked API.
- Controller tests.
- Widget tests.
- Integration test: register/login/refresh/logout.
- Offline and token-expired scenarios.

## Exit gate

- Dev/staging flavors work.
- Auth persistence and refresh reliable.
- Flutter analyze and tests pass.
- No API/business logic directly in pages.

---

# PHASE 5 — Practice-session control and LiveKit integration

**Goal:** Django-created secure session से Flutter room join कराना।  
**Estimated time:** 2 weeks.

## Backend steps

1. `POST /api/v1/practice-sessions/start` contract define करें।
2. User status, daily limit, teacher and topic validate करें।
3. Unique unguessable room name create करें।
4. Database session `CREATING` state में create करें।
5. Short-lived participant token generate करें with minimal grants.
6. Explicit named-agent dispatch create करें with metadata:
   - Session ID.
   - User ID pseudonymous reference.
   - Teacher ID.
   - Level.
   - Topic.
7. Session response return करें: room URL, token, session ID, expiry.
8. LiveKit webhook endpoint बनाएं।
9. Webhook signature verify करें।
10. Webhook events idempotently process करें।
11. Session state machine implement करें:

```text
CREATING → READY → CONNECTING → ACTIVE → ENDING → COMPLETED
                                      ↘ FAILED/CANCELLED/EXPIRED
```

12. Orphan sessions cleanup task.
13. One active session per user initially enforce करें।

## Flutter steps

1. Topic/level selector.
2. Start-session API.
3. LiveKit room connect.
4. Permission handling before token usage.
5. Local camera preview.
6. Remote AI participant renderer.
7. Mic/camera controls.
8. Network quality indicator.
9. Reconnect UI.
10. End-call confirmation and cleanup.

## Tests

- Expired token rejected.
- User cannot join another user’s room.
- Duplicate webhook safe.
- App killed mid-call leaves recoverable session.
- Agent missing produces controlled error.
- Limit check cannot be bypassed by repeated requests.

## Exit gate

- Secure end-to-end room creation works from physical device.
- Session states remain correct after disconnect/reconnect.
- LiveKit secrets are backend-only.

---

# PHASE 6 — Realtime AI agent skeleton

**Goal:** Model-independent robust agent lifecycle।  
**Estimated time:** 1–2 weeks.

## Detailed steps

1. Separate `realtime_agent` service.
2. Agent server registers with fixed `agent_name`.
3. Parse and validate dispatch metadata.
4. Join correct room as AI participant.
5. Subscribe only required user audio track.
6. Session context object create करें.
7. Implement state machine:

```text
STARTING → IDLE → LISTENING → THINKING → SPEAKING → INTERRUPTED → ENDING
```

8. Structured session/turn logs.
9. Cancellation token per turn.
10. Participant leaves तो current inference cancel.
11. Hard timeout and maximum call duration.
12. Agent health and readiness endpoints.
13. Graceful shutdown: new jobs stop, active job drain/terminate policy.
14. Send lifecycle status to Django using authenticated internal callback or signed event.
15. Dummy echo/audio response publish करें।

## Exit gate

- Worker crashes do not leave permanent active sessions.
- User interruption/cancel signal skeleton works.
- Session IDs trace across Flutter, Django, LiveKit and agent logs.

---

# PHASE 7 — Speech-to-text

**Goal:** Indian English speech को low-latency text में बदलना।  
**Estimated time:** 2 weeks.

## Step 7.1 — Benchmark dataset

1. 20–50 consented short samples collect करें across male/female and Indian accents.
2. Quiet and moderate-noise subsets.
3. Human-correct reference transcripts.
4. No production-user recording reuse without explicit consent.

## Step 7.2 — Model evaluation

1. faster-whisper small/medium/large or distil candidates benchmark करें।
2. FP16/INT8 modes compare करें।
3. Measure WER, real-time factor, VRAM and first partial latency.
4. Exact chosen model revision and SHA record करें।
5. Unsupported language behavior and hallucination-on-silence test करें।

## Step 7.3 — Realtime integration

1. VAD/turn detection strategy.
2. Audio resampling and mono format normalization.
3. Partial transcript events.
4. Final transcript on turn end.
5. Minimum/maximum utterance length.
6. Silence and noise handling.
7. User cancellation clears stale transcript.
8. Transcript sequence numbers to prevent out-of-order updates.
9. Store only final transcript by default.

## Initial quality targets

- Quiet Indian English median WER target ≤ 15% on project benchmark.
- Moderate-noise median WER target ≤ 25%.
- End-of-turn to final transcript P95 target ≤ 1.5 seconds on target GPU.

Targets may be revised only through benchmark ADR, not silently.

## Exit gate

- Benchmark report committed.
- False speech on silence acceptable.
- Partial/final transcript order correct.
- No cross-session audio leakage.

---

# PHASE 8 — LLM English-teacher brain

**Goal:** Safe, consistent, short and teachable responses।  
**Estimated time:** 2 weeks.

## Step 8.1 — vLLM server

1. Separate vLLM service.
2. Qwen3-8B exact checkpoint/revision select after benchmark.
3. Evaluate BF16 vs supported quantized checkpoint based on GPU.
4. API key/private network protection.
5. Health/readiness and model warmup.
6. Request timeout, concurrency and maximum context limits.
7. Disable uncontrolled model defaults by explicitly defining generation settings.

## Step 8.2 — Provider abstraction

Create interface so model backend can later change without rewriting agent:

- `stream_chat()`
- `generate_structured_report()`
- `health()`
- usage metrics.

## Step 8.3 — Teacher policy

1. System prompt versioned in repository.
2. Beginner/intermediate behavior.
3. One question at a time.
4. Short spoken responses.
5. Polite correction.
6. Hindi explanation text only in MVP when needed.
7. No false official score claims.
8. No unsafe or inappropriate conversations; age policy defined.
9. Prompt injection tests.
10. Conversation memory window and summarization policy.

## Step 8.4 — Structured turn output

Internal schema example:

```json
{
  "spoken_reply": "What did you buy at the market?",
  "correction": {
    "original": "I go market yesterday",
    "corrected": "I went to the market yesterday.",
    "explanation_hi": "Yesterday के कारण past tense आएगा।"
  },
  "should_end": false
}
```

Validate schema before TTS. Invalid output gets controlled repair/fallback, not direct speech.

## Evaluation set

- 100 scripted learner turns.
- Grammar correction accuracy review.
- Response length.
- Repetition.
- Hallucination.
- Hindi explanation quality.
- Unsafe prompt refusal.

## Exit gate

- Prompt/evaluation report committed.
- Streaming works.
- Invalid JSON cannot crash session.
- Responses fit spoken latency and length targets.

---

# PHASE 9 — Text-to-speech

**Goal:** Natural English voice with streaming-friendly output।  
**Estimated time:** 1–2 weeks.

## Detailed steps

1. Kokoro exact weights/revision and voice select करें।
2. Verify code and weight license records.
3. Text normalization:
   - Numbers.
   - Abbreviations.
   - Punctuation.
   - Unsupported symbols.
4. Sentence/chunk strategy for early audio.
5. Consistent sample rate.
6. Silence padding and click prevention.
7. Cache fixed prompts/greetings.
8. Cancellation when user interrupts.
9. Do not generate prohibited voice clone.
10. Hindi explanations initially captions; Hindi TTS separate future benchmark.

## Targets

- Text received to first playable audio P95 ≤ 1 second on target hardware.
- No clipped start/end.
- Stable volume.
- Correct cancellation within 300 ms target after interruption signal.

## Exit gate

- Voice quality approved on headphones and phone speaker.
- Chunk boundaries sound natural.
- Audio format accepted by LiveKit publication path.

---

# PHASE 10 — Complete realtime voice AI

**Goal:** Avatar के बिना production-like voice conversation।  
**Estimated time:** 3–4 weeks.

## Pipeline

```text
User audio
→ VAD/turn detection
→ faster-whisper
→ validated teacher LLM output
→ Kokoro streaming audio
→ LiveKit audio track
```

## Detailed steps

1. Turn coordinator implement करें।
2. Each turn unique ID.
3. Partial STT UI captions.
4. Final transcript triggers LLM.
5. LLM stream sentence boundaries identify करें।
6. TTS chunks queue करें।
7. Audio publish with timestamps.
8. User barge-in detection.
9. On barge-in:
   - Stop TTS.
   - Cancel LLM.
   - Flush queued audio.
   - Move to LISTENING.
10. Prevent AI from replying to its own speaker audio; echo control/test.
11. Timeout and fallback messages.
12. Transcript persist asynchronously without blocking media.
13. End-call summary job enqueue after session.
14. Per-stage latency metrics.
15. Session usage seconds record.

## Release targets for voice MVP

- User stops speaking to first AI audio P95 ≤ 4 seconds.
- Successful session start ≥ 99% in controlled staging tests.
- Barge-in works in ≥ 95% scripted tests.
- No stale answer speaks after a newer user turn.
- 20-minute soak call without memory leak/crash.

## Exit gate

- 50 scripted end-to-end sessions pass.
- 10 human pilot sessions reviewed.
- Latency breakdown and bottlenecks documented.
- Voice pipeline stable before avatar begins.

---

# PHASE 11 — Offline MuseTalk avatar

**Goal:** Live streaming से पहले reliable lip-synced file output।  
**Estimated time:** 2–3 weeks.

## Asset preparation

1. Written actor consent complete.
2. Controlled lighting, frontal camera and stable 1080p capture.
3. Neutral idle, listening, thinking and ending clips record करें।
4. No logos/third-party copyrighted background.
5. Raw asset access restricted.
6. Asset hash and consent record link store करें।

## Worker setup

1. Separate MuseTalk CUDA image.
2. Official model files and all transitive models inventory करें।
3. Each dependency license verify करें.
4. Repository testdata delete/ignore करें.
5. Avatar preprocessing cache.
6. Input validation.
7. AI-generated audio से MP4 output.
8. Frame flicker, mouth/teeth artifacts and identity drift review.
9. Audio-video sync measure.
10. GPU memory and real-time factor benchmark.

## Exit gate

- 20 varied sentences produce acceptable output.
- A/V sync target within ±100 ms.
- No unlicensed sample asset.
- Model/dependency manifest complete.
- Offline output reproducible from pinned image and weights.

---

# PHASE 12 — Realtime avatar streaming

**Goal:** MuseTalk-generated speaking face को live AI participant video track बनाना।  
**Estimated time:** 4–8 weeks; highest-risk phase.

## Step 12.1 — Avatar state renderer

1. Pre-generated consented loops:
   - IDLE.
   - LISTENING.
   - THINKING.
   - ENDING.
2. Loop transitions and cross-fades.
3. Speaking state MuseTalk frames से।
4. LivePortrait production में use नहीं।

## Step 12.2 — Streaming architecture

1. TTS audio chunks carry timestamps.
2. Avatar input queue with bounded size.
3. MuseTalk inference worker processes chunks.
4. Frames converted to chosen video format.
5. LiveKit video source publishes monotonic timestamps.
6. Audio remains primary clock.
7. Frame buffer prevents short jitter.
8. Backpressure drops/adjusts frames instead of unlimited memory growth.
9. User interruption cancels current avatar generation.
10. Switch immediately to listening loop after cancellation.
11. Worker crash fallback to static/idle avatar plus audio; entire call should not necessarily fail.
12. Resolution/FPS adaptive profile.

## Step 12.3 — GPU benchmark

Measure separately and combined:

- STT VRAM.
- vLLM VRAM/KV cache.
- TTS VRAM/CPU.
- MuseTalk VRAM and FPS.
- Combined peak memory.
- One-session sustained performance.
- Two-session contention test.

Do not assume all models fit on one 24 GB GPU. If combined benchmark fails, split LLM and avatar across GPUs/services or use approved quantization; do not hide OOM with unsafe retries.

## Initial targets

- Sustained output ≥ 20 FPS at chosen MVP resolution.
- A/V sync within ±120 ms P95.
- Voice-to-first-avatar-frame P95 ≤ 5 seconds.
- No unbounded queue/memory growth.
- 15-minute session stable.

## Exit gate

- 30 realtime avatar sessions pass.
- Fallback to audio-only works.
- Artifacts are documented and acceptable for beta.
- Target GPU bill and concurrency measured, not guessed.

---

# PHASE 13 — English-learning intelligence

**Goal:** System को talking avatar से useful teacher बनाना।  
**Estimated time:** 2–3 weeks.

## Detailed steps

1. Curriculum taxonomy:
   - Levels.
   - Topics.
   - Objectives.
   - Vocabulary.
   - Scenario prompts.
2. Session objective selected before call.
3. During call corrections should not interrupt every sentence; correction policy define करें।
4. Store final turns and selected corrections.
5. Post-session structured report job.
6. Report fields:
   - Grammar feedback.
   - Vocabulary feedback.
   - Fluency practice feedback.
   - Corrected sentences.
   - Useful words.
   - Next lesson.
7. Pronunciation score label तभी जब acoustic evaluation pipeline validated हो; MVP में unsupported numerical pronunciation claims avoid करें।
8. User can mark feedback helpful/not helpful.
9. Mistake revision list.
10. Daily streak and practice minutes.
11. Progress trend based on consistent rubric versions.
12. Rubric version stored with each report.

## Evaluation

- Human English teacher reviews sample reports.
- Same transcript repeated should produce reasonably consistent report.
- Scores/feedback not discriminatory by accent.
- Explanations easy for beginners.

## Exit gate

- Teacher-reviewed quality threshold met.
- Report JSON schema stable/versioned.
- Rubric and prompt versions traceable.

---

# PHASE 14 — Product features, usage limits and admin operations

**Goal:** Controlled beta-ready product।  
**Estimated time:** 2–3 weeks.

## Features

1. Dashboard.
2. Teacher/topic selection.
3. Session history.
4. Report detail.
5. Progress summary.
6. Settings.
7. Delete account request.
8. Delete transcript/recording request where applicable.
9. Daily minute limits.
10. Session maximum duration.
11. Concurrent-session limit.
12. Subscription plan data model; payment integration only after beta economics.
13. Admin:
    - Enable/disable teacher/topic.
    - Inspect failed sessions.
    - Usage summary.
    - Consent status.
    - Data deletion processing.
14. Celery + RabbitMQ tasks only for non-realtime work:
    - Reports.
    - Emails.
    - Cleanup.
    - Aggregations.
    - Avatar preprocessing.
15. Large audio/video payload RabbitMQ messages में नहीं; object storage reference भेजें।

## Exit gate

- Limits cannot be bypassed with concurrent requests.
- Admin actions audited.
- Background retries idempotent.
- Dead-letter/failure handling documented.

---

# PHASE 15 — Security, privacy and commercial hardening

**Goal:** Staging से पहले OWASP ASVS-aligned controls और data protection।  
**Estimated time:** 2–3 weeks.

## Threat modeling

1. Data-flow diagram.
2. STRIDE review for Flutter, APIs, webhooks, internal services and object storage.
3. Abuse cases:
   - Account takeover.
   - Token theft.
   - IDOR.
   - Room hijacking.
   - Prompt injection.
   - Cost/GPU exhaustion.
   - Malicious uploads.
   - Avatar misuse.

## Backend controls

1. HTTPS only.
2. Strong secret keys outside repo.
3. Allowed hosts/CORS exact allowlist.
4. Secure proxy headers.
5. Rate limiting.
6. Object-level authorization tests.
7. Input size/format validation.
8. Upload type validation and malware strategy if uploads enabled.
9. Sensitive log redaction.
10. Database least-privileged accounts.
11. Internal service authentication and network isolation.
12. LiveKit webhook signature and replay/idempotency handling.
13. Short-lived LiveKit tokens and grants.
14. Django production deployment checks.

## Privacy controls

1. AI teacher disclosure visible in call UI.
2. Recording indicator accurate; do not imply recording when none.
3. Default no raw user video/audio retention.
4. Transcript retention configurable and documented.
5. Consent/version timestamp.
6. Account/data deletion workflow tested.
7. Actor assets separated from user assets.
8. Object storage encryption/access controls.
9. Backups follow same retention/deletion policy where legally/practically possible.

## Supply-chain controls

1. SBOM for each release.
2. Container vulnerability scan.
3. Secret scan.
4. Model manifest with source, license, revision and hash.
5. Dependency update schedule.
6. No automatic major updates.
7. `THIRD_PARTY_NOTICES.md` complete.
8. FFmpeg production build license configuration recorded.

## Exit gate

- Security checklist passes.
- Critical/high vulnerabilities resolved or formally accepted.
- Privacy and consent flows tested.
- Commercial license audit complete for shipped model chain.

---

# PHASE 16 — Observability, quality and cost instrumentation

**Goal:** Production failures को diagnose और cost control करना।  
**Estimated time:** 1–2 weeks.

## Logging and traces

1. Correlation IDs across Flutter request, Django session, LiveKit room, agent job and avatar worker.
2. Structured logs.
3. No raw audio/JWT in logs.
4. Trace each turn stages:
   - Audio received.
   - STT partial/final.
   - LLM first token/complete.
   - TTS first audio/complete.
   - Avatar first frame.
5. Error category and retry decision.

## Metrics

- Active rooms.
- Session-start success/failure.
- Reconnect rate.
- STT latency/WER sample results.
- LLM first-token latency and tokens.
- TTS first-audio latency.
- Avatar FPS and queue depth.
- GPU utilization/VRAM/OOM.
- RabbitMQ queue depth.
- Database latency/connections.
- Webhook failures.
- Daily minutes and estimated compute cost per session.

## Alerts

- High session failure rate.
- No available AI workers.
- GPU OOM.
- Database unavailable.
- Queue backlog.
- Disk/storage nearing capacity.
- TURN/connectivity failure spike.

## Exit gate

- One failed session traceable end to end.
- Metrics dashboards work in staging.
- Alerts tested, not only configured.

---

# PHASE 17 — Load, resilience and disaster recovery

**Goal:** Launch से पहले real limits और recovery prove करना।  
**Estimated time:** 2–4 weeks.

## Load tests

1. Django REST load tests.
2. Session-start race/limit tests.
3. LiveKit official load tester/benchmark methodology.
4. One, two and target concurrent AI sessions.
5. Network impairment tests: latency, packet loss, disconnect.
6. Agent worker saturation behavior.
7. Avatar queue backpressure.
8. RabbitMQ backlog and worker restart.
9. PostgreSQL connection pool saturation.

## Resilience tests

1. Kill AI agent mid-session.
2. Kill avatar worker; verify audio-only fallback.
3. Restart Django while active room exists.
4. Restart RabbitMQ; realtime call unaffected.
5. LiveKit restart behavior and user messaging.
6. vLLM timeout/OOM fallback.
7. Object storage unavailable during report; retry later.

## Backup and restore

1. Automated PostgreSQL backups.
2. Object storage backup/replication policy.
3. Restore into clean staging environment.
4. Verify data integrity and app login/report access.
5. Measure RPO/RTO.
6. Document restore commands and owner.

## LiveKit scaling decision gate

MVP/beta uses single-node LiveKit. Before multi-node:

1. Benchmark shows single node insufficient.
2. Evaluate official coordination-store requirement.
3. Validate Valkey protocol compatibility in staging or obtain legal/engineering approval for supported Redis deployment.
4. Record decision in ADR.
5. Never introduce unverified coordination backend directly in production.

## Exit gate

- Capacity report states safe concurrent-user limit.
- Graceful overload response, not cascading crash.
- Backup restore drill succeeds.
- Rollback drill succeeds.

---

# PHASE 18 — Closed staging beta

**Goal:** Small real-user group से quality and usability validate करना।  
**Estimated time:** 2–4 weeks.

## Beta plan

1. 10–25 consented testers.
2. Daily minute cap.
3. One avatar/voice.
4. Support and feedback channel.
5. In-app issue reporting with session ID, no sensitive transcript by default.
6. Track:
   - Start success.
   - Latency.
   - Crash-free sessions.
   - User-rated voice/avatar realism.
   - Correction helpfulness.
   - Cost per minute.
7. Weekly bug triage.
8. No public marketing claims until beta results.
9. Delete test user data at beta end according to policy.

## Beta exit targets

- Critical security/privacy defects: zero open.
- Crash-free session target ≥ 98%.
- Session start success target ≥ 98% in beta networks.
- Known avatar artifacts documented.
- Unit economics and daily limits understood.

---

# PHASE 19 — Production launch

**Goal:** Controlled Android release।

## Pre-launch checklist

1. Production domain/DNS/TLS.
2. TURN/TLS connectivity test.
3. Production secrets rotation.
4. Production database and migrations.
5. Backups enabled and restore-tested.
6. Monitoring and on-call contacts.
7. Privacy policy, terms, AI disclosure and consent records.
8. Third-party notices and model manifest.
9. Signed Android app and Play Console setup.
10. Staged rollout, not 100% first day.
11. Feature flag for avatar; audio-only emergency fallback.
12. Feature flag for new model/prompt.
13. Maximum GPU concurrency enforced.
14. Incident and rollback runbook ready.
15. Release tag and immutable artifact manifest.

## Launch strategy

- Internal test.
- Closed test.
- Small production percentage.
- Observe 24–72 hours.
- Gradual expansion only if metrics remain within thresholds.

---

# PHASE 20 — Post-launch scaling and improvement

**Goal:** Evidence-based scaling, not premature complexity।

## Only after real metrics

1. Optimize prompts and response length.
2. Improve STT from real consented, anonymized evaluation data.
3. Add more topics.
4. Add second voice/avatar only after asset consent and GPU impact test.
5. Consider Hindi TTS after quality/license benchmark.
6. Add payments after minute economics stable.
7. Horizontal AI worker pool.
8. Separate LLM and avatar GPUs.
9. Multi-node LiveKit only after ADR/gate.
10. Kubernetes only when Docker Compose/VM operations become proven bottleneck.
11. Fine-tuning only with lawful, consented and quality-controlled data.
12. Every model upgrade runs full regression benchmark against locked baseline.

---

## 6. API implementation order

### Foundation

```text
GET  /api/v1/health/live
GET  /api/v1/health/ready
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
GET  /api/v1/auth/me
```

### Content and sessions

```text
GET  /api/v1/teachers
GET  /api/v1/topics
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

### Account/privacy

```text
GET    /api/v1/account/consents
POST   /api/v1/account/consents
POST   /api/v1/account/data-export
DELETE /api/v1/account
```

All APIs must have OpenAPI docs, permissions, validation, error contracts and tests before considered complete.

---

## 7. Test matrix that must not be missed

| Layer | Required tests |
|---|---|
| Flutter domain | Unit tests |
| Flutter presentation | Controller + widget tests |
| Flutter app | Physical-device integration tests |
| Django | Unit + PostgreSQL integration tests |
| API | Contract, auth, permission, rate-limit tests |
| Database | Migration, constraints, backup/restore |
| LiveKit | Join, reconnect, TURN, webhook, load |
| Agent | Lifecycle, cancellation, timeout, isolation |
| STT | WER, latency, noise, silence hallucination |
| LLM | Prompt regression, schema, safety, consistency |
| TTS | First audio, quality, cancellation, clipping |
| Avatar | Offline quality, FPS, A/V sync, identity stability |
| End-to-end | Scripted conversations + human pilots |
| Security | ASVS checklist, IDOR, secrets, abuse/load |
| Operations | Rollback, restore, worker failure, alert testing |

---

## 8. Definition of Done for every ticket

A task is not done केवल इसलिए कि UI/API चल रही है। हर ticket में:

1. Acceptance criteria met.
2. Code reviewed.
3. Tests added and passing.
4. Error and cancellation path handled.
5. Logs/metrics added where needed.
6. Security/privacy impact checked.
7. API/schema docs updated.
8. Migration and rollback considered.
9. New dependency license checked.
10. No secrets/PII in logs.
11. User-visible loading/error/empty state.
12. Relevant manual test evidence.

---

## 9. Major risk register and prevention

| Risk | Prevention |
|---|---|
| All models do not fit one GPU | Separate benchmarks; split LLM/avatar GPUs; approved quantization |
| Avatar blocks project | Voice AI is independent deliverable; audio-only fallback |
| WebRTC fails on restricted networks | TURN/TLS setup and real-network testing |
| High latency | Per-stage metrics; short replies; streaming; warm models |
| Stale AI speech after interruption | Turn IDs, cancellation and queue flush |
| Cross-user data leak | Per-session isolation, authorization and tests |
| License issue | Model manifest, transitive audit, no sample data, SBOM |
| Face/voice misuse | Written consent, restricted assets, AI disclosure |
| GPU cost explosion | Minute limits, concurrency caps, cost/session metrics |
| Database migration downtime/data loss | Expand-contract migrations, backups and restore tests |
| RabbitMQ backlog | Idempotent tasks, bounded retries, dead-letter handling |
| Storage loss | Backups, checksums and restore drill |
| Dependency update breaks system | Lockfiles, image digests, staging regression, ADR |
| LiveKit multi-node coordination uncertainty | Stay single-node until compatibility/license ADR passes |

---

## 10. Realistic timeline

Assuming one developer, 2–4 focused hours/day:

| Milestone | Expected range |
|---|---:|
| Feasibility + scaffolding | 3–4 weeks |
| Backend + Flutter foundations | 4–6 weeks |
| Stable voice AI | 6–9 additional weeks |
| Offline + realtime avatar | 6–11 additional weeks |
| Learning/product/security | 6–9 additional weeks |
| Load, beta and launch | 5–8 additional weeks |
| **Usable closed beta** | **approximately 6–8 months** |
| **Controlled commercial launch** | **approximately 8–12+ months** |

Timeline is an engineering estimate, not a guarantee. Phase gates are more important than calendar dates.

---

## 11. Version-pinning rule

Architecture families are locked, but exact patch versions are pinned only when a phase starts and passes compatibility tests.

For every dependency/model record:

- Name.
- Version/tag.
- Source URL.
- License.
- Release date.
- Container digest or package hash.
- Model revision and SHA-256.
- Tested CUDA/driver/GPU.
- Benchmark result.
- Known limitations.
- Upgrade owner/date.

Never use `latest` tags in production.

---

## 12. Verification basis

This roadmap was checked against the current official documentation and primary repositories available on 2026-08-01, including:

- Flutter official app-architecture and integration-testing guidance.
- Django 5.2 LTS release notes, system checks and deployment checklist.
- PostgreSQL official versioning/support policy.
- LiveKit official self-hosting, deployment, agent dispatch, webhooks and benchmark documentation.
- Celery stable broker documentation and RabbitMQ official release/security documentation.
- faster-whisper official repository and benchmarks.
- Qwen3 official repository/license.
- vLLM official OpenAI-compatible serving documentation.
- Kokoro official repository and model statement.
- MuseTalk official repository license/disclaimer.
- LivePortrait official license warning regarding InsightFace models.
- OWASP ASVS 5.0 guidance.

---

## 13. Change-control lock

Changing any of the following requires a new ADR, benchmark, security review and commercial-license review:

- Flutter state architecture.
- Django backend.
- PostgreSQL.
- LiveKit.
- STT model.
- LLM/model server.
- TTS model.
- Avatar model.
- Message broker.
- Object storage.
- Authentication/token design.
- Recording/retention policy.
- GPU deployment strategy.

**Final execution principle:** पहले transport prove करें, फिर voice intelligence, फिर offline avatar, फिर realtime avatar, फिर product scale। इस order को बदलना project risk बढ़ाएगा और बिना ADR allowed नहीं है।
