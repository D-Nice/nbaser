import
  nbaser,
  strutils,
  terminal

proc main(): void =
  var alpha = newStringOfCap(256)
  var input = newStringOfCap(1024)
  var decoded = newSeqOfCap[byte](1024)
  alpha.shallow
  input.shallow
  decoded.shallow

  if stdin.isatty:
    quit 1

  input.removeSuffix("\n")
  input = stdin.readAll

  let args = input.split(" ", 1)
  if (args.len <= 1):
    quit 1
  alpha = args[0]
  input = args[1]

  # safe way to run lib
  try:
    # should check any new alphabet
    # can use get if preferable to exception
    checkBaseValidity(alpha)
  except BaseXError:
    quit 1

  decoded = alpha.decode(input)

main()
