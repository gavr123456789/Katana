import Slot

type
  Section* = ref object
    slots*: seq[Slot]
    selected_slot*: int # -1 no selected

func newSection*(slots: seq[Slot]): Section = 
  result = Section()
  result.selected_slot = -1
  result.slots = slots

# SLOT CONTROL
func add_slot*(section: Section, slot: Slot) = 
  section.slots.add slot

func delete_slot_by_index*(section: Section, n: int) = 
  section.slots.delete n

# UTILS
proc pretty_print*(section: Section) =
  debugEcho "section slots count: ", section.slots.len
  for slot in section.slots:
    slot.pretty_print()
    echo "----"

### TESTS

proc construct_test_section*(n: int): Section =
  var slots: seq[Slot]
  slots.add (dir: "home/gavr", name: "folder" & $n, ext: "")
  slots.add (dir: "home/gavr", name: "file", ext: ".json")
  return newSection(slots)

proc print_test() =
  let section = construct_test_section(0)
  section.pretty_print()

when isMainModule:
  echo "print test"
  print_test()
