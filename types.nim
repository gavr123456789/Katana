import gintro/[gtk4, gobject, gio, adw]
import carousel_widget

type
  CustomData* = object
    carousel*: CarouselWithPaths
    path*: string

  PathAndNum* = tuple
    num: int
    path: string