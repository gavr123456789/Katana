import Slot

type
  Section* = ref object
    slots*: seq[Slot]
    selected_slot*: int # -1 no selected
    num_in_manager*: int

func newSection*(slots: seq[Slot], num_in_manager: int): Section = 
  result = Section()
  result.selected_slot = -1
  result.slots = slots
  result.num_in_manager = num_in_manager

# SLOT CONTROL
func add_slot*(section: Section, slot: Slot) = 
  section.slots.add slot

func delete_slot_by_index*(section: Section, n: int) = 
  section.slots.delete n

func get_selected_slot_path*(section: Section): string =
  return section.slots[section.selected_slot].get_full_path()

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
  return newSection(slots, 0)

proc print_test() =
  let section = construct_test_section(0)
  section.pretty_print()

when isMainModule:
  echo "print test"
  print_test()
