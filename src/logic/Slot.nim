type
  Slot* = tuple[dir, name, ext: string]
  SlotType = enum DIR, FILE, JSONFILE, JSONNODE

func get_type(slot: Slot): SlotType =
  case slot.ext:
  of "": DIR
  of ".json": JSONFILE
  of "json": JSONNODE
  else: FILE

func get_full_path*(slot: Slot): string =
  case slot.get_type():
  of DIR: return slot.dir & slot.name
  of FILE: return slot.dir & slot.name & slot.ext
  of JSONFILE: ""
  of JSONNODE: ""
 
proc pretty_print*(slot: Slot) =
  echo "slot type of ", slot.get_type, " with name: ", slot.name