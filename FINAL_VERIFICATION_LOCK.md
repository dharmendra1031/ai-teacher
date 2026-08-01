# AI Teacher — Final Verification Lock

**Status:** LOCKED AMENDMENT  
**Verification date:** 2026-08-01  
**Repository:** `dharmendra1031/ai-teacher`  
**Applies to:** `ARCHITECTURE_LOCK.md` and `DEVELOPMENT_ROADMAP_LOCK.md`

> This document is the final verification amendment. Where a statement here conflicts with an older architecture or roadmap statement, **this document takes precedence**. It does not remove phase gates; it makes them stricter.

## 1. Final conclusion

The architecture remains viable for a self-hosted realtime AI English teacher, but it is approved only with the compatibility, licensing, privacy, GPU and operations gates below.

The final architecture family remains:

```text
Flutter + GetX + feature-first Clean Architecture
Django 5.2 LTS + Django REST Framework
JWT authentication after compatibility matrix validation
PostgreSQL 17 current minor
Self-hosted LiveKit + LiveKit Agents
faster-whisper
Qwen3-8B served by vLLM
Kokoro-82M
MuseTalk 1.5 after full transitive-model audit
Celery 5.6 + a currently community-supported RabbitMQ release
S3-compatible object-storage abstraction
Ubuntu Linux + Docker Compose + NVIDIA GPU workers
```

No document can guarantee that an upstream dependency, law, model license or security status will never change. Production releases therefore remain subject to the re-verification gates in this file.

---

## 2. Verification passes performed

The project was rechecked across these independent areas:

1. Architecture order and service boundaries.
2. Django, DRF and JWT package compatibility.
3. PostgreSQL support lifecycle.
4. LiveKit deployment, TURN, TLS and coordination requirements.
5. Flutter/GetX and LiveKit Flutter-client status.
6. Celery/RabbitMQ support lifecycle.
7. STT, LLM, TTS and avatar runtime compatibility.
8. AI-model and transitive-checkpoint commercial licensing.
9. Windows-development versus Linux-production constraints.
10. Security, privacy, consent and India-specific legal readiness.
11. Object-storage durability and backup assumptions.
12. Testing, load, rollback and disaster-recovery gates.

---

# 3. Mandatory corrections and overrides

## 3.1 Delivery-order correction

An older architecture section placed the Django product backend after the realtime avatar gate. The detailed development roadmap correctly places the control backend earlier.

The authoritative delivery order is:

```text
1. Governance, scope and consent
2. Flutter ↔ LiveKit ↔ Python participant feasibility spike
3. Monorepo, environments, dependency locks and CI
4. Django backend foundation
5. Flutter application foundation
6. Secure session creation, LiveKit token and agent dispatch
7. Realtime AI-agent lifecycle
8. STT
9. LLM
10. TTS
11. Complete voice AI
12. Offline MuseTalk avatar
13. Realtime avatar streaming
14. Learning intelligence and reports
15. Product features and usage limits
16. Security, privacy and commercial hardening
17. Observability and cost controls
18. Load, rollback, backup and recovery
19. Closed beta
20. Production launch
```

Voice AI must pass before avatar work. Offline avatar must pass before realtime avatar work.

---

## 3.2 Django / DRF / JWT compatibility gate

### Verified facts

- Django 5.2 is an LTS release.
- Django 5.2 supports Python 3.10–3.14 in current patches; the backend remains locked to Python 3.12 for project consistency.
- Django REST Framework 3.17.1 is a current stable release and supports modern Django/Python versions.
- SimpleJWT 5.5.1 is production/stable and its PyPI classifiers include Django 5.2.
- SimpleJWT's stable documentation still lists an older official requirements matrix, including DRF 3.14/3.15 and Django up to 5.1. Documentation and package metadata are therefore not fully aligned.

### Locked rule

Do not assume the following combination is valid merely because installation succeeds:

```text
Django 5.2.x
Django REST Framework 3.17.x
SimpleJWT 5.5.x
Python 3.12.x
```

Before backend Phase 3 is approved, CI must run an authentication compatibility matrix with at least:

```text
Matrix A:
Django latest 5.2 patch
DRF 3.17.1
SimpleJWT 5.5.1
Python 3.12 latest patch

Matrix B fallback:
Django latest 5.2 patch
DRF 3.16.1
SimpleJWT 5.5.1
Python 3.12 latest patch
```

Tests must cover:

