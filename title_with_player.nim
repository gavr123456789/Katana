import gintro/[gtk4, gobject, gio, adw]
import std/with

const TITLE_STACK_PAGE = "title"
const PLAYER_STACK_PAGE = "player"

type
  TitleStack* = ref object of Stack
    mediaStream: MediaStream
    mediaControls: MediaControls

var headerBarGb*: TitleStack

proc activateTitlePage*() =
  headerBarGb.setVisibleChildName(TITLE_STACK_PAGE)

proc activatePlayerPage*() =
  headerBarGb.setVisibleChildName(PLAYER_STACK_PAGE)



proc stopCb(btn: Button) =
  headerBarGb.mediaStream.pause
  activateTitlePage()
  

proc createTitleStackWithPlayer*(): TitleStack =
  result = newStack(TitleStack)
  result.mediaControls = newMediaControls()
  
  let 
    stopBtn = newButton("Stop") # TODO stop icon
    box2 = newBox(Orientation.horizontal, 0)

  with box2:
    append result.mediaControls
    append stopBtn
  
  stopBtn.connect("clicked", stopCb)
 
  let title = newLabel("Katana")
  discard result.addNamed(title, TITLE_STACK_PAGE)
  discard result.addNamed(box2, PLAYER_STACK_PAGE)


proc setMediaFile*(self: TitleStack, mediaStream: MediaStream) =
  if self.mediaStream != nil:
    self.mediaStream.pause()

  self.mediaStream = mediaStream
  self.mediaControls.mediaStream = mediaStream

