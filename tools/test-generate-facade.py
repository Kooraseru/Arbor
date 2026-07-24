#!/usr/bin/env python3
"""Focused tests for Arbor root facade filesystem generation."""

from __future__ import annotations

from pathlib import Path
import importlib.util
import sys
import tempfile
import textwrap
import unittest

sys.dont_write_bytecode = True


REPO_ROOT = Path(__file__).resolve().parents[1]
GENERATOR_PATH = REPO_ROOT / "tools" / "generate-facade.py"


def load_generator():
    spec = importlib.util.spec_from_file_location("arbor_generate_facade", GENERATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {GENERATOR_PATH}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class GenerateFacadeTests(unittest.TestCase):
    def test_generate_updates_stale_root_facade(self):
        generator = load_generator()

        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            definitions = root / "Definitions" / "TypeFunctions" / "Children" / "Instances"
            definitions.mkdir(parents=True)
            (definitions / "Child.luau").write_text(
                textwrap.dedent(
                    """\
                    -- Test/Child.luau
                    --!strict

                    return function<Args>(): never
                    \terror("type only")
                    end
                    """
                ),
                encoding="utf-8",
                newline="\n",
            )
            (root / "Mold.luau").write_text(
                textwrap.dedent(
                    """\
                    -- Test/Mold.luau
                    --!strict
                    -- arbor-facade-require Mold "@self/Mold"
                    -- arbor-facade-type Mold<Schema, First, Second> = Mold.Resolve<Schema, First, Second>

                    return {}
                    """
                ),
                encoding="utf-8",
                newline="\n",
            )
            (root / "Run.luau").write_text(
                textwrap.dedent(
                    """\
                    -- Test/Run.luau
                    --!strict
                    -- arbor-facade-require Run "@self/Run"
                    -- arbor-facade-type Run<Molded> = Run.Resolve<Molded>

                    return {}
                    """
                ),
                encoding="utf-8",
                newline="\n",
            )
            runtime = root / "Runtime"
            runtime.mkdir()
            (runtime / "Children.luau").write_text(
                textwrap.dedent(
                    """\
                    -- Test/Runtime/Children.luau
                    --!strict
                    -- arbor-facade-export Runtime.Children
                    -- arbor-facade-alias ExpectChild = Runtime.Children.ExpectChild

                    return {}
                    """
                ),
                encoding="utf-8",
                newline="\n",
            )
            (root / "init.luau").write_text(
                textwrap.dedent(
                    """\
                    -- Test/init.luau
                    --!strict

                    local Arbor = {}

                    -- <arbor-facade-requires>
                    -- </arbor-facade-requires>

                    -- <arbor-facade-public>
                    -- </arbor-facade-public>

                    -- <arbor-facade-types>
                    -- </arbor-facade-types>

                    return Arbor
                    """
                ),
                encoding="utf-8",
                newline="\n",
            )

            self.assertEqual(generator.generate(root, check=True), 1)
            self.assertEqual(generator.generate(root, check=False), 0)
            self.assertEqual(generator.generate(root, check=True), 0)

            source = (root / "init.luau").read_text(encoding="utf-8")

            self.assertIn('local Child = require("@self/Definitions/TypeFunctions/Children/Instances/Child")', source)
            self.assertIn('local Mold = require("@self/Mold")', source)
            self.assertIn('local Run = require("@self/Run")', source)
            self.assertIn('local Children = require("@self/Runtime/Children")', source)
            self.assertIn("Arbor.Runtime = {}", source)
            self.assertIn("Arbor.Runtime.Children = Children", source)
            self.assertIn("Arbor.ExpectChild = Arbor.Runtime.Children.ExpectChild", source)
            self.assertIn("export type Child<Args> = Run.Resolve<Mold.Resolve<typeof(Child), Args, never>>", source)
            self.assertIn('export type RequiredChild<Parent, Name> = Child<{ Parent: Parent, Name: Name, Mode: "required" }>', source)


if __name__ == "__main__":
    unittest.main()
