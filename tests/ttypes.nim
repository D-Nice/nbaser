import
  nbaser,
  unittest

suite "test error type inheritances":
  test "CatchableError inherits Exception":
    require(CatchableError is Exception)
  test "NBaserError inherits CatchableError":
    require(NBaserError is CatchableError)
  test "InvalidBaseSizeError inherits NBaserError":
    require(InvalidBaseSizeError is NBaserError)
  test "InvalidBaseAlphabetError inherits NBaserError":
    require(InvalidBaseAlphabetError is NBaserError)
  test "UnsupportedCharacterError inherits NBaserError":
    require(UnsupportedCharacterError is NBaserError)
  test "NonZeroCarryError inherits NBaserError":
    require(NonZeroCarryError is NBaserError)
  test "InvalidBaseSizeError is not InvalidBaseAlphabetError":
    require(InvalidBaseSizeError is InvalidBaseAlphabetError == false)

suite "test NBaserProc against exported procs":
  test "checkBaseValidity is NBaserProc":
    require(checkBaseValidity is NBaserProc)
  test "getBaseValidity is NBaserProc":
    require(getBaseValidity is NBaserProc)
  test "isBaseValid is NBaserProc":
    require(isBaseValid is NBaserProc)
  test "encode is NBaserProc":
    require(checkBaseValidity is NBaserProc)
  test "decode is NBaserProc":
    require(checkBaseValidity is NBaserProc)