- Token obtain.
- Token validation.
- Refresh.
- Refresh rotation.
- Blacklisting.
- Logout/revocation.
- Password-change invalidation policy.
- Custom user model.
- Concurrent refresh requests.
- Expired and malformed tokens.
- Database migrations for blacklist tables.
- DRF authentication and permission behavior.

Only a passing matrix may be pinned. If neither matrix passes, changing the JWT implementation requires an ADR and security review. Do not create an improvised JWT implementation during feature development.

Official references:

- https://docs.djangoproject.com/en/5.2/releases/5.2/
- https://www.django-rest-framework.org/community/release-notes/
- https://django-rest-framework-simplejwt.readthedocs.io/en/stable/getting_started.html
- https://pypi.org/project/djangorestframework-simplejwt/

---

## 3.3 RabbitMQ version-policy correction

`RabbitMQ 4.x` must not be treated as one long-supported fixed release family.

RabbitMQ community-support windows are short. As of 2026-08-01, RabbitMQ 4.3 is the current community-supported series, and its published community-support end date is 2026-11-30. That date is earlier than the expected commercial launch date of this project.

### Locked rule

The architecture choice is **RabbitMQ**, not a permanently pinned `4.x` minor series.

At the start of the background-jobs phase and again before every production release:

1. Select a RabbitMQ series still covered by community support.
2. Select the current patch release in that series.
3. Pin the Docker image by digest.
4. Pin a compatible Erlang/OTP version according to RabbitMQ's official matrix.
5. Run Celery publish/consume/retry/acknowledgement/dead-letter tests.
6. Record the support-end date in `DEPENDENCY_MANIFEST.md`.
7. Schedule upgrade work before that community-support date.

Celery 5.6 currently lists RabbitMQ as a stable broker. RabbitMQ remains suitable, but its release lifecycle must be actively managed.

Official references:

- https://docs.celeryq.dev/en/latest/getting-started/backends-and-brokers/
- https://www.rabbitmq.com/release-information
- https://www.rabbitmq.com/docs/which-erlang

---

## 3.4 LiveKit production-deployment gate

### Verified facts

A secure self-hosted LiveKit production deployment requires more than starting a Docker container. Official deployment guidance requires attention to:

- A trusted domain and SSL certificate.
- Secure WebSocket endpoint.
- Public-IP advertisement.
- UDP/TCP media ports.
- TURN for restricted networks.
- A separate TURN domain/certificate when TURN/TLS is enabled.
- Host networking for optimal Docker performance.
- Sufficient CPU and network bandwidth.

LiveKit's production example recommends Redis. Multi-node LiveKit requires a coordination store and cannot be introduced casually.

### Locked rule

The first beta may use single-node LiveKit without an external coordination store only if all of the following pass:

1. Room lifecycle after process restart is understood and accepted.
2. Active-session failure behavior is tested.
3. Capacity is within one node's benchmarked CPU and bandwidth limit.
4. TURN/TLS tests pass on mobile data, restricted Wi-Fi and corporate-style firewalls.
5. The operational risk is documented in an ADR.

Before multi-node deployment:

1. Confirm LiveKit's currently supported coordination-store requirement.
2. Review license and operational implications.
3. Validate protocol compatibility in staging.
4. Run rolling-restart and node-loss tests.
5. Do not substitute an unverified Redis-compatible server directly in production.

Official references:

- https://docs.livekit.io/transport/self-hosting/deployment/
- https://github.com/livekit/livekit
- https://github.com/livekit/livekit/blob/master/config-sample.yaml

---

## 3.5 GPU, CUDA and operating-system compatibility gate

### Verified runtime differences

The selected AI components do not share one guaranteed CUDA/PyTorch environment:

- Current faster-whisper/CTranslate2 GPU guidance uses CUDA 12 libraries and cuDNN 9.
- MuseTalk's official environment recommends Python 3.10 and an older tested PyTorch/CUDA combination around CUDA 11.7/11.8.
- vLLM recommends a fresh environment, has binary compatibility constraints with PyTorch/CUDA builds, and is natively supported on Linux rather than Windows.

### Locked deployment structure

```text
Django container:
Python 3.12, no CUDA packages

Realtime-agent/STT container:
Pinned faster-whisper + CTranslate2 + tested CUDA/cuDNN runtime

vLLM container:
Official/reproducible vLLM image, separate process and environment

MuseTalk container:
Python 3.10 + official tested PyTorch/CUDA dependency set

Host:
Ubuntu Linux + NVIDIA driver new enough for every selected container runtime
```

### Mandatory `GPU_COMPATIBILITY_MATRIX.md`

Before STT, vLLM or avatar phases are marked complete, record:

