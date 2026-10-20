///|
priv struct Edge {
  target : Int32
  output : Value
}

///|
priv struct Machine {
  states : Array[String]
  initial : Int32
  alphabet : Array[String]
  edges : Map[String, Edge]
}

///|
fn edge_key(state : Int32, symbol : String) -> String {
  Array([Number(state.to_double()), String(symbol)]).canonical()
}

///|
fn parse_machine(value : Value) -> Machine raise InputError {
  fields_only(value, ["states", "initial", "alphabet", "transitions"])
  let states = array(required(value, "states")).map(v => identifier(v))
  let alphabet = array(required(value, "alphabet")).map(v => identifier(v))
  if states.is_empty() ||
    states.length() > 128 ||
    alphabet.is_empty() ||
    alphabet.length() > 32 {
    raise InputError("machine requires 1..128 states and 1..32 input symbols")
  }
  states.sort_by(lexical_compare)
  alphabet.sort_by(lexical_compare)
  let indexes : Map[String, Int32] = Map([])
  for i, name in states {
    if indexes.contains(name) {
      raise InputError("duplicate state: " + name)
    }
    indexes[name] = i
  }
  for i in 1..<alphabet.length() {
    if alphabet[i] == alphabet[i - 1] {
      raise InputError("duplicate alphabet symbol")
    }
  }
  let start = identifier(required(value, "initial"))
  let initial = match indexes.get(start) {
    Some(i) => i
    None => raise InputError("initial state not declared")
  }
  let transitions = array(required(value, "transitions"))
  if transitions.length() > 4096 {
    raise InputError("too many transitions")
  }
  let edges : Map[String, Edge] = Map([])
  let nodes = Ref(0)
  for item in transitions {
    fields_only(item, ["from", "input", "to", "output"])
    let from = identifier(required(item, "from"))
    let target = identifier(required(item, "to"))
    let symbol = identifier(required(item, "input"))
    let source = match indexes.get(from) {
      Some(i) => i
      None => raise InputError("undeclared transition source")
    }
    let to = match indexes.get(target) {
      Some(i) => i
      None => raise InputError("undeclared transition target")
    }
    if !alphabet.contains(symbol) {
      raise InputError("undeclared input symbol")
    }
    let key = edge_key(source, symbol)
    if edges.contains(key) {
      raise InputError("nondeterministic duplicate state/input transition")
    }
    let output = required(item, "output")
    validate_value(output, 0, nodes)
    edges[key] = { target: to, output, }
  }
  { states, initial, alphabet, edges, }
}

///|
fn reachable(machine : Machine) -> (Array[Int32], Array[Array[String]]) {
  let seen = Array::make(machine.states.length(), false)
  let access = Array::make(machine.states.length(), [])
  let order : Array[Int32] = [machine.initial]
  seen[machine.initial] = true
  let mut cursor = 0
  while cursor < order.length() {
    let state = order[cursor]
    cursor += 1
    for symbol in machine.alphabet {
      match machine.edges.get(edge_key(state, symbol)) {
        Some(edge) =>
          if !seen[edge.target] {
            seen[edge.target] = true
            let word = access[state].copy()
            word.push(symbol)
            access[edge.target] = word
            order.push(edge.target)
          }
        None => ()
      }
    }
  }
  (order, access)
}

///|
fn observations(machine : Machine, word : Array[String]) -> Value {
  let mut state = machine.initial
  let output : Array[Value] = []
  for i, symbol in word {
    match machine.edges.get(edge_key(state, symbol)) {
      None =>
        return record([
          ("accepted", Bool(false)),
          ("rejected_at", Number(i.to_double())),
          ("outputs", Array(output)),
          ("state", String(machine.states[state])),
        ])
      Some(edge) => {
        output.push(edge.output)
        state = edge.target
      }
    }
  }
  record([
    ("accepted", Bool(true)),
    ("outputs", Array(output)),
    ("state", String(machine.states[state])),
  ])
}

///|
fn machine_value(machine : Machine) -> Value {
  let transitions : Array[Value] = []
  for i, name in machine.states {
    for symbol in machine.alphabet {
      match machine.edges.get(edge_key(i, symbol)) {
        Some(edge) =>
          transitions.push(
            record([
              ("from", String(name)),
              ("input", String(symbol)),
              ("to", String(machine.states[edge.target])),
              ("output", edge.output),
            ]),
          )
        None => ()
      }
    }
  }
  record([
    ("states", strings(machine.states)),
    ("initial", String(machine.states[machine.initial])),
    ("alphabet", strings(machine.alphabet)),
    ("transitions", Array(transitions)),
  ])
}
