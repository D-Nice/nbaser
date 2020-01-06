import
  nbaser,
  strutils,
  sequtils,
  unittest,
  sugar,
  ../tests/utils

# Missing test for non-zero carry, as even the fuzzer was unable
# to trigger a crash or exception with it disabled.
# Consider it a fail-safe to notify users of what would
# likely yield malformed output if continued, due to
# whatever internal error it may have encountered.
# The perf difference appears minimal when benchmarking it.

type
  Fixture = object
    args: seq[string]
    msg: string
    err: ref Exception

template expectErrorMsg(
  fn: NBaserProc,
  f: Fixture
) =
  try:
    when fn is checkBaseValidity.type:
      fn(f.args[0])
    when fn is encode.type:
      discard fn(f.args[0], f.args[1].toSeqByte, true)
    when fn is decode.type:
      discard fn(f.args[0], f.args[1], true)
    fail()
  except NBaserError as e: # tests that all errors inherit NBaserError
    if f.err.name != e.name:
      false.doAssert("Unexpected error... expected " &
        $f.err.name & " got " & $e.name)
    if f.msg != e.msg:
      false.doAssert("Unexpected error msg... expected " &
        $f.msg & " got " & $e.msg)
  except Exception as e:
    false.doAssert("Unexpected error... got " & $e.name & " " & e.msg)

suite "test checkers":
  setup:
    const
      # passing case
      base2 = "01"
      # Invalid Base Size
      base1 = "X"
      fakeBase2 = "11"
      base257 = newSeqWith(256, '4').join & '2'
      # Unsupported Alphabet
      fakeBase3 = "110"
      # Unsupported Character
      base2utf8 = "0ف"

    const msg = [
      "minimum base size is 2",
      "maximum base size is 256",
      "alphabet must not have any char dupes",
    ]

    # EDIT THESE FOR TESTS
    var fixtures = [
      Fixture(
        args: @[base1],
        msg: msg[0],
        err: new(InvalidBaseSizeError)),
      Fixture(
        args: @[fakeBase2],
        msg: msg[0],
        err: new(InvalidBaseSizeError)),
      Fixture(
        args: @[base257],
        msg: msg[1],
        err: new(InvalidBaseSizeError)),
      Fixture(
        args: @[fakeBase3],
        msg: msg[2],
        err: new(InvalidBaseAlphabetError)),
      Fixture(
        args: @[base2, "012"],
        msg: "Char`2` is not one of the supported `01`",
        err: new(UnsupportedCharacterError)),
      Fixture(
        args: @[base2, "1ف0"],
        msg: "Char`ف` is not one of the supported `01`",
        err: new(UnsupportedCharacterError)),
      Fixture(
        args: @[base2, "ف01"],
        msg: "Char`ف` is not one of the supported `01`",
        err: new(UnsupportedCharacterError)),
      Fixture(
        args: @[base2utf8, "ف01"],
        msg: "Char`1` is not one of the supported `0ف`",
        err: new(UnsupportedCharacterError)),
      Fixture(
        args: @[base257],
        msg: msg[1],
        err: new(NonZeroCarryError)),
    ]

  test "passing checkBaseValidity case":
    try:
      base2.checkBaseValidity
    except NBaserError:
      fail()
    except:
      fail()

  const checkBaseFailTests = [
    "InvalidBaseSizeError",
    "InvalidBaseAlphabetError",
  ]

  for check in checkBaseFailTests:
    test "checkBaseValidity except " & check:
      for fixture in fixtures.filter(x => x.err.name == check):
        checkBaseValidity.expectErrorMsg(fixture)

  const check = "UnsupportedCharacterError"
  test "decode except " & check:
    for fixture in fixtures.filter(x => x.err.name == check):
      decode.expectErrorMsg(fixture)
