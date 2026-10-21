///|
test "output object key respects the same string resource boundary" {
  let output : Map[String, Json] = Map([])
  output[Array::make(65537, "k").join("")] = Json::null()
  let result = from_json(
    execute({
      "old": {
        "states": ["s"],
        "initial": "s",
        "alphabet": ["a"],
        "transitions": [
          {
            "from": "s",
            "input": "a",
            "to": "s",
            "output": Json::object(output),
          },
        ],
      },
      "new": {
        "states": ["s"],
        "initial": "s",
        "alphabet": ["a"],
        "transitions": [],
      },
    }),
  )
  assert_eq(field(result, "verdict"), String("invalid_input"))
}

///|
test "renamed states and output object ordering preserve equivalence" {
  let result = from_json(
    execute({
      "old": {
        "states": ["s"],
        "initial": "s",
        "alphabet": ["a"],
        "transitions": [
          {
            "from": "s",
            "input": "a",
            "to": "s",
            "output": { "x": 1, "ab": 2 },
          },
        ],
      },
      "new": {
        "states": ["renamed"],
        "initial": "renamed",
        "alphabet": ["a"],
        "transitions": [
          {
            "from": "renamed",
            "input": "a",
            "to": "renamed",
            "output": { "ab": 2, "x": 1 },
          },
        ],
      },
    }),
  )
  assert_eq(field(result, "verdict"), String("equivalent"))
}
