import gintro/[gtk4, gobject]
import std/with, std/tables
import SlotView
import ../logic/Slot
import ../logic/Section


var callBackFunc*: proc (self: ListBox, row: ListBoxRow)

var r: ref int 
new(r)

# let p = cast[ptr int](r)
# let p = addr r[]
# echo p[]

proc createSection*(section: Section, num: int): Frame =
  let
    frame = newFrame()
    listBox = newListBox()

  var r: ref int 
  new(r)
  r[] = num
  
  listBox.setData("num", cast[ptr int](r))
  let intPtr = listBox.getData("num")
  echo (cast[ptr int](intPtr))[] 
  with listBox:
    selectionMode = SelectionMode.single
    showSeparators = true
    setCssClasses("rich-list")
    # setCssClasses("navigation-sidebar")
    # setCssClasses("data-table")
  
  if callBackFunc == nil:
    echo "callBackFunc == nil"
    

  listBox.connect("row-activated", callBackFunc)

  for slot in section.slots:
    listBox.append createSlot(slot.name)

  frame.child = listBox
  result = frame