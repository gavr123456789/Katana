import ../logic/Slot

proc createFakeSlot*(names: seq[string]): seq[Slot] = 
  var qwe: seq[Slot]
  for name in names:
    qwe.add (dir: "1", name: name, ext: "")

    
  return qwe
