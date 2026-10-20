///|
fn transition_suite(machine : Machine, maximum : Int32) -> Value {
  let (reached, access) = reachable(machine)
  let tests : Array[Value] = []
  let mut total = 0
  for state in reached {
    for symbol in machine.alphabet {
      if machine.edges.contains(edge_key(state, symbol)) {
        total += 1
        if tests.length() < maximum {
          let sequence = access[state].copy()
          sequence.push(symbol)
          tests.push(
            record([
              ("word", strings(sequence)),
              ("expected", observations(machine, sequence)),
            ]),
          )
        }
      }
    }
  }
  record([
    (
      "verdict",
      String(if tests.length() == total { "complete" } else { "unknown" }),
    ),
    ("reset_required", Bool(true)),
    ("coverage_kind", String("reachable_transition_cover")),
    ("reachable_transitions", Number(total.to_double())),
    ("tests", Array(tests)),
  ])
}
