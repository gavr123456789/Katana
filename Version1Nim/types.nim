import gintro/[gtk4]

type
  PathAndNum* = tuple
    num: int
    path: string

type
  NumAndListView* = tuple
    num: int
    lv: ListView