# AI Teacher — Verified Technology Stack

**Document role:** यह file project में इस्तेमाल होने वाली technologies, architecture boundaries, compatibility gates, license conditions और deployment constraints की single source of truth है।  
**Branch:** `development`  
**Verification date:** 2026-08-01  
**Status:** Approved for phased development, subject to the mandatory gates written below.

### Phase 2 reproducibility baseline

| Component | Locked baseline |
|---|---|
| Flutter / Dart | Flutter 3.44.0 / Dart 3.12.0 |
| Backend and realtime agent | Python 3.12.13 container target |
| Avatar worker plan | Python 3.10; exact patch and CUDA image deferred to Phase 11 benchmark |
| PostgreSQL | `postgres:17.10-bookworm` |
| RabbitMQ | `rabbitmq:4.3.4-management` |
| LiveKit server | `livekit/livekit-server:v1.13.1` |
| Local/production OS target | Ubuntu 24.04 LTS |
| Container tooling minimum | Docker Engine 27+, Docker Compose 2.29+ |

Flutter's `pubspec.lock` is committed. Backend, realtime-agent and avatar locks are separate; the Phase 2 placeholders intentionally have no third-party Python runtime dependencies. GPU model images, packages, weights and digests remain deferred until their mandatory benchmark and license gates, and ordinary CI does not download them.

> किसी core technology, AI model, database, realtime layer, authentication design, broker या storage implementation को बिना ADR, compatibility test, security/privacy review, benchmark और license review के replace नहीं किया जाएगा।

---

## 1. Final architecture

```text
Flutter Android App
  Flutter + GetX + feature-first Clean Architecture
                 |
                 | REST/HTTPS + short-lived JWT
                 v
Django Control Backend
  Django 5.2 LTS + Django REST Framework
                 |
                 +---- PostgreSQL 17 current minor
                 +---- Celery 5.6 + supported RabbitMQ release
                 +---- S3-compatible object-storage abstraction
                 |
                 | LiveKit token + room + explicit agent dispatch
                 v
Self-hosted LiveKit
                 |
                 +---- Flutter learner participant
                 +---- Python realtime AI participant
                              |
                              +---- faster-whisper STT
                              +---- Qwen3-8B through vLLM
                              +---- Kokoro-82M TTS
                              +---- MuseTalk avatar worker
```

### Control path और media path अलग रहेंगे

- Django login, users, permissions, lessons, session lifecycle, limits, reports, admin और audit संभालेगा।
- Django से raw realtime audio/video stream नहीं गुजरेगी।
- Flutter और AI Agent सीधे LiveKit/WebRTC room में join करेंगे।
- Celery/RabbitMQ realtime audio, frames या inference chunks carry नहीं करेंगे।

---

## 2. Locked technology families

| Area | Approved choice | Status | Important condition |
|---|---|---|---|
| Mobile | Flutter stable | Approved | Exact stable version Phase 2 में pin होगी |
| State, navigation, DI | GetX stable 4.x | Approved | GetX 5 prerelease नहीं |
| Mobile architecture | Feature-first Clean Architecture | Approved | GetX presentation layer तक सीमित |
| HTTP | Dio | Conditional | Exact release, license और interceptor behavior test |
| Secure local secrets | `flutter_secure_storage` | Conditional | Exact release audit और device test |
| Realtime Flutter client | Official LiveKit Flutter SDK | Approved | SDK/server compatibility test mandatory |
| Backend runtime | Python 3.12 latest patch | Approved | Django container में CUDA packages नहीं |
| Backend | Django 5.2 LTS current patch | Approved | Security patch updates required |
| REST API | Django REST Framework | Approved | Exact DRF version auth matrix के बाद pin होगी |
| Authentication | JWT; SimpleJWT candidate | Conditional | Django/DRF/SimpleJWT matrix पास होने पर ही lock |
| Database | PostgreSQL 17 current minor | Approved | Current minor हमेशा use करें; EOL 2029-11-08 |
| Realtime media | Self-hosted LiveKit | Approved | TLS, TURN, firewall और capacity tests mandatory |
| Realtime agent | LiveKit Agents Python SDK | Approved | Separate service/runtime |
| STT | faster-whisper | Approved candidate | Model और CUDA matrix benchmark के बाद pin |
| LLM | Qwen3-8B | Approved candidate | Exact checkpoint, quantization और hash benchmark के बाद |
| LLM serving | vLLM | Approved | Separate Linux GPU container |
| TTS | Kokoro-82M | Approved candidate | Short-utterance quality benchmark mandatory |
| Avatar | MuseTalk 1.5 | Conditional | Complete transitive-model license audit mandatory |
| Face expressions | Pre-recorded consented loops | Approved for MVP | Idle/listening/thinking/ending states |
| LivePortrait | Excluded from production | Blocked | InsightFace detection models non-commercial |
| Background jobs | Celery 5.6 | Approved | Non-realtime tasks only |
| Broker | Currently community-supported RabbitMQ series | Approved | Release support date and Erlang matrix rechecked each release |
| Object storage | S3-compatible abstraction | Approved architecture | Exact implementation durability/security tests के बाद |
| Deployment | Ubuntu Linux + Docker Compose | Approved | Production AI on NVIDIA GPU/Linux |
| Media utility | LGPL-compatible FFmpeg build | Conditional | GPL/nonfree flags prohibited unless separate legal review |