- GPU model and VRAM.
- Host OS/kernel.
- NVIDIA driver.
- Container CUDA runtime.
- cuDNN version.
- PyTorch version.
- CTranslate2 version.
- vLLM image digest/version.
- MuseTalk commit and model revision.
- Startup test result.
- 20-minute soak result.
- Peak VRAM.
- OOM behavior.

The user's Windows laptop may run Flutter, Django and basic local services. Production AI inference and official vLLM deployment must use Linux/remote GPU infrastructure. WSL2 may be used only as a development convenience after explicit testing, not as the production baseline.

Official references:

- https://github.com/SYSTRAN/faster-whisper
- https://docs.vllm.ai/en/latest/getting_started/installation/gpu/
- https://github.com/TMElyralab/MuseTalk

---

## 3.6 Kokoro short-utterance quality gate

Kokoro's model card is Apache-2.0 and suitable for commercial deployment, but its voice guidance notes that very short utterances can perform worse. An English teacher often generates short replies, corrections and questions, so this is a product risk.

### Mandatory benchmark

Test at least these groups:

- 1–5 tokens.
- 6–10 tokens.
- 11–20 tokens.
- 21–50 tokens.
- Numbers, abbreviations and punctuation.
- Indian names and locations.
- Corrected sentences.
- Questions and encouragement phrases.

Measure:

- First playable audio latency.
- Clipping.
- Mispronunciation.
- Unnatural rushing.
- Silence or empty output.
- Consistency across the selected voice.

If short outputs fail quality targets, approved mitigations include controlled text grouping, punctuation/pause normalization, cached fixed phrases, or an ADR-reviewed TTS alternative. Do not hide poor audio by sending longer irrelevant responses.

Official references:

- https://huggingface.co/hexgrad/Kokoro-82M
- https://huggingface.co/hexgrad/Kokoro-82M/blob/main/VOICES.md
- https://github.com/hexgrad/kokoro

---

## 3.7 MuseTalk release gate remains conditional

MuseTalk remains the selected avatar candidate, not an unconditional commercial approval of its entire downloaded runtime bundle.

Verified project statements:

- MuseTalk code is MIT.
- Its trained model is allowed for commercial use.
- Other downloaded models must follow their own licenses.
- Internet-collected repository test data is non-commercial research data.
- The official realtime performance claim is hardware-specific.
- Known limitations include 256×256 face-region processing, identity-detail loss and jitter.

### Locked rule

Before commercial beta, audit and hash every downloaded component, including any:

- Whisper feature model.
- VAE.
- DWPose.
- SyncNet.
- Face detector.
- Face parser.
- Restoration/upscaling model.
- FFmpeg build.

A missing or unclear license blocks that exact component. Repository test media is prohibited. Realtime product claims are based only on our target-GPU benchmark, not upstream V100 claims.

Official reference:

- https://github.com/TMElyralab/MuseTalk

---

## 3.8 LivePortrait remains excluded

LivePortrait code is MIT, but its official license states that bundled InsightFace models are non-commercial research assets. Therefore LivePortrait remains excluded from the production baseline.

It can be reconsidered only when:

1. InsightFace detection models are completely removed.
2. Every replacement detector/weight has commercial permission.
3. Quality and performance are revalidated.
4. A new ADR and model manifest are approved.

Official reference:

- https://github.com/KlingAIResearch/LivePortrait/blob/main/LICENSE

---

## 3.9 Object-storage correction

SeaweedFS is Apache-2.0 and remains an acceptable candidate, but production durability must not depend on its name alone.

The locked architecture requirement is an **S3-compatible storage abstraction**.

```text
Development:
Local filesystem or disposable development storage

Beta candidate:
SeaweedFS only after access-control, replication, backup and restore tests

Production:
Whichever S3-compatible implementation passes durability, security, cost and operations review
```

Mandatory tests:

- Private-by-default buckets.
- Signed/short-lived access URLs where needed.
- Server-side encryption policy.
- Checksums.
- Replication or backup.
- Restore into clean staging.
- Deletion behavior.
- Actor assets separated from user assets.
- No public model/recording bucket.

Official reference:

- https://github.com/seaweedfs/seaweedfs

---

## 3.10 India privacy and child-user compliance gate

The project is expected to launch first for Indian users. India's Digital Personal Data Protection Rules, 2025 were published on 2025-11-14, alongside an enforcement timeline and establishment of the Data Protection Board of India.

General privacy wording is not sufficient. Before closed beta, create `docs/privacy/INDIA_DPDP_COMPLIANCE_MATRIX.md` mapping the actual product and data flows against applicable law and rules.

