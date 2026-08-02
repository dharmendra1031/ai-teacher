"""Dependency-free Phase 2 health server, replaced by Django in Phase 3."""

from __future__ import annotations

import json
import os
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Final

HOST: Final = "0.0.0.0"


class HealthHandler(BaseHTTPRequestHandler):
    """Serve liveness and readiness endpoints without logging request data."""

    def do_GET(self) -> None:  # noqa: N802
        if self.path not in {"/health/live", "/health/ready"}:
            self.send_error(HTTPStatus.NOT_FOUND)
            return

        payload = json.dumps({"status": "ok", "service": "backend-placeholder"}).encode()
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args: object) -> None:
        return


def main() -> None:
    port = int(os.environ.get("PORT", "8000"))
    ThreadingHTTPServer((HOST, port), HealthHandler).serve_forever()


if __name__ == "__main__":
    main()

