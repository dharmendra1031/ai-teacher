# AI Teacher — Locked Architecture and License Baseline

**Status:** LOCKED  
**Lock date:** 2026-08-01  
**Repository:** `dharmendra1031/ai-teacher`  
**Purpose:** A self-hosted, real-time, realistic AI English teacher with Flutter mobile clients, live voice conversation, and a lip-synced digital human.

> This document is the project’s technical and third-party license baseline. No dependency, model, media asset, or architecture component may be added to the production build without the review process defined below.

## 1. Important limitation

This review greatly reduces technical and licensing risk, but it cannot guarantee that a future release, dependency, law, codec patent, model card, or upstream license will never change. The approval in this document applies only to the component families and conditions written here. Exact versions and model file hashes must be pinned before production deployment.

This is an engineering and open-source license review, not formal legal advice. A qualified lawyer should review the final commercial release, privacy policy, actor consent, and distribution model.

---

## 2. Final locked architecture

```text
Flutter Mobile App
  Flutter stable + GetX 4.x + feature-first Clean Architecture
             |
             | REST/HTTPS + JWT
             v
Django Control Backend
  Django 5.2 LTS + Django REST Framework + SimpleJWT
             |
             +------ PostgreSQL 17
             +------ Celery 5.6 + RabbitMQ 4.x
             +------ SeaweedFS S3-compatible storage (production beta)
             |
             | LiveKit room/token/agent dispatch
             v
Self-hosted LiveKit Server
             |
             +------ Flutter participant
             +------ Python realtime AI participant
                           |
                           +-- faster-whisper STT
                           +-- Qwen3-8B through vLLM
                           +-- Kokoro-82M TTS
                           +-- MuseTalk avatar worker
```

### Runtime separation

The following services must remain separate containers/environments:

1. **Django backend** — Python 3.12.
2. **Realtime AI agent** — Python environment compatible with LiveKit Agents, faster-whisper and Kokoro.
3. **Avatar GPU worker** — isolated Python/CUDA environment matching MuseTalk’s tested dependencies.
4. **vLLM model server** — official or reproducibly built vLLM container.
5. **LiveKit server** — independent media server.
6. **PostgreSQL, RabbitMQ and SeaweedFS** — independent infrastructure services.

Do not install Django, MuseTalk, vLLM and all CUDA packages into one Python environment. Isolating them prevents dependency and CUDA/PyTorch conflicts.

---

## 3. Approved production technology

| Area | Locked choice | License / status | Production decision |
|---|---|---|---|
| Mobile SDK | Flutter stable channel | BSD-3-Clause | Approved |
| State/navigation/DI | GetX stable 4.x; currently 4.7.3 | MIT | Approved; do not use GetX 5 release candidates |
| Mobile architecture | Feature-first Clean Architecture | Project convention | Approved |
| HTTP client | Dio | Verify pinned release during implementation | Conditional on dependency audit |
| Secret storage | `flutter_secure_storage` | Verify pinned release during implementation | Approved after lockfile audit |
| Realtime Flutter client | Official LiveKit Flutter SDK | Apache-2.0 | Approved |
| Backend language | Python 3.12 | PSF license | Approved |
| Backend framework | Django 5.2 LTS, current patch | BSD-3-Clause | Approved; LTS receives security updates for at least 3 years from release |
| REST API | Django REST Framework 3.17.x | BSD | Approved |
| JWT | SimpleJWT stable release | MIT | Approved |
| Database | PostgreSQL 17.x, current minor | PostgreSQL License | Approved; supported through 2029-11-08 |
| Realtime media | Self-hosted LiveKit Server | Apache-2.0 | Approved; software is free, hosting is not |
| Realtime agent | LiveKit Agents Python SDK | Apache-2.0 | Approved |
| Speech-to-text | faster-whisper + Whisper weights | MIT | Approved |
| LLM | Qwen3-8B | Apache-2.0 | Approved |
| LLM serving | vLLM | Apache-2.0 | Approved |
| English TTS | Kokoro-82M | Apache-licensed weights | Approved for MVP English voice |
| Lip synchronization | MuseTalk 1.5 | Code MIT; trained model allowed commercially | Conditionally approved; transitive model audit required |
| Background jobs | Celery 5.6 | New BSD | Approved |
| Task broker | RabbitMQ 4.x | MPL-2.0 | Approved; stable/default Celery broker |
| Object storage | Local volume in development; SeaweedFS later | SeaweedFS Apache-2.0 | Approved |
| Containers | Docker Engine + Compose on Ubuntu | Open-source engine components | Approved |
| Media processing | FFmpeg LGPL-only build | LGPL-2.1+ | Conditional; server-side only and compliance rules below |

### Official verification references

