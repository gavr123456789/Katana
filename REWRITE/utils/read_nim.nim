import npeg, strutils, tables

type Dict = Table[string, int]
type Dict2 = Table[string, string]

# let x = """proc sas() = """

# let parser = peg("pairs", d: Dict):
#   pairs <- pair * *(',' * pair) * !1
#   word <- +Alpha
#   number <- +Digit
#   pair <- >word * '=' * >number:
#     d[$1] = parseInt($2)

let parser2 = peg("proct", d: Dict2):
  proct <- "proc" * Space * word * *Space * '(' * pairs * ')' * *Space * '='
  pairs <- pair * *(',' * *Space * pair)
  word <- +Alpha
  pair <- >word * ':' * *Space * >word:
    d[$1] = $2

var args: Table[string, string]
doAssert parser2.match("proc sasss(self: GestureClick, nPress: int, x: cdouble, y: cdouble, data: Data) =", args).ok
echo args

# one=1,two=2,three=3,four=4"

# let parser3 = patt *("proc" * *Space * >+Alpha * *Space * ?"(" * *(>*Alpha * *Space * ':' * *Alpha * ?"," * *Space) * ?")" * *Space * '=')

# echo parser3.match("proc gestureMiddleClickCb(self: GestureClick, nPress: int, x: cdouble, y: cdouble, data: Data) =").captures

