import gintro/[gtk4, gobject, gio, pango, glib, adw]

type 
  DirOrFile = enum
    file
    dir


type
  Row* = ref object of Box
    btn1*: ToggleButton
    btn2*: ToggleButton
    image*: Image
    labelFileName*: Label
    kind*: DirOrFile

proc `iconName=`*(self: Row, iconName: string) =
  self.image.setFromIconName(iconName)