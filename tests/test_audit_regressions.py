"""Regression tests for the verified 2026-10-07 audit fixes.

Run from the repository root with:
    python -m unittest discover -s tests -v
"""
from __future__ import annotations

import contextlib
import hashlib
import importlib.util
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))

import make_100pct_save
import save_codec


def snapshot_files(root: Path) -> dict[str, str]:
    """Return a stable digest map for a temporary fixture tree."""
    return {
        path.relative_to(root).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(root.rglob("*"))
        if path.is_file()
    }


def write_minimal_saves(save_dir: Path, *, endless) -> None:
    save_dir.mkdir(parents=True)
    save_codec.save_save(str(save_dir / "achievements.sav"), {"sentinel": save_codec.b(False)})
    save_codec.save_save(str(save_dir / "prog.sav"), {"endless": endless})
    save_codec.save_save(str(save_dir / "stats.sav"), {})


class SaveCodecAuditRegressionTests(unittest.TestCase):
    def test_malformed_payloads_are_rejected(self):
        for label, text in save_codec.MALFORMED_PUNKCAKE.items():
            with self.subTest(label=label):
                with self.assertRaises(ValueError):
                    save_codec.parse(text)

    def test_pack_rejects_rootless_text_without_touching_destination(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            source = tmp_path / "invalid.txt"
            destination = tmp_path / "existing.sav"
            source.write_text("PUNKCAKE\nFOREVER", encoding="utf-8")
            destination.write_bytes(b"keep this output unchanged")
            before = destination.read_bytes()
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                result = save_codec.main([
                    "save_codec.py", str(source), "--pack", str(destination)
                ])
            self.assertEqual(result, 1)
            self.assertEqual(destination.read_bytes(), before)
            self.assertIn("missing root table", stderr.getvalue())


class SaveToolAuditRegressionTests(unittest.TestCase):
    def test_restore_dry_run_leaves_current_save_and_backup_unchanged(self):
        with tempfile.TemporaryDirectory() as tmp:
            game_dir = Path(tmp)
            current = game_dir / "save"
            backup = game_dir / "save_backup_20260101-000000"
            current.mkdir()
            backup.mkdir()
            (current / "sentinel.sav").write_bytes(b"current save")
            (backup / "sentinel.sav").write_bytes(b"backup save")
            before = snapshot_files(game_dir)

            stdout = io.StringIO()
            with contextlib.redirect_stdout(stdout):
                result = make_100pct_save.main([
                    "make_100pct_save.py", "--game-dir", str(game_dir),
                    "--restore", "--dry-run",
                ])

            self.assertEqual(result, 0)
            self.assertEqual(snapshot_files(game_dir), before)
            self.assertIn("restore preview only", stdout.getvalue())

    def test_unsupported_endless_shape_fails_before_any_save_or_backup_write(self):
        with tempfile.TemporaryDirectory() as tmp:
            game_dir = Path(tmp)
            save_dir = game_dir / "save"
            write_minimal_saves(save_dir, endless={"lvl": save_codec.n(7)})
            before = snapshot_files(game_dir)

            with contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(SystemExit) as raised:
                    make_100pct_save.main([
                        "make_100pct_save.py", "--game-dir", str(game_dir),
                    ])

            self.assertIn("unsupported prog.sav schema", str(raised.exception))
            self.assertIn("no save files were changed", str(raised.exception))
            self.assertEqual(snapshot_files(game_dir), before)
            self.assertFalse(any(p.name.startswith("save_backup_") for p in game_dir.iterdir()))

    def test_verified_numeric_endless_shape_is_supported(self):
        with tempfile.TemporaryDirectory() as tmp:
            game_dir = Path(tmp)
            save_dir = game_dir / "save"
            write_minimal_saves(save_dir, endless=save_codec.n(7))
            before = snapshot_files(game_dir)

            stdout = io.StringIO()
            with contextlib.redirect_stdout(stdout):
                result = make_100pct_save.main([
                    "make_100pct_save.py", "--game-dir", str(game_dir), "--dry-run",
                ])

            self.assertEqual(result, 0)
            self.assertIn("endless floor 15", stdout.getvalue())
            self.assertEqual(snapshot_files(game_dir), before)


class SmokeTestDependencyRegressionTests(unittest.TestCase):
    def test_missing_lupa_reports_skip_and_runs_parser_selftest(self):
        isolated_env = os.environ.copy()
        isolated_env.pop("PYTHONPATH", None)
        proc = subprocess.run(
            [sys.executable, "-S", str(TOOLS / "mod_smoketest.py")],
            cwd=ROOT,
            env=isolated_env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        self.assertEqual(proc.returncode, 2, proc.stdout)
        self.assertIn("selftest:", proc.stdout)
        self.assertIn("Lua smoke test: SKIPPED", proc.stdout)
        self.assertIn("Exit status 2", proc.stdout)

    @unittest.skipUnless(importlib.util.find_spec("lupa"), "optional dev dependency 'lupa' is not installed")
    def test_lupa_present_runs_lua_scenarios(self):
        proc = subprocess.run(
            [sys.executable, str(TOOLS / "mod_smoketest.py")],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        self.assertEqual(proc.returncode, 0, proc.stdout)
        self.assertIn("all()-semantics variants", proc.stdout)
        self.assertNotIn("SKIP: Lua smoke test", proc.stdout)


if __name__ == "__main__":
    unittest.main()
