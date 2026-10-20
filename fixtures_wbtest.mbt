///|
fn selected(value : Json, parts : Array[String]) -> Json {
 let mut current=value
 for part in parts {current=match current {Json::Object(fields)=>fields[part]; _=>abort("fixture path")}}
 current
}

///|
test "identical machines" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"equivalent\"")))
}

///|
test "delayed output difference" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":1},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"different\"")))
assert_eq(from_json(selected(result,["word"])),from_json(@json.parse("[\"open\",\"send\"]")))
assert_eq(from_json(selected(result,["shortest"])),from_json(@json.parse("true")))
}

///|
test "difference verifier" {
let result=execute(@json.parse("{\"operation\":\"verify_difference\",\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":1},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"word\":[\"open\",\"send\"]}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"valid_difference\"")))
}

///|
test "false difference rejected" {
let result=execute(@json.parse("{\"operation\":\"verify_difference\",\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":1},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"word\":[\"open\"]}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_difference\"")))
}

///|
test "run rejects undefined" {
let result=execute(@json.parse("{\"operation\":\"run\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"word\":[\"send\"]}"))
assert_eq(from_json(selected(result,["accepted"])),from_json(@json.parse("false")))
assert_eq(from_json(selected(result,["rejected_at"])),from_json(@json.parse("0")))
}

///|
test "run records outputs" {
let result=execute(@json.parse("{\"operation\":\"run\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"word\":[\"open\",\"send\",\"close\"]}"))
assert_eq(from_json(selected(result,["accepted"])),from_json(@json.parse("true")))
assert_eq(from_json(selected(result,["outputs"])),from_json(@json.parse("[\"ok\",0,\"bye\"]")))
}

///|
test "analyze reachable" {
let result=execute(@json.parse("{\"operation\":\"analyze\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["reachable"])),from_json(@json.parse("[\"closed\",\"open\"]")))
assert_eq(from_json(selected(result,["missing_transitions"])),from_json(@json.parse("3")))
}

///|
test "minimized verified" {
let result=execute(@json.parse("{\"operation\":\"minimize\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["minimized_states"])),from_json(@json.parse("2")))
assert_eq(from_json(selected(result,["equivalence_verified"])),from_json(@json.parse("true")))
}

///|
test "transition suite" {
let result=execute(@json.parse("{\"operation\":\"suite\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"complete\"")))
assert_eq(from_json(selected(result,["reachable_transitions"])),from_json(@json.parse("3")))
assert_eq(from_json(selected(result,["reset_required"])),from_json(@json.parse("true")))
}

///|
test "suite bound" {
let result=execute(@json.parse("{\"operation\":\"suite\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"max_tests\":1}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"unknown\"")))
}

///|
test "suite audit" {
let result=execute(@json.parse("{\"operation\":\"audit_suite\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"tests\":[[\"open\",\"send\",\"close\"]]}"))
assert_eq(from_json(selected(result,["complete"])),from_json(@json.parse("true")))
assert_eq(from_json(selected(result,["covered_transitions"])),from_json(@json.parse("3")))
}

///|
test "suite missing edge" {
let result=execute(@json.parse("{\"operation\":\"audit_suite\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"tests\":[[\"open\"]]}"))
assert_eq(from_json(selected(result,["complete"])),from_json(@json.parse("false")))
assert_eq(from_json(selected(result,["covered_transitions"])),from_json(@json.parse("1")))
}

///|
test "suite rejected test" {
let result=execute(@json.parse("{\"operation\":\"audit_suite\",\"machine\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"tests\":[[\"send\"]]}"))
assert_eq(from_json(selected(result,["rejected_tests"])),from_json(@json.parse("[{\"test\":0,\"rejected_at\":0}]")))
}

///|
test "pair budget unknown" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"max_pairs\":1}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"unknown\"")))
}

///|
test "step budget unknown" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"max_steps\":1}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"unknown\"")))
}

///|
test "extension changes equivalence" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"},{\"from\":\"closed\",\"input\":\"send\",\"to\":\"closed\",\"output\":null}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"different\"")))
assert_eq(from_json(selected(result,["word"])),from_json(@json.parse("[\"send\"]")))
}

///|
test "extension backward compatible" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"},{\"from\":\"closed\",\"input\":\"send\",\"to\":\"closed\",\"output\":null}]},\"mode\":\"backward\"}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"compatible\"")))
}

///|
test "duplicate state" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"closed\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "empty alphabet" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "undeclared initial" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"no\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "extra machine property" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}],\"extra\":true},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "nondeterminism rejected" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"},{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "output required" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]}}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "mode validated" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"mode\":\"wrong\"}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "unknown option" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"random\":true}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}

///|
test "zero budget" {
let result=execute(@json.parse("{\"old\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"new\":{\"states\":[\"closed\",\"open\"],\"initial\":\"closed\",\"alphabet\":[\"open\",\"send\",\"close\"],\"transitions\":[{\"from\":\"closed\",\"input\":\"open\",\"to\":\"open\",\"output\":\"ok\"},{\"from\":\"open\",\"input\":\"send\",\"to\":\"open\",\"output\":0},{\"from\":\"open\",\"input\":\"close\",\"to\":\"closed\",\"output\":\"bye\"}]},\"max_pairs\":0}"))
assert_eq(from_json(selected(result,["verdict"])),from_json(@json.parse("\"invalid_input\"")))
}
