import strutils

var 
  vertical_direction = 0
  horizontal_direction = 0

for line in "input.txt".readFile.splitlines:
  let
    line_parts = line.split " "
    direction = line_parts[0]
    magnitude = parseInt line_parts[1]

  vertical_direction += (case direction:
  of "up": -magnitude
  of "down": magnitude
  else: 0)

  horizontal_direction += (case direction:
  of "forward": magnitude
  else: 0)

echo horizontal_direction * vertical_direction


