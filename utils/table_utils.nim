import tables

type ListTable[K,V] = Table[K, seq[V]] or TableRef[K, seq[V]]

func `[]=`*(table: var ListTable, key: auto, value: auto) =
  if table.hasKeyOrPut(key, @[value]):
    table[key].add value