- Flutter license: https://github.com/flutter/flutter/blob/master/LICENSE
- GetX stable package and MIT license: https://pub.dev/packages/get/license
- Django 5.2 LTS release notes: https://docs.djangoproject.com/en/5.2/releases/5.2/
- Django REST Framework: https://github.com/encode/django-rest-framework
- SimpleJWT license: https://github.com/jazzband/djangorestframework-simplejwt/blob/master/LICENSE.txt
- PostgreSQL version policy: https://www.postgresql.org/support/versioning/
- PostgreSQL license: https://www.postgresql.org/about/licence/
- LiveKit server license: https://github.com/livekit/livekit
- LiveKit Agents license: https://github.com/livekit/agents
- LiveKit Flutter SDK license: https://github.com/livekit/client-sdk-flutter
- faster-whisper license: https://github.com/SYSTRAN/faster-whisper/blob/master/LICENSE
- Whisper code and weights license: https://github.com/openai/whisper/blob/main/LICENSE
- Qwen3-8B model card/license: https://huggingface.co/Qwen/Qwen3-8B
- vLLM license: https://github.com/vllm-project/vllm/blob/main/LICENSE
- Kokoro: https://github.com/hexgrad/kokoro
- MuseTalk license and commercial statement: https://github.com/TMElyralab/MuseTalk
- Celery broker status: https://docs.celeryq.dev/en/latest/getting-started/backends-and-brokers/
- RabbitMQ license: https://www.rabbitmq.com/
- SeaweedFS license: https://github.com/seaweedfs/seaweedfs
- FFmpeg legal guidance: https://ffmpeg.org/legal.html

---

## 4. Components deliberately excluded from the initial production build

### 4.1 LivePortrait is not production-approved yet

LivePortrait’s main code is MIT, but its official license file states that bundled InsightFace detection models are limited to non-commercial research. Therefore:

- LivePortrait may be used only for local research/prototyping.
- InsightFace detection weights must never be shipped or deployed in the commercial service.
- Production approval requires replacing the detection pipeline with a commercially permitted detector, validating output quality, and recording the exact model license and hash.
- MediaPipe is an Apache-2.0 candidate, but integration compatibility with LivePortrait must be proven before approval.

For the MVP, use **consented, pre-recorded idle/listening/thinking loops** and MuseTalk only while speaking. This is technically simpler and removes the immediate InsightFace risk.

Reference: https://github.com/KlingAIResearch/LivePortrait/blob/main/LICENSE

### 4.2 Valkey/Redis is not required in the MVP

Valkey itself is permissively licensed, but Celery’s current stable documentation lists RabbitMQ and Redis transports, while direct native Valkey transport work has not been established here as the locked stable path. To avoid protocol/client compatibility surprises:

- Use RabbitMQ as the Celery broker.
- Celery tasks should update PostgreSQL and normally use `task_ignore_result=True`.
- Do not send audio, video frames or large model payloads through Celery/RabbitMQ.
- Add Valkey later only through a separate ADR and compatibility test if caching becomes necessary.

### 4.3 No separate FastAPI business backend

Django is the business/control backend. The realtime agent and model servers are Python worker processes, not duplicate public business APIs. This avoids duplicated authentication, schemas, validation, migrations and deployment logic.

### 4.4 No ASP.NET Core or SQL Server

They are not technically bad, but mixing C#, Python AI services and Flutter increases learning and maintenance cost without providing a necessary advantage for this product. The locked backend is Django + PostgreSQL.

### 4.5 No external avatar API dependency

Tavus, HeyGen and similar services are not part of the locked core. They may be used only as temporary benchmark tools, never as an undocumented production dependency.

---

## 5. MuseTalk commercial-release conditions

MuseTalk’s project states that its code is MIT and its trained model can be used commercially. It also explicitly warns that other models and test data have their own terms.

Before any commercial release, all of the following are mandatory:

1. Use only a teacher image/video/voice for which written commercial consent exists.
2. Do not use MuseTalk repository sample/test media in the product.
3. Create `MODEL_MANIFEST.json` recording every downloaded checkpoint:
   - component name,
   - source URL,
   - exact revision/commit,
   - SHA-256 hash,
   - license,
   - commercial-use decision,
   - audit date.
4. Audit every transitive checkpoint used by the selected MuseTalk pipeline, including face detection, pose, VAE, audio and restoration components.
5. A checkpoint with unclear, research-only, non-commercial or missing terms is blocked.
6. Store model files outside the Git repository.

MuseTalk is therefore **architecture-approved but release-gated** until its exact runtime model bundle passes this manifest audit.

---

## 6. FFmpeg and codec policy

FFmpeg is mainly LGPL-2.1+, but optional flags and external libraries can make a build GPL or non-redistributable.

Locked rules:

- FFmpeg runs on Linux servers only; do not bundle a custom FFmpeg binary inside the Flutter application.
- Use a reproducible LGPL-compatible build.
- Never use `--enable-gpl` or `--enable-nonfree` in the approved build.
- Do not silently add GPL libraries such as `libx264` or `libx265`.
- Keep the FFmpeg configure command, binary version, source reference and license notices.
- Prefer WebRTC-native VP8/Opus for the first release where technically possible.
- Any H.264/HEVC distribution decision needs a separate codec/patent review for target countries and app stores.

---

## 7. Free software versus actual operating cost

The approved open-source components do not require Tavus/OpenAI-style per-minute software license fees when self-hosted. They do not make the whole service free.

The following remain paid operational costs:

