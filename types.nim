import gintro/[gtk4, gobject, gio, adw]

type
  PathAndNum* = tuple
    num: int
    path: string

type
  NumAndListView* = tuple
    num: int
    lv: ListView