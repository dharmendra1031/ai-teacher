from __future__ import annotations

import json
import logging
import os
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


def validate_environment() -> None:
    missing = [
        name
        for name, value in {
            "LIVEKIT_API_KEY": API_KEY,
            "LIVEKIT_API_SECRET": API_SECRET,
            "LIVEKIT_PUBLIC_URL": PUBLIC_URL,
        }.items()
        if not value
    ]
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")


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
    server_version = "AI-Teacher-Phase1-TokenService/1.0"

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)

        if parsed.path == "/health":
            self._write_json(HTTPStatus.OK, {"status": "ok"})
            return

        if parsed.path != "/token":
            self._write_json(HTTPStatus.NOT_FOUND, {"message": "Not found"})
            return

        query = parse_qs(parsed.query)
        room_name = query.get("room", [DEFAULT_ROOM])[0].strip()
        identity = query.get("identity", [""])[0].strip()
        display_name = query.get("name", [identity or "Flutter Learner"])[0].strip()

        if not identity:
            self._write_json(
                HTTPStatus.BAD_REQUEST,
                {"message": "identity query parameter is required"},
            )
            return

        if len(identity) > 64 or len(room_name) > 64:
            self._write_json(
                HTTPStatus.BAD_REQUEST,
                {"message": "room and identity must be 64 characters or fewer"},
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
        self.end_headers()
        self.wfile.write(encoded)


def main() -> None:
    validate_environment()
    server = ThreadingHTTPServer((HOST, PORT), TokenRequestHandler)
    LOGGER.info("Token service listening on http://%s:%s", HOST, PORT)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        LOGGER.info("Token service stopping")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
