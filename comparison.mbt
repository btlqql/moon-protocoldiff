///|
priv struct PairNode {
  left : Int32
  right : Int32
  word : Array[String]
}

///|
fn comparison(
  left : Machine,
  right : Machine,
  mode : String,
  max_pairs : Int32,
  max_steps : Int32,
) -> Value {
  let alphabet = left.alphabet.copy()
  if mode == "equivalence" {
    for symbol in right.alphabet {
      if !alphabet.contains(symbol) {
        alphabet.push(symbol)
      }
    }
  }
  alphabet.sort_by(lexical_compare)
  let queue : Array[PairNode] = [
    { left: left.initial, right: right.initial, word: [], },
  ]
  let seen : Map[String, Bool] = Map([
    (edge_key(left.initial, right.initial.to_string()), true),
  ])
  let mut cursor = 0
  let mut steps = 0
  while cursor < queue.length() {
    let node = queue[cursor]
    cursor += 1
    for symbol in alphabet {
      if steps >= max_steps {
        return record([
          ("verdict", String("unknown")),
          ("reason", String("max_steps")),
          ("visited_pairs", Number(queue.length().to_double())),
        ])
      }
      steps += 1
      let old = left.edges.get(edge_key(node.left, symbol))
      let new = right.edges.get(edge_key(node.right, symbol))
      if mode == "backward" && old is None {
        continue
      }
      let different = match (old, new) {
        (None, None) => false
        (Some(a), Some(b)) => a.output != b.output
        _ => true
      }
      let word = node.word.copy()
      word.push(symbol)
      if different {
        return record([
          ("verdict", String("different")),
          ("mode", String(mode)),
          ("word", strings(word)),
          ("shortest", Bool(true)),
          ("old", observations(left, word)),
          ("new", observations(right, word)),
          ("visited_pairs", Number(queue.length().to_double())),
          ("transition_checks", Number(steps.to_double())),
        ])
      }
      match (old, new) {
        (Some(a), Some(b)) => {
          let key = edge_key(a.target, b.target.to_string())
          if !seen.contains(key) {
            if queue.length() >= max_pairs {
              return record([
                ("verdict", String("unknown")),
                ("reason", String("max_pairs")),
                ("visited_pairs", Number(queue.length().to_double())),
              ])
            }
            seen[key] = true
            queue.push({ left: a.target, right: b.target, word, })
          }
        }
        _ => ()
      }
    }
  }
  record([
    (
      "verdict",
      String(if mode == "backward" { "compatible" } else { "equivalent" }),
    ),
    ("mode", String(mode)),
    ("complete", Bool(true)),
    ("visited_pairs", Number(queue.length().to_double())),
    ("transition_checks", Number(steps.to_double())),
  ])
}

///|
fn verify_difference(
  left : Machine,
  right : Machine,
  word : Array[String],
  mode : String,
) -> Value {
  let old = observations(left, word)
  let new = observations(right, word)
  let a = match field(old, "outputs") {
    Array(v) => v
    _ => []
  }
  let b = match field(new, "outputs") {
    Array(v) => v
    _ => []
  }
  let size = if a.length() < b.length() { a.length() } else { b.length() }
  let mut different = false
  for i in 0..<size {
    if a[i] != b[i] {
      different = true
    }
  }
  if a.length() != b.length() ||
    field(old, "accepted") != field(new, "accepted") {
    different = true
  }
  // Once the old machine rejects, extra new behavior is permitted in backward mode.
  if mode == "backward" && field(old, "accepted") == Bool(false) {
    different = false
    for i in 0..<a.length() {
      if i >= b.length() || a[i] != b[i] {
        different = true
      }
    }
  }
  record([
    (
      "verdict",
      String(if different { "valid_difference" } else { "invalid_difference" }),
    ),
    ("valid", Bool(different)),
    ("old", old),
    ("new", new),
  ])
}
