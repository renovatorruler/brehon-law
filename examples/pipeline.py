"""Run a premise through the whole spec, end to end, against a local model.

A transformation signal goes in; a story that has been driven through every gate
— spine, world, weave, concreteness, embodiment, show-not-tell — comes out, with
a stage-by-stage report of how it scored. The local ollama model is the worker
inside each stage; the gates are the system.

Run with:
    python -m examples.pipeline "A premise in one line"
"""

import sys

from brehon import pipeline
from brehon.generate import OllamaClient
from brehon.render import OutlineRenderer

DEFAULT_PREMISE = (
    "A night nurse who keeps everyone alive learns to let one patient go"
)


def main(argv: list[str]) -> None:
    premise = " ".join(argv).strip() or DEFAULT_PREMISE
    print(f"signal: {premise}\n")
    print("running the pipeline through a local ollama model (first run loads it)…\n")

    result = pipeline.generate(premise, OllamaClient())

    print("=== OUTLINE (root = the mirror; two branches) ===\n")
    print(OutlineRenderer().render(result.story))
    print(f"\ncast: {[c.name for c in result.world.characters]}")

    print("\n=== PIPELINE REPORT ===")
    print(result.report.summary())

    print("\n=== SCREENPLAY (previous -> mirror -> next) ===\n")
    print(result.screenplay)

    for message in result.warnings:
        print(f"[warn] {message}", file=sys.stderr)
    verdict = "passed every gate" if result.report.passed else "still failing gates above"
    print(f"\n{verdict}.")


if __name__ == "__main__":
    main(sys.argv[1:])
