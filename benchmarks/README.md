# Cost-per-Accepted-Change Benchmark

This benchmark measures the whole task, including retries and verification.
Lower response tokens alone do not count as an improvement.

## Profiles

- `baseline`: no Minimize-Cursor-Cost rules
- `current`: released rules being compared
- `adaptive`: proposed rules

Use the same Cursor version, model, repository commit, settings, MCP servers,
and prompt for every profile. Start each run in a new chat.

## Prepare the five scenarios

`scenarios.json` defines the required task shapes. For each one:

1. Pick a real task from a stable repository.
2. Freeze its starting commit and acceptance command.
3. Save the exact prompt using the default task contract.
4. Seed identical starting state for every run.
5. Run each profile at least three times to reduce model variance.

Do not let the benchmark rules reveal the expected implementation. Acceptance
must be checked independently with tests, static validation, or a fixed defect
key for review tasks.

## Record results

Write one JSON object per run to `results.jsonl`:

```json
{"task_id":"bug-fix","profile":"baseline","run_id":"b1","input_tokens":1200,"output_tokens":500,"tool_result_tokens":3400,"tool_calls":8,"correction_turns":1,"wall_seconds":95,"acceptance_passed":true,"unrelated_changed_lines":0,"reported_cost_usd":0.12}
```

Required fields:

- `task_id`, `profile`, `run_id`
- `input_tokens`, `output_tokens`, `tool_result_tokens`
- `tool_calls`, `correction_turns`, `wall_seconds`
- `acceptance_passed`, `unrelated_changed_lines`

`reported_cost_usd` is optional because Cursor/provider reporting differs.
Use `0` for token fields a provider cannot separate, but document that choice
with the results.

## Summarize

```bash
python benchmarks/summarize.py benchmarks/results.jsonl
```

The report includes:

- acceptance rate
- total tokens per accepted run
- reported cost per accepted run when supplied
- average tool calls, correction turns, wall time, and unrelated changed lines
- a quality gate comparing `current` with `adaptive`

The adaptive profile passes only when:

1. Its acceptance rate is not lower than `current`.
2. Its unrelated changed lines per run do not increase.
3. Its total tokens per accepted run decrease.

Do not publish a savings claim from fewer than three runs per scenario. Keep
failed runs in the data; deleting them hides the retry cost the project exists
to reduce.
