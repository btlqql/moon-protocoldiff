///|
test "equivalent reachable states merge while unreachable states disappear" {
  let source = from_json({
    "states": ["a", "b", "unused"],
    "initial": "a",
    "alphabet": ["x"],
    "transitions": [
      { "from": "a", "input": "x", "to": "b", "output": 0 },
      { "from": "b", "input": "x", "to": "a", "output": 0 },
      { "from": "unused", "input": "x", "to": "unused", "output": 99 },
    ],
  })
  let result = minimize_machine(parse_machine(source))
  assert_eq(field(result, "minimized_states"), Number(1))
  assert_eq(field(result, "reachable_states"), Number(2))
  assert_eq(field(result, "equivalence_verified"), Bool(true))
}
