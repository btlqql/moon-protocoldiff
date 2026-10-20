///|
test "transition cover uses reset and bounded generation is unknown" {
  let machine = parse_machine(from_json({"states":["a","b"],"initial":"a","alphabet":["x"],"transitions":[{"from":"a","input":"x","to":"b","output":1},{"from":"b","input":"x","to":"a","output":2}]}))
  let full = transition_suite(machine, 4096)
  assert_eq(field(full,"verdict"), String("complete"))
  assert_eq(array(field(full,"tests")).length(),2)
  assert_eq(field(transition_suite(machine,1),"verdict"),String("unknown"))
  let parsed = @json.parse("{\"operation\":\"unsupported\"}")
  assert_eq(field(from_json(execute(parsed)),"verdict"),String("invalid_input"))
}
