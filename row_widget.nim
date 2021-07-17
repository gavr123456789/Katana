import gintro/[gtk4, gobject, gio, pango]
import std/with

type 
  FileRow* = ref object of Stack 
    info*: gio.FileInfo
    fullPath*: string
    btn1*: ToggleButton
    btn2*: ToggleButton
    image*: Image
    labelFileName*: Label
    pageNum*: int
    # signals
    arrowBtnSignalid*: uint64
    fileBtnSignalid*: uint64 
    switchStackBtnSignalid*: uint64 

proc `iconName=`*(self: FileRow, iconName: string) =
  self.image.setFromIconName(iconName)

proc createFileRow*(pageNum: int, name: string, stackBox: Box = nil): FileRow = 
  let 
    row = newStack(FileRow)
    mainBox = newBox(Orientation.horizontal, 0)
    # labelFileName = newLabel(name)
    box = newBox(Orientation.horizontal, 5)



  row.labelFileName = newLabel(name)
  row.image = newImage()
  row.btn1 = newToggleButton()

  row.btn2 = newToggleButton("↪")
  
# box with file picture and label  
  with box:
    append row.image
    append row.labelFileName

  with row.labelFileName:
    ellipsize = EllipsizeMode.middle
    maxWidthChars = 13

  row.btn1.child = box
  row.btn1.hexpand = true


  with mainBox:
    setCssClasses("linked")
    append row.btn1
    append row.btn2

  row.pageNum = pageNum

  discard row.addNamed(mainBox, "mainBox")
  if stackBox != nil:
    discard row.addNamed(stackBox, "stackBox")


  result = row