---

## 3. Mobile application stack

### Core

```text
Flutter stable
Dart bundled with selected Flutter stable
GetX stable 4.x
Dio
flutter_secure_storage
livekit_client
permission_handler
connectivity_plus
freezed / json_serializable only if selected during scaffolding
```

### Flutter architecture rule

```text
lib/
├── app/
│   ├── bindings/
│   ├── routes/
│   ├── theme/
│   └── config/
├── core/
│   ├── network/
│   ├── errors/
│   ├── storage/
│   ├── logging/
│   └── utils/
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

### GetX restrictions

- GetX केवल presentation state, navigation और dependency injection के लिए।
- Domain entities, use cases और repository contracts में GetX import नहीं होगा।
- API call page/widget से direct नहीं होगी।
- हर route का binding होगा।
- Global permanent controllers केवल app-wide services के लिए।
- Controller lifecycle और disposal tests होंगे।

### Mobile security

- Refresh token `flutter_secure_storage` में।
- Access token memory में; आवश्यकता होने पर secure storage strategy documented होगी।
- LiveKit secret, backend secret, model key या admin credential APK में नहीं होगा।
- Logs में JWT, email, transcript और PII redact होंगे।
- Certificate pinning तभी जब rotation और emergency bypass strategy ADR में हो।

---

## 4. Backend stack

### Core

```text
Python 3.12 latest patch
Django 5.2 LTS current patch
Django REST Framework
JWT authentication package after compatibility matrix
psycopg current supported PostgreSQL driver
Celery 5.6
RabbitMQ supported release
```

### Backend architecture

Django modular monolith रहेगा। Artificial repository layers बनाकर Django ORM से लड़ना नहीं है।

```text
backend/
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── local.py
│   │   ├── test.py
│   │   ├── staging.py
│   │   └── production.py
│   └── urls.py
├── apps/
│   ├── accounts/
│   ├── teachers/
│   ├── learning/
│   ├── sessions/
│   ├── reports/
│   ├── usage/
│   ├── consents/
│   └── audit/
└── common/
    ├── api/
    ├── permissions/
    ├── exceptions/
    ├── logging/
    └── utils/
```

Per app:

```text
models.py
services.py      # state-changing use cases
selectors.py     # complex reads
api/
  serializers.py
  views.py
  urls.py
tasks.py
admin.py
tests/
```

### JWT compatibility gate

Candidate matrix:

```text
Matrix A
Python 3.12 latest patch
Django latest 5.2 patch
DRF 3.17.x
SimpleJWT 5.5.x

Matrix B fallback
Python 3.12 latest patch
Django latest 5.2 patch
DRF 3.16.x
SimpleJWT 5.5.x
```

Tests:

- Login/token obtain.
- Access-token validation.
- Refresh and rotation.
- Blacklist/revocation.
- Logout.
- Concurrent refresh requests.
- Expired/malformed token.
- Custom user model.
- Password-change invalidation policy.
- Permission and object-level authorization.

Passing matrix ही exact lockfile में जाएगी। Custom JWT implementation नहीं लिखी जाएगी जब तक ADR और security review आवश्यक न कर दें।

---

## 5. Database

```text
PostgreSQL 17, always current minor release
```

PostgreSQL 17 official support 2029-11-08 तक है। Production में current minor release use करना mandatory है।

### Main data groups

- Users and devices.
- Teachers, avatars and voice profiles.
- Topics, levels, objectives and lessons.
- Practice sessions and state transitions.
- Final transcript turns.
- Corrections, reports and rubric versions.
- Practice minutes and usage limits.
- Consent, privacy requests and audit logs.
- Subscription models later; payment records when payments are added.

### Database rules

- Custom user model first migration से पहले।
- UUID/public-safe identifiers where appropriate.
- UTC timestamps.
- Database constraints business invariants enforce करें।
- PostgreSQL integration tests; SQLite substitute नहीं।
- Destructive migration के लिए expand-migrate-contract strategy।
- Backup और restore test production gate है।
- Audio/video/model binaries PostgreSQL में store नहीं होंगे।

---

## 6. Realtime media

```text
Self-hosted LiveKit Server
Official Flutter LiveKit SDK
LiveKit Agents Python SDK
WebRTC audio/video/data
```

### Production requirements

- Trusted domain and CA-signed TLS certificate.
- Secure WebSocket endpoint.
- Correct public-IP advertisement.
- UDP/TCP media ports.
- Embedded TURN configured and tested.
- TURN/TLS for restrictive networks.
- Firewall rules and network-capacity benchmark.
- Separate local, staging and production deployments.

### Scaling rule

- First feasibility और controlled beta single-node से शुरू हो सकती है।
- Single-node production use केवल documented ADR, capacity benchmark और restart-failure acceptance के बाद।
- Multi-node से पहले currently supported coordination-store requirement official LiveKit docs से re-verify होगी।
- Unverified Redis-compatible replacement production में नहीं लगाया जाएगा।

---

## 7. AI runtime separation

AI components एक Python environment में install नहीं होंगे।

```text
Django container
  Python 3.12
  No CUDA dependencies

