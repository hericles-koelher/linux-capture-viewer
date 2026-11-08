import runpy
import tempfile
import unittest
from pathlib import Path

CONFIG = runpy.run_path(str(Path(__file__).parents[1] / "bin/capture-viewer-config"))


class ConfigTests(unittest.TestCase):
    def test_config_json_roundtrip_and_rejects_shell_payload(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "config.json"
            valid = {"video": "/dev/video2", "format": "yuyv422", "resolution": "1920x1080", "framerate": "60", "audio_source": ""}
            path.write_text(__import__("json").dumps(valid))
            self.assertEqual(CONFIG["load_config"](path), valid)
            valid["video"] = "$(touch /tmp/pwned)"
            path.write_text(__import__("json").dumps(valid))
            self.assertIsNone(CONFIG["load_config"](path))
            path.write_text("{}")
            self.assertIsNone(CONFIG["load_config"](path))

    def test_mode_parser_tracks_pixel_format_resolution_and_discrete_fps(self):
        fixture = """[0]: 'YUYV' (YUYV 4:2:2)
        Size: Discrete 1920x1080
            Interval: Discrete 0.017s (60.000 fps)
            Interval: Discrete 0.033s (30.000 fps)
[1]: 'MJPG' (Motion-JPEG)
        Size: Discrete 1280x720
            Interval: Discrete 0.017s (60.000 fps)
[2]: 'ZZZZ' (format without an FFmpeg mapping)
        Size: Discrete 800x600
            Interval: Discrete 0.017s (60.000 fps)
"""
        namespace = CONFIG["modes"].__globals__
        old_run = namespace["run"]
        namespace["run"] = lambda args: fixture
        try:
            self.assertEqual(CONFIG["modes"]("/dev/video2"), [
                ("yuyv422", "1920x1080", "60"),
                ("yuyv422", "1920x1080", "30"),
                ("mjpeg", "1280x720", "60"),
            ])
        finally:
            namespace["run"] = old_run

    def test_dependent_options_only_offer_supported_combinations(self):
        combos = [
            ("yuyv422", "1920x1080", "30"),
            ("yuyv422", "1280x720", "60"),
            ("mjpeg", "1920x1080", "60"),
        ]
        options = CONFIG["dependent_mode_options"]
        self.assertEqual(options(combos), (
            ["yuyv422", "mjpeg"], ["1920x1080", "1280x720"], ["30"]
        ))
        self.assertEqual(options(combos, "mjpeg", "1920x1080"), (
            ["yuyv422", "mjpeg"], ["1920x1080"], ["60"]
        ))


if __name__ == "__main__":
    unittest.main()
