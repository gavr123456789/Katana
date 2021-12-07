import strformat

type
  A = ref object of RootObj

  B = ref object of A
    field: float
  
  C = ref object of A
    value: float

  D = ref object
    data: int
  
  
proc printMe(self: B) =
  echo &"I'm B with field={self.field}"
    
proc printMe(self: C) =
  echo &"I'm C with value={self.value}"
  
  
proc qwe() : A =
  var d = D(data: 1)
  case d.data
  of 1:
    return B(field: 1.23)
  of 2:
    return C(value: 3.14)
  else:
    raise newException(ValueError, "data can be only 1 or 2")


var aKind = qwe()

if aKind of B:
  echo aKind.B.field