Realtime Agent / STT container
  LiveKit Agents
  faster-whisper
  Tested CTranslate2 + CUDA + cuDNN combination

vLLM container
  Separate official/reproducible Linux GPU image
  Qwen3-8B checkpoint

TTS container or isolated agent dependency
  Kokoro-82M exact revision

MuseTalk avatar container
  Python 3.10
  MuseTalk-tested PyTorch/CUDA environment
```

Host NVIDIA driver सभी selected container CUDA runtimes के लिए compatible होना चाहिए। `GPU_COMPATIBILITY_MATRIX.md` coding के दौरान generated implementation artifact होगा, लेकिन इस stack decision को replace नहीं करेगा।

---

## 8. Speech-to-text

```text
faster-whisper
```

Selection exact model benchmark पर निर्भर होगी:

- Indian English accuracy.
- Quiet and moderate-noise WER.
- Silence hallucination.
- First partial latency.
- End-of-turn final latency.
- VRAM and real-time factor.
- FP16/INT8 behavior.

Model revision, hash, CTranslate2, CUDA और cuDNN versions lock होंगे।

---

## 9. LLM

```text
Qwen3-8B
vLLM OpenAI-compatible serving interface
```

### Why

- Open-weight model family.
- Multilingual capability useful for English + Hindi explanations.
- vLLM streaming और provider abstraction देता है।
- Model backend बदलने पर agent logic rewrite नहीं होना चाहिए।

### Mandatory gates

- Exact checkpoint/revision/hash.
- License snapshot.
- BF16/quantized benchmark.
- First-token latency.
- Max context and concurrency.
- Structured-output validation.
- Prompt-injection and unsafe-content tests.
- 100+ scripted English-teacher evaluation turns.

---

## 10. Text-to-speech

```text
Kokoro-82M
```

Kokoro MVP English voice candidate है। बहुत short replies के लिए अलग benchmark mandatory है:

- 1–5 tokens.
- 6–10 tokens.
- 11–20 tokens.
- Questions.
- Corrections.
- Numbers and abbreviations.
- Indian names and places.

Fail होने पर controlled text grouping, punctuation/pause normalization, cached fixed phrases या ADR-reviewed alternative TTS use होगा। Poor voice quality छिपाने के लिए irrelevant long responses नहीं बनेंगे। Voice cloning MVP में नहीं है।

---

## 11. Avatar system

### Approved MVP design

```text
IDLE      -> consented pre-recorded loop
LISTENING -> consented pre-recorded loop
THINKING  -> consented pre-recorded loop
SPEAKING  -> MuseTalk-generated lip-synced frames
ENDING    -> consented pre-recorded loop
```

### MuseTalk status

- Code MIT.
- Main trained model commercial use permitted by upstream statement.
- Other downloaded models have separate licenses.
- Repository internet test data non-commercial and prohibited.
- Hardware-specific upstream FPS claim हमारे product claim का आधार नहीं होगा।

Commercial beta से पहले हर transitive component audit और hash होगा, including:

- Whisper feature model.
- VAE.
- DWPose.
- SyncNet.
- Face detection/parsing.
- Restoration/upscaling.
- FFmpeg build.

Unclear/non-commercial license component release को block करेगा।

### LivePortrait

Production baseline से excluded है क्योंकि bundled InsightFace detection models non-commercial research restriction रखते हैं। Replacement detector, complete removal, quality benchmark और new ADR के बाद ही reconsider होगा।

---

## 12. Background jobs

```text
Celery 5.6
Currently community-supported RabbitMQ release
```

Uses:

- Session report generation.
- Email/notification jobs.
- Progress aggregation.
- Cleanup and retention jobs.
- Avatar preprocessing.
- Data export/deletion workflows.

Not allowed:

- Realtime audio chunks.
- Video frames.
- Large model payloads.
- Turn-critical inference.

RabbitMQ exact series implementation और हर release से पहले reselected होगी क्योंकि community support windows short हैं। Current patch, compatible Erlang/OTP और Docker digest pin होंगे।

---

## 13. Object storage

Architecture एक S3-compatible abstraction use करेगी। Exact product अभी permanently lock नहीं है।

```text
Local development: local/disposable volume
Beta candidate: SeaweedFS after tests
Production: implementation passing security, durability, restore and cost review
```

Mandatory tests:

- Private by default.
- Short-lived signed access.
- Encryption policy.
- Checksums.
- Backup/replication.
- Clean staging restore.
- Reliable deletion.
- Actor assets and user assets separated.
- No public recording/model bucket.

---

## 14. Deployment and operations

```text
Ubuntu Linux
Docker Engine + Docker Compose
NVIDIA Driver + NVIDIA Container Toolkit
Reverse proxy/TLS
Separate dev, staging and production
```

Kubernetes initial baseline में नहीं है। It may be introduced only when measured operations/load show VM/Compose is the bottleneck.

Production artifacts:

- Immutable release tag.
- Docker image digests.
- Python and Flutter lockfiles.
- Model revisions and SHA-256.
- SBOM.
- Third-party notices.
- Migration/rollback instructions.
- Backup/restore evidence.

---

## 15. Testing stack and gates

- Flutter unit, controller, widget and physical-device integration tests.
- Django unit, PostgreSQL integration, permission and API contract tests.
- Migration tests from clean and previous release database.
- LiveKit join, reconnect, TURN, webhook and network-impairment tests.
- STT WER/latency benchmark.
- LLM prompt/schema/safety regression suite.
- TTS latency/quality/cancellation suite.
- Avatar FPS, A/V sync, identity stability and memory tests.
- End-to-end scripted sessions and human pilots.
- Load, worker-crash, rollback, backup and restore tests.

---

## 16. Security, privacy and legal baseline

- No raw audio/video recording by default.
- Explicit consent for optional recording or training use.
- Written commercial avatar/voice rights.
- Visible `AI Teacher` disclosure.
- Account/data deletion flow.
- Data-retention matrix.
- India DPDP compliance mapping before closed beta.
- Age and child-user policy before accepting minors.
- Breach-response plan.
- Least-privilege service accounts.
- Exact CORS/hosts allowlists.
- Rate limits and GPU-abuse controls.
- Secret scanning, dependency scanning and SBOM.

This is engineering/license planning, not a replacement for final legal advice.

---

## 17. Explicitly excluded from initial production

- Tavus/HeyGen as hidden core dependencies.
- ASP.NET Core and SQL Server.
- Duplicate FastAPI business backend.
- Django Channels for video media.
- LivePortrait/InsightFace weights.
- Voice cloning.
- Multiple avatars.
- Full-body avatar.
- Emotion or mental-state diagnosis.
- Official IELTS/TOEFL scoring claims.
- Kubernetes before measured need.
- Unlimited video usage.
- Unpinned `latest` production images.

---

## 18. Free software versus cost

Core software may be self-hosted without Tavus/OpenAI-style per-minute software fees. Project operation is not free. Paid costs include:

- NVIDIA GPU rental/hardware.
- Backend and LiveKit servers.
- TURN/video bandwidth.
- Object storage and backups.
- Domain and operational services.
- Play Store account.
- Monitoring, maintenance and support.

---

## 19. Official verification references

- Django 5.2 LTS: https://docs.djangoproject.com/en/5.2/releases/5.2/
- PostgreSQL version policy: https://www.postgresql.org/support/versioning/
- LiveKit self-hosting: https://docs.livekit.io/transport/self-hosting/
- LiveKit production deployment: https://docs.livekit.io/transport/self-hosting/deployment/
- RabbitMQ support lifecycle: https://www.rabbitmq.com/release-information
- MuseTalk license/disclaimer: https://github.com/TMElyralab/MuseTalk
- LivePortrait license: https://github.com/KlingAIResearch/LivePortrait/blob/main/LICENSE
- India DPDP Rules page: https://www.meity.gov.in/documents/act-and-policies/digital-personal-data-protection-rules-2025-gDOxUjMtQWa

---

## 20. Version-lock rule

Architecture families इस document में locked हैं। Exact patch/package/model versions तभी pin होंगी जब संबंधित roadmap phase का compatibility test और benchmark pass हो। हर selected dependency/model के लिए record करें:

- Name and purpose.
- Exact version/revision.
- Official source.
- License.
- Release/support date.
- Package hash/container digest/model SHA-256.
- Tested OS, driver, CUDA and GPU.
- Benchmark result.
- Known limitations.
- Upgrade deadline.

Production में `latest`, floating model revision या undocumented download prohibited है.
