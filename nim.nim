import math

type X = "asd" or "qwe"

proc returnInt(b: int): int = 6

proc sas2(a: int) = echo a
proc sas3(a: proc(x: int): int) = echo 4

sas2(5.returnInt)


proc sas(nums: seq[int]): int =
  # gcd(nums.min, nums.max)
  sas2(nums.min)
  




