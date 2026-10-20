///|
test "partial machines preserve undefined versus null output" {
  let a = parse_machine(
    from_json({
      "states": ["s"],
      "initial": "s",
      "alphabet": ["x"],
      "transitions": [{ "from": "s", "input": "x", "to": "s", "output": null }],
    }),
  )
  let b = parse_machine(
    from_json({
      "states": ["s"],
      "initial": "s",
      "alphabet": ["x"],
      "transitions": [],
    }),
  )
  assert_eq(
    field(comparison(a, b, "equivalence", 100, 100), "verdict"),
    String("different"),
  )
  assert_eq(
    field(comparison(b, a, "backward", 100, 100), "verdict"),
    String("compatible"),
  )
  assert_eq(
    field(verify_difference(b, a, ["x"], "backward"), "valid"),
    Bool(false),
  )
}

///|
test "bounded product search cannot claim equivalence" {
  let a = parse_machine(
    from_json({
      "states": ["s", "t"],
      "initial": "s",
      "alphabet": ["x"],
      "transitions": [
        { "from": "s", "input": "x", "to": "t", "output": 0 },
        { "from": "t", "input": "x", "to": "s", "output": 1 },
      ],
    }),
  )
  assert_eq(
    field(comparison(a, a, "equivalence", 1, 100), "verdict"),
    String("unknown"),
  )
}
