# Moon ProtocolDiff

A MoonBit library and JSON CLI for comparing **explicit deterministic partial Mealy machines** across protocol versions.

- Owner: **btlqql**; proposed replacement for FindCore.
- Package: `btlqql/moon_protocoldiff@0.1.1`, Apache-2.0.
- Repository: https://github.com/btlqql/moon-protocoldiff

## Implemented kernel

1. Strict model validation: declared states/symbols, deterministic transitions, explicit JSON outputs, missing transitions distinct from null outputs.
2. Product-graph BFS for behavioral equivalence and old-to-new backward compatibility. Differences include a shortest distinguishing input and both output traces. State names need not match.
3. Independent trace simulation verifies a proposed difference. It does not certify minimality.
4. Reachability and partition refinement remove inaccessible states and merge behaviorally equivalent states. The result is checked against the original by product comparison.
5. Reset-based transition-cover generation includes shortest access sequences and expected observations. A separate suite auditor identifies reachable edges covered, missing edges and rejected tests.

This implements standard automata methods; no new algorithm or ecosystem-first claim is made. It compares protocol models supplied by a caller, not arbitrary source code, concurrent histories, network captures or nondeterministic/timed protocols. Transition coverage is not a complete black-box conformance proof.

## Use

```sh
moon update
moon build --target js
node _build/js/debug/build/cmd/main/main.js examples/session-diff.json
# exits 2: word ["open","send"] reveals changed output
moon add btlqql/moon_protocoldiff@0.1.1
```

Import `"btlqql/moon_protocoldiff" @engine` and call `@engine.execute(request)` with `Json`. Returns JSON, including `invalid_input` for invalid models. Pure core supports js, wasm, wasm-gc and native; Node 24 CLI supports JS only. Pass `-` for stdin. CLI exit: 0 successful report/valid difference, 2 behavioral difference/invalid difference witness, 3 unknown, 64 invalid input. A run rejection or incomplete coverage is a report, not a CLI error.

## API

| operation | fields | result |
|---|---|---|
| compare (default) | old, new, mode?, max_pairs?, max_steps? | equivalent / compatible / different / unknown |
| verify_difference | old, new, word, mode? | valid_difference / invalid_difference |
| minimize | machine | machine, blocks, equivalence_verified |
| run | machine, word | outputs, accepted, state, rejected_at? |
| analyze | machine | normalized machine, reachable, access_sequences |
| suite | machine, max_tests? | tests with word/expected, complete or unknown |
| audit_suite | machine, tests (arrays of symbols) | covered/uncovered transitions, rejected_tests |

Models contain `states`, `initial`, `alphabet`, `transitions`; each transition contains `from`, `input`, `to`, `output`. The example is a session with open/send/close commands. Equivalence compares the union alphabet; backward mode permits newly defined behavior where the old version rejects. Undefined transitions reject immediately. Outputs use structural JSON equality.

## Limits

1–128 states, 1–32 symbols, at most 4096 transitions, 256 UTF-16 units per identifier. Output trees: depth 32, total 20000 nodes per machine, 65536 units per string. Pair budget defaults 20000 (maximum 65536), step budget 2000000 (maximum 10000000). Sequence length 20000; suite 4096 tests / 1000000 audit steps. CLI JSON input 16 MiB. Exhausted comparison/generation budgets return unknown; invalid sizes/options return invalid_input. A missing difference under unknown is not equivalence.

## Verification

```sh
moon check --deny-warn --target js
moon test --target js  # 30 tests, including 26 golden API cases
moon test --target wasm
moon test --target wasm-gc
moon test --target native
moon build --target js
node scripts/check.mjs
python -B scripts/reference.py
python -B scripts/scale.py
```

The Python oracle independently eliminates invalid pairs to a greatest relation instead of calling the MoonBit BFS. Fixed seed 20261020: 60 model pairs, both modes, 437 checks including independent difference execution, exhaustive shorter words, reachable equivalence classes, minimization and transition-cover auditing. Synthetic cases are not production adoption or performance claims. CI runs all four core targets and the CLI/reference gates.

Version 0.1.1 stores BFS parent links and reconstructs the witness only when needed, avoiding a complete input sequence copy for every visited pair. The coprime-cycle scale check visits 16256 reachable pairs and checks explicit budget exhaustion at 100 pairs. This is a bounded scale check, not a throughput benchmark.

Common JSON Value and CLI scaffolding is disclosed in [THIRD_PARTY.md](THIRD_PARTY.md); domain modules are machine.mbt, comparison.mbt, minimize.mbt, suite.mbt, coverage.mbt and api.mbt. Neither repository publication nor MoonCakes publication constitutes competition registration.
