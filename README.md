# AI Teacher

Self-hosted realtime AI English teacher with a realistic speaking avatar.

## Locked stack

- Flutter + GetX + feature-first Clean Architecture
- Django 5.2 LTS + Django REST Framework
- JWT authentication after compatibility-matrix validation
- PostgreSQL 17
- Self-hosted LiveKit + LiveKit Agents
- faster-whisper
- Qwen3-8B served by vLLM
- Kokoro-82M
- MuseTalk 1.5 with a mandatory transitive-model license audit
- Celery + a currently supported RabbitMQ release
- S3-compatible object-storage abstraction
- Docker Compose on Ubuntu with isolated NVIDIA GPU workers

## Locked project documents

- [Architecture and license baseline](ARCHITECTURE_LOCK.md)
- [Complete phase-by-phase development roadmap](DEVELOPMENT_ROADMAP_LOCK.md)
- [Final verification lock and mandatory amendments](FINAL_VERIFICATION_LOCK.md)

`FINAL_VERIFICATION_LOCK.md` takes precedence wherever an older statement conflicts with the final audit.

> Do not add or replace a core technology or AI model without an ADR, license review, compatibility test, benchmark, security/privacy review and roadmap-gate update.
