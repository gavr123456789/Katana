import gintro/[gtk4, gobject, gio]


type 
  BoxWithProgressBarReveal* = ref object of Box
    revealer*: Revealer

proc createBoxWithProgressBarReveal*(revealOpened: bool): BoxWithProgressBarReveal = 
  result = newBox(BoxWithProgressBarReveal, Orientation.vertical, 0)
  let
    reveal = newRevealer() 
    progressBar = newProgressBar()
  progressBar.fraction = 1.0
  
  result.revealer = reveal
  reveal.transitionType = RevealerTransitionType.swingUp
  reveal.transitionDuration = 200
  reveal.revealChild = revealOpened
  reveal.setChild progressBar
  result.append reveal

  result.vexpand = true

func `showProgressBar=`*(self: BoxWithProgressBarReveal, revealChild: bool) = 
  self.revealer.revealChild = revealChild