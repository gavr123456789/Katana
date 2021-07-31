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


proc createButtonWithLabelAndImage(toggleButton: ToggleButton, image: Image, labelFileName: Label) =
  let 
    buttonChildBox = newBox(Orientation.horizontal, 5)

  with buttonChildBox:
    append image
    append labelFileName

  with labelFileName:
    ellipsize = EllipsizeMode.middle
    maxWidthChars = 13
  
  toggleButton.child = buttonChildBox
  toggleButton.hexpand = true
  

proc `iconName=`*(self: FileRow, iconName: string) =
  self.image.setFromIconName(iconName)

proc createFileRow*(pageNum: int, name: string, stackBox: Box = nil): FileRow = 
  let 
    row = newStack(FileRow)
    mainBox = newBox(Orientation.horizontal, 0)
    
    # mediaFile = newMediaFile()
    # mediaControls = newMediaControls(mediaFile)
    

  row.labelFileName = newLabel(name)
  row.image = newImage()
  row.btn1 = newToggleButton()
  row.btn2 = newToggleButton("↪")
  
  row.btn1.createButtonWithLabelAndImage(row.image, row.labelFileName)


  with mainBox:
    setCssClasses("linked")
    append row.btn1
    # append mediaControls
    append row.btn2

  row.pageNum = pageNum

  # row.append row.btn2

  discard row.addNamed(mainBox, "mainBox")
  if stackBox != nil:
    discard row.addNamed(stackBox, "stackBox")


  result = row

