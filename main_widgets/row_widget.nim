import gintro/[gtk4, gobject, gio, pango]
import std/with

const MAIN_STACK_NAME = "mainBox"
const SECOND_STACK_NAME = "secondBox"

type 
  FileRow* = ref object of Stack 
    # info*: gio.FileInfo
    fullPath*: string
    btn1*: ToggleButton
    btn2*: ToggleButton
    backBtn*: Button
    image*: Image
    labelFileName*: Label
    pageNum*: int
    # signals
    arrowBtnSignalid*: uint64
    fileBtnSignalid*: uint64 
    switchStackBtnSignalid*: uint64 


proc addSecondStack*(row: FileRow, stackBox: Box) = 
  discard row.addNamed(stackBox, SECOND_STACK_NAME)

proc backToMainStackCb*(btn: Button, row: FileRow) =
  row.setVisibleChildName(MAIN_STACK_NAME)


# import title_with_player
proc openSecondStackCb*(toggleBtn: ToggleButton, row: FileRow) =

  if toggleBtn.active == true:
    toggleBtn.active = false
    row.setVisibleChildName(SECOND_STACK_NAME)
    # activatePlayerPage()

proc createButtonWithLabelAndImage(toggleButton: ToggleButton, image: Image, labelFileName: Label) =
  let 
    buttonChildBox = newBox(Orientation.horizontal, 5)

  with buttonChildBox:
    append image
    append labelFileName

  with labelFileName:
    wrap = true
    wrapMode = pango.WrapMode.wordChar
    # ellipsize = EllipsizeMode.middle
    maxWidthChars = 15
  
  toggleButton.child = buttonChildBox
  toggleButton.hexpand = true
  

proc `iconName=`*(self: FileRow, iconName: string) =
  self.image.setFromIconName(iconName)


proc createFileRow*(): FileRow = 
  let 
    row = newStack(FileRow)
    mainBox = newBox(Orientation.horizontal, 0)


  row.switchStackBtnSignalid = 0
  row.arrowBtnSignalid = 0
  row.fileBtnSignalid = 0
    
  row.transitionType = slideLeftRight

  row.labelFileName = newLabel()
  row.image = newImage()
  row.btn1 = newToggleButton()
  row.btn2 = newToggleButton("↪")
  
  row.btn1.createButtonWithLabelAndImage(row.image, row.labelFileName)

  with mainBox:
    setCssClasses("linked")
    append row.btn1
    append row.btn2

  row.pageNum = 0

  discard row.addNamed(mainBox, MAIN_STACK_NAME)

  result = row

