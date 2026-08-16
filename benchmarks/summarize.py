#!/usr/bin/env python3
"""Summarize Cursor benchmark runs without third-party dependencies."""

from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

PROFILES = {"baseline", "current", "adaptive"}
TASKS = {
    "bug-fix",
    "feature-reuse",
    "code-review",
    "multi-file-change",
    "failing-test-diagnosis",
}
NUMBER_FIELDS = (
    "input_tokens",
    "output_tokens",
    "tool_result_tokens",
    "tool_calls",
    "correction_turns",
    "wall_seconds",
    "unrelated_changed_lines",
)


def load_records(path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    seen: set[tuple[str, str, str]] = set()
    for line_number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not raw.strip():
            continue
        try:
            record = json.loads(raw)
        except json.JSONDecodeError as exc:
            raise ValueError(f"line {line_number}: invalid JSON: {exc.msg}") from exc
        validate_record(record, line_number)
        key = (record["task_id"], record["profile"], record["run_id"])
        if key in seen:
            raise ValueError(f"line {line_number}: duplicate run {key}")
        seen.add(key)
        records.append(record)
    if not records:
        raise ValueError("results file contains no records")
    return records


def validate_record(record: Any, line_number: int) -> None:
    if not isinstance(record, dict):
        raise ValueError(f"line {line_number}: each record must be an object")
    for field in ("task_id", "profile", "run_id"):
        if not isinstance(record.get(field), str) or not record[field]:
            raise ValueError(f"line {line_number}: {field} must be a non-empty string")
    if record["task_id"] not in TASKS:
        raise ValueError(f"line {line_number}: unknown task_id {record['task_id']!r}")
    if record["profile"] not in PROFILES:
        raise ValueError(f"line {line_number}: unknown profile {record['profile']!r}")
    if not isinstance(record.get("acceptance_passed"), bool):
        raise ValueError(f"line {line_number}: acceptance_passed must be boolean")
    for field in NUMBER_FIELDS:
        value = record.get(field)
        if isinstance(value, bool) or not isinstance(value, (int, float)) or value < 0:
            raise ValueError(f"line {line_number}: {field} must be a non-negative number")
    if "reported_cost_usd" in record:
        value = record["reported_cost_usd"]
        if isinstance(value, bool) or not isinstance(value, (int, float)) or value < 0:
            raise ValueError(
                f"line {line_number}: reported_cost_usd must be non-negative"
            )


def summarize(records: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        grouped[record["profile"]].append(record)

    summaries: dict[str, dict[str, Any]] = {}
    for profile, runs in sorted(grouped.items()):
        accepted = sum(run["acceptance_passed"] for run in runs)
        total_tokens = sum(
            run["input_tokens"] + run["output_tokens"] + run["tool_result_tokens"]
            for run in runs
        )
        cost_complete = all("reported_cost_usd" in run for run in runs)
        summaries[profile] = {
            "runs": len(runs),
            "runs_by_task": dict(sorted(Counter(run["task_id"] for run in runs).items())),
            "accepted": accepted,
            "acceptance_rate": accepted / len(runs),
            "tokens_per_accepted": total_tokens / accepted if accepted else None,
            "cost_usd_per_accepted": (
                sum(run["reported_cost_usd"] for run in runs) / accepted
                if accepted and cost_complete
                else None
            ),
            "avg_tool_calls": average(runs, "tool_calls"),
            "avg_correction_turns": average(runs, "correction_turns"),
            "avg_wall_seconds": average(runs, "wall_seconds"),
            "avg_unrelated_changed_lines": average(runs, "unrelated_changed_lines"),
        }
    return summaries


def average(runs: list[dict[str, Any]], field: str) -> float:
    return sum(run[field] for run in runs) / len(runs)


def quality_gate(summaries: dict[str, dict[str, Any]]) -> tuple[bool, list[str]]:
    reasons: list[str] = []
    if "current" not in summaries or "adaptive" not in summaries:
        return False, ["current and adaptive profiles are both required"]

    current = summaries["current"]
    adaptive = summaries["adaptive"]
    for profile_name, summary in (("current", current), ("adaptive", adaptive)):
        missing = sorted(TASKS - summary["runs_by_task"].keys())
        if missing:
            reasons.append(f"{profile_name} missing scenarios: {', '.join(missing)}")
        under_sampled = sorted(
            task for task, count in summary["runs_by_task"].items() if count < 3
        )
        if under_sampled:
            reasons.append(
                f"{profile_name} needs at least 3 runs for: {', '.join(under_sampled)}"
            )

    if adaptive["acceptance_rate"] < current["acceptance_rate"]:
        reasons.append("adaptive acceptance rate is lower")
    if (
        adaptive["avg_unrelated_changed_lines"]
        > current["avg_unrelated_changed_lines"]
    ):
        reasons.append("adaptive unrelated diff increased")
    if adaptive["tokens_per_accepted"] is None:
        reasons.append("adaptive has no accepted runs")
    elif current["tokens_per_accepted"] is None:
        reasons.append("current has no accepted runs")
    elif adaptive["tokens_per_accepted"] >= current["tokens_per_accepted"]:
        reasons.append("adaptive tokens per accepted run did not decrease")
    return not reasons, reasons


def print_report(
    summaries: dict[str, dict[str, Any]], gate_passed: bool, reasons: list[str]
) -> None:
    for profile, summary in summaries.items():
        tokens = summary["tokens_per_accepted"]
        cost = summary["cost_usd_per_accepted"]
        print(f"{profile}:")
        print(
            f"  accepted {summary['accepted']}/{summary['runs']} "
            f"({summary['acceptance_rate']:.1%})"
        )
        print(f"  tokens/accepted: {tokens:.0f}" if tokens is not None else "  tokens/accepted: n/a")
        if cost is not None:
            print(f"  cost/accepted: ${cost:.4f}")
        print(
            "  averages: "
            f"{summary['avg_tool_calls']:.1f} tools, "
            f"{summary['avg_correction_turns']:.1f} corrections, "
            f"{summary['avg_wall_seconds']:.1f}s, "
            f"{summary['avg_unrelated_changed_lines']:.1f} unrelated lines"
        )
    print(f"quality gate: {'PASS' if gate_passed else 'FAIL'}")
    for reason in reasons:
        print(f"  - {reason}")


def self_test() -> None:
    records: list[dict[str, Any]] = []
    for profile, token_scale in (("current", 1.0), ("adaptive", 0.6)):
        for task in sorted(TASKS):
            for run_number in range(3):
                records.append(
                    {
                        "task_id": task,
                        "profile": profile,
                        "run_id": str(run_number),
                        "input_tokens": 1000 * token_scale,
                        "output_tokens": 500 * token_scale,
                        "tool_result_tokens": 2000 * token_scale,
                        "tool_calls": 6,
                        "correction_turns": 0,
                        "wall_seconds": 30,
                        "acceptance_passed": True,
                        "unrelated_changed_lines": 0,
                        "reported_cost_usd": 0.1 * token_scale,
                    }
                )
    passed, reasons = quality_gate(summarize(records))
    if not passed:
        raise AssertionError("; ".join(reasons))
    print("Self-test passed.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", nargs="?", type=Path, help="JSONL results file")
    parser.add_argument("--json", action="store_true", help="emit JSON")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        self_test()
        return
    if args.results is None:
        parser.error("results is required unless --self-test is used")

    try:
        summaries = summarize(load_records(args.results))
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    passed, reasons = quality_gate(summaries)
    if args.json:
        print(json.dumps({"profiles": summaries, "quality_gate": {"passed": passed, "reasons": reasons}}, indent=2))
    else:
        print_report(summaries, passed, reasons)


if __name__ == "__main__":
    main()
