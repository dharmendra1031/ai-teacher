# Local non-GPU infrastructure

Requirements: Docker Engine 27+ with Compose v2.29+; production target is Ubuntu 24.04 LTS. GPU services are deliberately excluded.

From the repository root:

```powershell
Copy-Item .env.example .env
.\scripts\dev.ps1 up
.\scripts\dev.ps1 check
.\scripts\dev.ps1 down
```

Reset removes the named local PostgreSQL and RabbitMQ volumes and is destructive to local-only data:

```powershell
.\scripts\dev.ps1 reset
```

Change every example password before startup. The local environment must never point to staging or production resources.

