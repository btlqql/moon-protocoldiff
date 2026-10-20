///|
pub fn execute(request : Json) -> Json {
  dispatch(from_json(request)).to_json() catch {
    InputError(message) =>
      record([("verdict", String("invalid_input")), ("reason", String(message))]).to_json()
  }
}

///|
fn word(value : Value) -> Array[String] raise InputError {
  let result = array(value).map(v => identifier(v))
  if result.length() > 20000 {
    raise InputError("input sequence exceeds 20000 symbols")
  }
  result
}

///|
fn dispatch(request : Value) -> Value raise InputError {
  let operation = if has(request, "operation") {
    string(field(request, "operation"))
  } else {
    "compare"
  }
  let max_pairs = limit(request, "max_pairs", 20000, 65536)
  let max_steps = limit(request, "max_steps", 2000000, 10000000)
  match operation {
    "compare" | "verify_difference" => {
      let allowed = ["operation", "old", "new", "mode"]
      if operation == "compare" {
        allowed.push("max_pairs")
        allowed.push("max_steps")
      } else {
        allowed.push("word")
      }
      fields_only(request, allowed)
      let old = parse_machine(required(request, "old"))
      let new = parse_machine(required(request, "new"))
      let mode = if has(request, "mode") {
        string(field(request, "mode"))
      } else {
        "equivalence"
      }
      if mode != "equivalence" && mode != "backward" {
        raise InputError("mode must be equivalence or backward")
      }
      if operation == "verify_difference" {
        verify_difference(old, new, word(required(request, "word")), mode)
      } else {
        comparison(old, new, mode, max_pairs, max_steps)
      }
    }
    "audit_suite" => {
      fields_only(request, ["operation", "machine", "tests"])
      audit_suite(
        parse_machine(required(request, "machine")),
        array(required(request, "tests")),
      )
    }
    "suite" => {
      fields_only(request, ["operation", "machine", "max_tests"])
      transition_suite(
        parse_machine(required(request, "machine")),
        limit(request, "max_tests", 4096, 4096),
      )
    }
    "minimize" => {
      fields_only(request, ["operation", "machine"])
      minimize_machine(parse_machine(required(request, "machine")))
    }
    "run" | "analyze" => {
      fields_only(
        request,
        if operation == "run" {
          ["operation", "machine", "word"]
        } else {
          ["operation", "machine"]
        },
      )
      let machine = parse_machine(required(request, "machine"))
      if operation == "run" {
        observations(machine, word(required(request, "word")))
      } else {
        let (reached, access) = reachable(machine)
        record([
          ("machine", machine_value(machine)),
          ("reachable", strings(reached.map(fn(i) { machine.states[i] }))),
          (
            "access_sequences",
            Array(
              reached.map(fn(i) {
                record([
                  ("state", String(machine.states[i])),
                  ("word", strings(access[i])),
                ])
              }),
            ),
          ),
          (
            "missing_transitions",
            Number(
              (machine.states.length() * machine.alphabet.length() -
              machine.edges.length()).to_double(),
            ),
          ),
        ])
      }
    }
    _ => raise InputError("unsupported operation: " + operation)
  }
}
