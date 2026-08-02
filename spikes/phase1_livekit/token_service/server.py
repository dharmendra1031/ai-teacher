from __future__ import annotations

import json
import logging
import os
import re
from datetime import timedelta
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

from dotenv import load_dotenv
from livekit import api

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
LOGGER = logging.getLogger("phase1.token_service")

API_KEY = os.environ.get("LIVEKIT_API_KEY", "").strip()
API_SECRET = os.environ.get("LIVEKIT_API_SECRET", "").strip()
PUBLIC_URL = os.environ.get("LIVEKIT_PUBLIC_URL", "").strip()
HOST = os.environ.get("TOKEN_SERVICE_HOST", "0.0.0.0").strip()
PORT = int(os.environ.get("TOKEN_SERVICE_PORT", "8090"))
DEFAULT_ROOM = os.environ.get("ROOM_NAME", "phase1-room").strip()

ALLOWED_IDENTITY_PATTERN = re.compile(r"^(flutter-|phase1-check-)[A-Za-z0-9._-]+$")
MAX_IDENTITY_LENGTH = 64
MAX_DISPLAY_NAME_LENGTH = 80


def validate_environment() -> None:
    missing = [
        name
        for name, value in {
            "LIVEKIT_API_KEY": API_KEY,
            "LIVEKIT_API_SECRET": API_SECRET,
            "LIVEKIT_PUBLIC_URL": PUBLIC_URL,
            "ROOM_NAME": DEFAULT_ROOM,
        }.items()
        if not value
    ]
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

    parsed_url = urlparse(PUBLIC_URL)
    if parsed_url.scheme not in {"ws", "wss"} or not parsed_url.hostname:
        raise RuntimeError("LIVEKIT_PUBLIC_URL must be a valid ws:// or wss:// URL")
    if not 1 <= PORT <= 65535:
        raise RuntimeError("TOKEN_SERVICE_PORT must be between 1 and 65535")


def create_token(room_name: str, identity: str, display_name: str) -> str:
    return (
        api.AccessToken(API_KEY, API_SECRET)
        .with_identity(identity)
        .with_name(display_name)
        .with_grants(
            api.VideoGrants(
                room_join=True,
                room=room_name,
                can_publish=True,
                can_subscribe=True,
            )
        )
        .with_ttl(timedelta(minutes=30))
        .to_jwt()
    )


class TokenRequestHandler(BaseHTTPRequestHandler):
    server_version = "AI-Teacher-Phase1-TokenService/1.1"

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)

        if parsed.path == "/health":
            self._write_json(HTTPStatus.OK, {"status": "ok"})
            return

        if parsed.path != "/token":
            self._write_json(HTTPStatus.NOT_FOUND, {"message": "Not found"})
            return

        query = parse_qs(parsed.query, keep_blank_values=True)
        room_name = query.get("room", [DEFAULT_ROOM])[0].strip()
        identity = query.get("identity", [""])[0].strip()
        display_name = query.get("name", [identity or "Flutter Learner"])[0].strip()

        if room_name != DEFAULT_ROOM:
            self._write_json(
                HTTPStatus.FORBIDDEN,
                {"message": "Only the configured Phase 1 room is allowed"},
            )
            return

        if not identity:
            self._write_json(
                HTTPStatus.BAD_REQUEST,
                {"message": "identity query parameter is required"},
            )
            return

        if len(identity) > MAX_IDENTITY_LENGTH or not ALLOWED_IDENTITY_PATTERN.fullmatch(identity):
            self._write_json(
                HTTPStatus.BAD_REQUEST,
                {
                    "message": (
                        "identity must be 64 characters or fewer and begin with "
                        "flutter- or phase1-check-"
                    )
                },
            )
            return

        if not display_name or len(display_name) > MAX_DISPLAY_NAME_LENGTH:
            self._write_json(
                HTTPStatus.BAD_REQUEST,
                {"message": "name must be between 1 and 80 characters"},
            )
            return

        try:
            token = create_token(room_name, identity, display_name)
        except Exception:  # pragma: no cover - defensive boundary
            LOGGER.exception("Token generation failed")
            self._write_json(
                HTTPStatus.INTERNAL_SERVER_ERROR,
                {"message": "Token generation failed"},
            )
            return

        LOGGER.info("Issued development token room=%s identity=%s", room_name, identity)
        self._write_json(
            HTTPStatus.OK,
            {
                "url": PUBLIC_URL,
                "token": token,
                "room": room_name,
                "identity": identity,
                "expires_in_seconds": 1800,
            },
        )

    def log_message(self, format: str, *args: object) -> None:
        LOGGER.info("%s - %s", self.client_address[0], format % args)

    def _write_json(self, status: HTTPStatus, payload: dict[str, object]) -> None:
        encoded = json.dumps(payload).encode("utf-8")
        self.send_response(status.value)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(encoded)


def main() -> None:
    validate_environment()
    server = ThreadingHTTPServer((HOST, PORT), TokenRequestHandler)
    server.daemon_threads = True
    LOGGER.info("Token service listening on http://%s:%s", HOST, PORT)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        LOGGER.info("Token service stopping")
    finally:
        server.shutdown()
        server.server_close()


if __name__ == "__main__":
    main()
