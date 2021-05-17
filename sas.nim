sumt:
  Name = sumtype:
    Kind1(string)
    Kind2(float)
    Kind3(char)

var s = Kind1("123")

matchSum s:
  Kind1(strVal):
    echo strVal

  Kind2(floatVal): echo floatVal
  Kind3(charVal): echo charVal