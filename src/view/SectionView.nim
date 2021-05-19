import gintro/[gtk4, gobject]
import std/with, std/tables
import SlotView
import ../logic/Slot
import ../logic/Section
import sugar


var callBackFunc*: proc (self: ListBox, row: ListBoxRow)
# Структура данных в которой есть ссылки на виджеты к номерам какие они по счету

proc createSection*(section: Section): Frame =
  let
    frame = newFrame()
    listBox = newListBox()

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