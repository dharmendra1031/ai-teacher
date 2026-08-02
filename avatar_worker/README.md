# Avatar worker boundary

MuseTalk work begins only after the voice AI gate passes. This service is intentionally not part of the non-GPU Compose profile.

- Runtime target: Python 3.10 on Ubuntu 24.04 LTS
- GPU baseline: NVIDIA driver compatible with the benchmark-selected CUDA image
- Image policy: immutable tag and digest required before staging
- Model policy: exact checkpoint hashes and license manifest required before download

`requirements.lock` remains empty until the Phase 11 benchmark selects a compatible CUDA/PyTorch/MuseTalk matrix. CI must not download model weights.