- NVIDIA GPU rental or owned GPU hardware,
- CPU backend and LiveKit server,
- internet bandwidth and TURN relay traffic,
- object storage and backups,
- domain, TLS/operations and monitoring,
- Play Store / App Store accounts,
- power, maintenance and support.

A local non-realtime prototype can be developed with no software license fee. A realistic realtime avatar needs a suitable NVIDIA GPU and will have infrastructure cost.

---

## 8. Security and privacy baseline

The following are mandatory from the beginning:

- Tavus/model/provider keys never go into Flutter.
- JWT access token: short lifetime; refresh token rotation and revocation enabled.
- Refresh token stored using platform secure storage, not plain GetStorage/SharedPreferences.
- TLS for every public endpoint and secure WebSocket connection.
- Raw user camera/video is not recorded by default.
- Explicit opt-in before any recording or training-data use.
- Account deletion and recording deletion flows.
- Signed commercial consent for avatar face and voice.
- Visible `AI Teacher` disclosure during a call.
- No face/voice cloning of public figures or any person without explicit rights.
- Secrets stay in environment/secret-manager storage and never enter Git.
- Dependency vulnerability scanning and secret scanning in CI.

---

## 9. Repository structure

```text
ai-teacher/
├── mobile_app/                 # Flutter + GetX
├── backend/                    # Django control plane
├── realtime_agent/             # LiveKit Agents, STT, LLM/TTS orchestration
├── avatar_worker/              # Isolated MuseTalk/CUDA runtime
├── infrastructure/
│   ├── livekit/
│   ├── postgres/
│   ├── rabbitmq/
│   ├── seaweedfs/
│   └── docker/
├── docs/
│   ├── adr/
│   ├── licenses/
│   ├── consent/
│   └── security/
├── MODEL_MANIFEST.json         # Added when checkpoints are selected
├── THIRD_PARTY_NOTICES.md      # Generated/maintained before release
└── ARCHITECTURE_LOCK.md
```

---

## 10. Delivery roadmap and technical gates

### Gate 0 — Realtime feasibility spike

- Flutter joins a self-hosted LiveKit room.
- Python agent joins as another participant.
- User audio reaches the agent.
- Agent publishes dummy audio and video back to Flutter.

No full product backend is required before this gate succeeds.

### Gate 1 — Voice AI teacher

- faster-whisper transcription,
- Qwen3-8B streamed through vLLM,
- Kokoro speech,
- interruption/barge-in,
- conversation transcript,
- acceptable end-of-turn latency.

### Gate 2 — Offline avatar

- consented reference media,
- Kokoro audio to MuseTalk,
- stable lip-synced MP4,
- no sample/test assets,
- initial model manifest.

### Gate 3 — Realtime avatar

- streaming TTS chunks,
- bounded frame/audio buffers,
- cancellation on user interruption,
- audio/video timestamp synchronization,
- LiveKit video publication,
- measurable FPS, latency, VRAM and concurrency.

### Gate 4 — Django product backend

- account and JWT flows,
- teacher/topic/session models,
- LiveKit token and agent dispatch,
- webhooks,
- usage limits,
- reports and Django Admin.

### Gate 5 — Commercial beta readiness

- complete dependency SBOM,
- complete model manifest,
- third-party notices,
- consent documents,
- data retention/deletion tests,
- security scan,
- load test,
- backup/restore test,
- formal final legal review.

---

## 11. Version and dependency policy

- Commit lockfiles: `pubspec.lock`, Python lockfiles, Docker image digests and model hashes.
- Use stable releases only; no release candidates in production.
- Apply security patch upgrades within the locked major/minor family after automated tests.
- A major framework/model change requires an Architecture Decision Record (ADR).
- Every AI model upgrade requires a new model-card/license review, quality benchmark and hash update.
- Every container base image must be pinned by digest for release builds.
- Generate an SBOM in CI before every release.
- Never rely only on a repository’s top-level license; inspect bundled weights, sample assets and transitive model downloads.

---

## 12. Architecture change-control rule

This document is locked. A change is allowed only when a pull request contains:

1. `docs/adr/ADR-XXXX-<decision>.md`,
2. reason for the change,
3. alternatives considered,
4. migration/rollback plan,
5. performance impact,
6. security/privacy impact,
7. license and commercial-use verification,
8. updated dependency/model manifest where applicable.

No developer may silently replace the database, backend, realtime layer, LLM, TTS, avatar model, broker or storage service.

---

## 13. Final decision

The production baseline is locked to:

```text
Flutter + GetX 4.x + feature-first Clean Architecture
Django 5.2 LTS + Django REST Framework + SimpleJWT
PostgreSQL 17
Self-hosted LiveKit + LiveKit Agents
faster-whisper
Qwen3-8B + vLLM
Kokoro-82M
MuseTalk 1.5, subject to exact transitive model audit
Celery 5.6 + RabbitMQ 4.x
Local storage in development; SeaweedFS in production beta
Ubuntu + Docker Engine/Compose + NVIDIA GPU
```

**LivePortrait, InsightFace weights, Valkey, multiple avatars, voice cloning, full-body generation and Kubernetes are not part of the initial production baseline.** They require a separate ADR and audit.
