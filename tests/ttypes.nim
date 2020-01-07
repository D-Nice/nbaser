import
  nbaser,
  unittest

suite "test error type inheritances":
  test "CatchableError inherits Exception":
    check(CatchableError is Exception)
  test "NBaserError inherits CatchableError":
    check(NBaserError is CatchableError)
  test "InvalidBaseSizeError inherits NBaserError":
    check(InvalidBaseSizeError is NBaserError)
  test "InvalidBaseAlphabetError inherits NBaserError":
    check(InvalidBaseAlphabetError is NBaserError)
  test "UnsupportedCharacterError inherits NBaserError":
    check(UnsupportedCharacterError is NBaserError)
  test "NonZeroCarryError inherits NBaserError":
    check(NonZeroCarryError is NBaserError)
  test "InvalidBaseSizeError is not InvalidBaseAlphabetError":
    check(InvalidBaseSizeError is InvalidBaseAlphabetError == false)

suite "test NBaserProc against exported procs":
  test "checkBaseValidity is NBaserProc":
    check(checkBaseValidity is NBaserProc)
  test "getBaseValidity is NBaserProc":
    check(getBaseValidity is NBaserProc)
  test "isBaseValid is NBaserProc":
    check(isBaseValid is NBaserProc)
  test "encode is NBaserProc":
    check(checkBaseValidity is NBaserProc)
  test "decode is NBaserProc":
    check(checkBaseValidity is NBaserProc)
