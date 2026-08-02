from contextlib import redirect_stdout
from io import StringIO
from json import loads
from unittest import TestCase

from agent.main import main


class MainTest(TestCase):
    def test_emits_structured_ready_log(self) -> None:
        output = StringIO()
        with redirect_stdout(output):
            main()
        self.assertEqual(loads(output.getvalue())["status"], "ready")

