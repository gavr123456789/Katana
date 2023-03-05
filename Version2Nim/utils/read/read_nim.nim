import npeg, strutils, tables

type Dict2 = Table[string, string]
type Variable = object 
  declarateType: string
  kind: string
  name: string


type 
  FuncType = enum
    PROC, FUNC, METHOD

  FunctionArg = tuple
    kind: string
    name: string

  Function = object 
    kind: FuncType
    name: string
    args: seq[FunctionArg]

# var x = Function(kind: FuncType.PROC, name: "sas", args: @[("sas", "sus")])
echo("qwe", 8, 99)
# TODO add digits
let procParser = peg("proct", d: Dict2):
  proct <- ("proc" | "func" | "method" | "template" | "macro") * +Space * funcName * *Space * ?args * *Space * ?returnType * *Space * '=' * *Space
  args <- '(' * pairs * ')'
  pairs <- pair * *(',' * *Space * pair)
  word <- +Alpha
  funcName <- word * ?'*'
  defaultParameter <- '=' * *Space * variableName

  variableName <- +{'A'..'Z','a'..'z','0'..'9', '[', ']', '"'}
  argumentType <- +(variableName * *(", " * variableName))
  generic <- '[' * *argumentType * ']'

  argumentTypeWithGenerics <- variableName * ?generic
  returnType <-  ':' * *Space * argumentTypeWithGenerics 
  pair <- >word * ':' * *Space * >variableName * *Space * ?defaultParameter:
    d[$1] = $2

let varParser = peg("variable", d: Variable):
  word <- +Alpha
  kind <- *Space * ':' * *Space * word
  variable <- >("var" | "let" | "const") * *Space * >word * >?kind * *Space * ?'=':
    d.declarateType = $1
    d.name = $2
    d.kind = $3

var varbable: Table[string, string]
# doAssert procParser.match("proc moveFiles(files: seqstring) =", varbable).ok
# doAssert procParser.match("func addUnders(fileExt: string): string =", varbable).ok
# doAssert procParser.match("proc unpackFilesFromFoldersByTypes*(dir: string) =", varbable).ok
# doAssert procParser.match("proc unpackFilesFromFoldersByTypes*(dir: int = 4) =", varbable).ok
# doAssert procParser.match("proc collect(dir: string, sas: string): TableRef[string, seq[string]] =", varbable).ok


echo varbable
# proc sasss(self: GestureClick, nPress: int, x: cdouble, y: cdouble, data: Data) =
# proc moveFiles(files: seq[string], dest: string) =
var varDeclatarion: Variable = Variable()
doAssert varParser.match("""var variableName: Function = Function(kind: FuncType.PROC, name: "sas")""", varDeclatarion).ok
echo varDeclatarion



proc getFileLines(fileName: string): seq[string] = readFile(fileName).splitLines

proc parseNim = 
  let entireFile = getFileLines("group_folder_by_types.nim")
  if entireFile.len == 0: 
    echo "пусто"

    return
  for i, codeString in entireFile:
    # echo i, " sasas  ", codeString
    # var varDeclatarion: Variable = Variable()
    # if varParser.match(codeString, varDeclatarion).ok:
    #   echo i, " has var declaration"
    var varbable: Table[string, string]
    if procParser.match(codeString, varbable).ok:
      echo i + 1, " has proc declaration"
      
  
    
# parseNim()