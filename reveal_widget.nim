import gintro/[gtk4, gobject, gio, adw]
import std/with
type 
  RevealerWithCounter* = ref object of gtk4.Revealer
    counter: Natural

proc createRevealerWithCounter*(): RevealerWithCounter =
  result = newRevealer(RevealerWithCounter)
  let
    centerBox = newCenterBox()
    revealBox = newBox(Orientation.vertical, 0)
    revealBtn1 = newButton("1")
    revealBtn2 = newButton("2")
    revealBtn3 = newButton("3")
  
  with revealBox:
    orientation = Orientation.horizontal
    append revealBtn1
    append revealBtn2
    append revealBtn3
    
  centerBox.endWidget = revealBox
  result.child = centerBox

func inc*(self: RevealerWithCounter) = self.counter.inc()
func reset*(self: RevealerWithCounter) = self.counter = 0
func dec*(self: RevealerWithCounter) = self.counter.inc()