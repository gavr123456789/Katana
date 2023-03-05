import jsony
import json
import tables
import strutils


func isObjOrArray(x: JsonNode): bool = 
  if x.kind == JArray or x.kind == JObject:
    true
  else:
    false

proc printFirstLevelNodes(jsonNode: JsonNode) = 
  let fields = jsonNode.getFields
  if fields.len == 0:
    echo jsonNode
    return

  for k, v in fields.pairs:
    var str = k & ": "
    
    if v.kind == JObject:
      str.add("object")
    elif v.kind == JArray:
      str.add("array")
    else:
      str.add(" " & $v)

    echo str



proc printContentFromPath(jobj: JsonNode, path: string) = 
  let splittedPath = path.split("/")
  var obj = jobj

  for key in splittedPath:
    if obj.hasKey(key) and obj.isObjOrArray:
      echo "obj has key: ", key
      obj = obj[key]
    else:
      echo "json has no key: ", key
      return
  printFirstLevelNodes(obj)
  


let fileContext = readFile("json.json")
var x = fromJson(fileContext)
x.printContentFromPath("glossary/GlossDiv/GlossList/GlossEntry/GlossDef/GlossSeeAlso")
