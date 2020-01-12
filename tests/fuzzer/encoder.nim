import
  nbaser,
  ../tests/utils,
  strutils,
  terminal

{.
  checks: off,
  warnings: off,
  hints: off,
  optimization: speed,
  define: danger,
  passC: "-march=native -Ofast",
.}

proc main(): void =
  var alpha = newStringOfCap(256)
  var input = newStringOfCap(1024)
  var encoded: string
  alpha.shallow
  input.shallow

  if stdin.isatty:
    quit 1

  input = stdin.readAll
  # rm EOL chars LF or CR
  input.removeSuffix("\n")
  input.removeSuffix("\r")

  let args = input.split(" ", 1)
  if (args.len <= 1):
    quit 1
  alpha = args[0]
  input = args[1]

  # safe way to run lib
  # should check any new alphabet
  # can use get if preferable to exception
  if getBaseValidity(alpha)[0] == false:
    quit 1

  encoded = alpha.encode(input.castToSeqByte)

main()