The matrix must cover at least:

- Data-fiduciary identity and contact/grievance channel.
- Clear notice and purpose.
- Consent capture and withdrawal.
- User/data-principal access, correction, erasure and grievance flows.
- Security safeguards.
- Personal-data breach response and notification procedure.
- Processor/vendor contracts.
- Cross-border/cloud-hosting review.
- Retention and deletion.
- Backup deletion limitations.
- Children's data and verifiable parent/guardian consent where applicable.
- Prohibition or controls on tracking/behavioural monitoring of children where applicable.
- Age-assurance decision and product age policy.
- Logs and evidence of consent versions.

Because an English-learning application can attract minors, the product must not postpone the age/child policy until launch. Legal review is mandatory before accepting minor users.

Official reference:

- https://www.meity.gov.in/documents/act-and-policies/digital-personal-data-protection-rules-2025-gDOxUjMtQWa

---

# 4. Additional phase-gate amendments

## Phase 0 additions

Create these documents before feature coding:

- `docs/privacy/INDIA_DPDP_COMPLIANCE_MATRIX.md`
- `docs/privacy/AGE_AND_CHILD_POLICY.md`
- `docs/privacy/BREACH_RESPONSE_PLAN.md`
- `docs/licenses/MODEL_LICENSE_CHECKLIST.md`
- `docs/operations/DEPENDENCY_SUPPORT_CALENDAR.md`

## Phase 2 additions

CI/reproducibility must include:

- Dependency lockfiles.
- Container image digests.
- SBOM generation.
- Secret scanning.
- License scanning.
- `pip check` and dependency-conflict checks.
- Auth compatibility matrix job.
- No GPU model downloads in ordinary CI.

## Phase 7 additions

The STT benchmark must record the selected CTranslate2/CUDA/cuDNN combination, not only the faster-whisper package version.

## Phase 9 additions

Add the Kokoro short-utterance test suite and selected voice revision/hash.

## Phase 11 additions

MuseTalk cannot pass its exit gate until the complete transitive checkpoint manifest is approved.

## Phase 15 additions

Add India DPDP and minor-user compliance review to the security/privacy exit gate.

## Phase 17 additions

Before launch, verify:

- RabbitMQ selected release is still community-supported.
- Django/PostgreSQL selected releases remain supported.
- LiveKit deployment uses trusted TLS and tested TURN.
- Coordination-store decision is documented.
- Full restore test succeeds.
- GPU driver supports every container runtime.

---

# 5. Final pre-development checklist

Development may start when all items below are understood; Phase 0 must complete them before product feature work proceeds.

- [ ] One consented avatar source strategy.
- [ ] Product age policy.
- [ ] India DPDP compliance matrix owner.
- [ ] Flutter/LiveKit feasibility spike plan.
- [ ] Linux remote GPU strategy.
- [ ] Separate runtime/container policy accepted.
- [ ] Django/DRF/SimpleJWT matrix test defined.
- [ ] Current dependency support calendar created.
- [ ] No production promise based on unbenchmarked MuseTalk performance.
- [ ] Audio-only fallback remains a first-class product mode.

---

# 6. Release re-verification checklist

Run this before every public release:

1. Check Django security patch and support status.
2. Check DRF and JWT compatibility/security status.
3. Check PostgreSQL current minor and support status.
4. Check RabbitMQ community-support date and Erlang compatibility.
5. Check LiveKit server/agent/client compatibility.
6. Check NVIDIA driver, CUDA and PyTorch matrix.
7. Re-run STT/LLM/TTS/avatar regression benchmarks.
8. Re-check model cards, licenses and hashes.
9. Regenerate SBOM and third-party notices.
10. Re-run privacy/legal review for changed data flows.
11. Test backup restore and application rollback.
12. Confirm feature flags and audio-only emergency fallback.

---

# 7. Final locked decision

The project is approved to proceed with the existing roadmap **after applying this amendment**.

The architecture is not changed at a high level. The following details are now explicitly conditional rather than assumed:

- SimpleJWT with DRF 3.17.
- A specific RabbitMQ 4.x series surviving until launch.
- One CUDA environment supporting every AI component.
- Kokoro quality on very short teacher phrases.
- SeaweedFS durability without testing.
- LiveKit production without TURN/TLS and coordination review.
- Commercial MuseTalk use without transitive-checkpoint audit.
- Launching to minors without India-specific compliance work.

**Execution principle remains:** prove transport first, complete stable voice AI second, validate an offline avatar third, add realtime avatar fourth, and scale only after measured production-like tests.
