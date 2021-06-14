import gintro/[gtk4, gobject, gio, adw]


type
  CustomData* = object
    carousel*: Carousel
    path*: string

  PathAndNum* = tuple
    num: int
    path: string