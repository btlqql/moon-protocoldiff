///|
fn audit_suite(machine : Machine, words : Array[Value]) -> Value raise InputError {
  if words.length() > 4096 { raise InputError("suite exceeds 4096 tests") }
  let covered : Map[String, Bool] = Map([])
  let rejected : Array[Value] = []
  let mut steps = 0
  for index, value in words {
    let sequence = word(value)
    let mut state = machine.initial
    for i, symbol in sequence {
      steps += 1
      if steps > 1000000 { raise InputError("suite exceeds 1000000 total steps") }
      let key = edge_key(state, symbol)
      match machine.edges.get(key) {
        None => { rejected.push(record([("test",Number(index.to_double())),("rejected_at",Number(i.to_double()))])); break }
        Some(edge) => { covered[key] = true; state = edge.target }
      }
    }
  }
  let (reached, _) = reachable(machine)
  let missing : Array[Value] = []
  let mut total = 0
  for state in reached {
    for symbol in machine.alphabet {
      let key = edge_key(state,symbol)
      if machine.edges.contains(key) {
        total += 1
        if !covered.contains(key) { missing.push(record([("state",String(machine.states[state])),("input",String(symbol))])) }
      }
    }
  }
  record([("complete",Bool(missing.is_empty())),("reachable_transitions",Number(total.to_double())),("covered_transitions",Number(covered.length().to_double())),("uncovered",Array(missing)),("rejected_tests",Array(rejected)),("reset_required",Bool(true))])
}
