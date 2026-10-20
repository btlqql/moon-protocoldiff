///|
fn minimize_machine(machine : Machine) -> Value {
  let (reached, _) = reachable(machine)
  let mut blocks = Array::make(machine.states.length(), -1)
  for state in reached {
    blocks[state] = 0
  }
  let mut rounds = 0
  while true {
    let signatures : Map[String, Int32] = Map([])
    let next = Array::make(machine.states.length(), -1)
    for state in reached {
      let behavior : Array[Value] = [Number(blocks[state].to_double())]
      for symbol in machine.alphabet {
        behavior.push(
          match machine.edges.get(edge_key(state, symbol)) {
            None => Array([Bool(false)])
            Some(edge) =>
              Array([
                Bool(true),
                edge.output,
                Number(blocks[edge.target].to_double()),
              ])
          },
        )
      }
      let key = Array(behavior).canonical()
      next[state] = match signatures.get(key) {
        Some(i) => i
        None => {
          let i = signatures.length()
          signatures[key] = i
          i
        }
      }
    }
    rounds += 1
    if next == blocks {
      break
    }
    blocks = next
  }
  let mut count = 0
  for state in reached {
    if blocks[state] >= count {
      count = blocks[state] + 1
    }
  }
  let names : Array[String] = []
  for i in 0..<count {
    names.push("q" + i.to_string())
  }
  let edges : Map[String, Edge] = Map([])
  let groups : Array[Value] = []
  for group in 0..<count {
    let members = reached.filter(fn(i) { blocks[i] == group })
    let representative = members[0]
    groups.push(
      record([
        ("state", String(names[group])),
        ("members", strings(members.map(fn(i) { machine.states[i] }))),
      ]),
    )
    for symbol in machine.alphabet {
      match machine.edges.get(edge_key(representative, symbol)) {
        Some(edge) =>
          edges[edge_key(group, symbol)] = {
            target: blocks[edge.target],
            output: edge.output,
          }
        None => ()
      }
    }
  }
  let minimized : Machine = {
    states: names,
    initial: blocks[machine.initial],
    alphabet: machine.alphabet,
    edges,
  }
  let verified = comparison(machine, minimized, "equivalence", 65536, 10000000)
  if field(verified, "verdict") != String("equivalent") {
    abort("partition refinement changed reachable behavior")
  }
  record([
    ("machine", machine_value(minimized)),
    ("blocks", Array(groups)),
    ("reachable_states", Number(reached.length().to_double())),
    ("minimized_states", Number(count.to_double())),
    ("refinement_rounds", Number(rounds.to_double())),
    ("equivalence_verified", Bool(true)),
  ])
}
