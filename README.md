# AI Teacher

Self-hosted realtime AI English teacher with a realistic speaking avatar.

## Locked stack

- Flutter + GetX + feature-first Clean Architecture
- Django 5.2 LTS + Django REST Framework + SimpleJWT
- PostgreSQL 17
- Self-hosted LiveKit + LiveKit Agents
- faster-whisper
- Qwen3-8B served by vLLM
- Kokoro-82M
- MuseTalk 1.5 with a mandatory transitive-model license audit
- Celery + RabbitMQ
- SeaweedFS for later S3-compatible object storage
- Docker Compose on Ubuntu with NVIDIA GPU workers

The verified technical, licensing, security and change-control baseline is locked in [ARCHITECTURE_LOCK.md](ARCHITECTURE_LOCK.md).

> Do not add or replace a core technology or AI model without an ADR, license review and benchmark.
