import json
from http.server import ThreadingHTTPServer
from threading import Thread
from unittest import TestCase
from urllib.error import HTTPError
from urllib.request import urlopen

from backend.health_server import HealthHandler


class HealthHandlerTest(TestCase):
    def setUp(self) -> None:
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), HealthHandler)
        self.thread = Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    def tearDown(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)

    def url(self, path: str) -> str:
        return f"http://127.0.0.1:{self.server.server_port}{path}"

    def test_liveness_and_readiness_are_healthy(self) -> None:
        for path in ("/health/live", "/health/ready"):
            with urlopen(self.url(path), timeout=2) as response:
                self.assertEqual(response.status, 200)
                self.assertEqual(json.load(response)["status"], "ok")

    def test_unknown_path_is_not_found(self) -> None:
        with self.assertRaises(HTTPError) as error:
            urlopen(self.url("/unknown"), timeout=2)
        self.assertEqual(error.exception.code, 404)
