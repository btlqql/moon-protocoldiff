///|
extern "js" fn read_input(path : String) -> String =
  #| (path) => {
  #|   const fs = process.getBuiltinModule('node:fs');
  #|   const b = fs.readFileSync(path === '-' ? 0 : path);
  #|   if (b.length > 16777216) throw new Error('input exceeds 16 MiB');
  #|   return new TextDecoder('utf-8', {fatal:true}).decode(b);
  #| }

///|
extern "js" fn status(code : Int32) -> Unit =
  #| code => { process.exitCode = code; }

///|
fn main {
  let args = @env.args()
  if args.length() != 3 {
    println("Usage: node main.js request.json (or - for stdin)")
    status(64)
  } else {
    try {
      let result = @engine.execute(@json.parse(read_input(args[2])))
      println(result.stringify(indent=2))
      let code = match result {
        { "verdict": "different", .. } | { "verdict": "invalid_difference", .. } => 2
        { "verdict": "unknown", .. } => 3
        { "verdict": "invalid_input", .. } => 64
        _ => 0
      }
      status(code)
    } catch {
      error => {
        println(
          Json::object({
            "verdict": Json::string("invalid_input"),
            "reason": Json::string(error.to_string()),
          }).stringify(),
        )
        status(64)
      }
    }
  }
}
