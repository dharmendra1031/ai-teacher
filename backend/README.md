# Backend placeholder

Phase 2 provides a dependency-free Python 3.12 health service so the local stack and Docker build can be verified before the Phase 3 Django foundation is introduced.

Run locally:

```powershell
py -3.12 -m unittest discover -s tests -v
py -3.12 -m backend.health_server
```

`requirements.lock` is intentionally empty in Phase 2. Phase 3 will generate the hashed Django production lock from `requirements.in`.

