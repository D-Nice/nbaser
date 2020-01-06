import sequtils, math, unicode

## Allows for efficient encoding and decoding of bases with the full unicode
## character set. Supporting bases 2 up to 256 in length.
##
## This makes it an interesting base generator for specific locales, and space efficient in terms of character length by allowing up to base256 with any UTF-8 characters of your choosing.
##
## **NOTES**:
##
## This will not encode/decode bases such as standard base32/base64 with padding and instead utilizes bitcoin style leading zero compression.
##
## Proceed with caution utilizing any unprintable unicode characters.
##
## The unicode support does slow this implementation down by an order of magnitude than if it just supported ASCII.
##

type
  NBaserError* = object of CatchableError
    ## Catchable error arising from nbaser module.

type
  InvalidBaseSizeError* {.final.} = object of NBaserError
    ## Base size is not between 2 and 256 inclusive.
  InvalidBaseAlphabetError* {.final.} = object of NBaserError
    ## Base has duplicate characters which can cause unexpected behaviour.
  UnsupportedCharacterError* {.final.} = object of NBaserError
    ## A character not part of the base was detected.
  NonZeroCarryError* {.final.} = object of NBaserError
    ## Failed to achieve a non-zero carry during encoding/decoding.

type
  NBaserProc* =
    # checkBaseValidity
    proc(a: string) {.inline noSideEffect.} |
    # getBaseValidity
    proc(a: string): (bool, string) {.inline.} |
    # isBaseValid
    proc(a: string): bool {.inline.} |
    # encode
    proc(a: string, b: openArray[byte], c: bool = false): string {.inline.} |
    # decode
    proc(a, b: string, c: bool = false): seq[byte] {.inline.}
    ## Type for any exported nbaser functions


# for easily running some checks and raising exception if they are not met.
template ensure(
  condition: bool,
  errorMsg: string,
  exception: type Exception
) =
  if unlikely condition == false:
    raise exception.newException errorMsg

func setupBaseVars(baseAlphabet: string):
  tuple[base: int, leader: Rune] {.inline.} =

  result.base = baseAlphabet.runeLen
  result.leader = baseAlphabet.runeAtPos(0)

func checkBaseValidity*(baseAlphabet: string):
  void {.inline
  raises: [NBaserError].} =
  ## Runs sanity checks on the passed `baseAlphabet`.
  ##
  ## Raises a NBaserError (one of InvalidBaseSizeError or
  ## InvalidBaseAlphabetError).

  runnableExamples:
    try:
      checkBaseValidity("0")
      doAssert(false, "should never reach this")
    except: # could catch specific exception, NBaserError or InvalidBaseAlphabetError
      discard # handle exception here

  # convert to runes for unicode support
  let deduped = $baseAlphabet.toRunes.deduplicate
  # we wish to count characters and not byte size
  # so we use unicode.runLen instead of len
  ensure (deduped.runeLen >= 2),
    "minimum base size is 2",
    InvalidBaseSizeError

  ensure (baseAlphabet.runeLen <= 256),
    "maximum base size is 256",
    InvalidBaseSizeError

  ensure (deduped == baseAlphabet),
    "alphabet must not have any char dupes",
    InvalidBaseAlphabetError

func getBaseValidity*(baseAlphabet: string):
  (bool, string) {.inline.} =
  ## Runs sanity checks on the passed `baseAlphabet`.
  ##
  ## Returns a tuple containing a boolean indicating the validity (true
  ## for valid, false for invalid), and exception message if available.

  runnableExamples:
    doAssert getBaseValidity("") == (false, "minimum base size is 2")
    doAssert getBaseValidity("0") == (false, "minimum base size is 2")
    doAssert getBaseValidity("010") == (false, "alphabet must not have any char dupes")
    doAssert getBaseValidity("01") == (true, "")
    var unicode256Char = "šŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƀƁƂƃƄƅƆƇƈƉƊƋƌƍƎƏƐƑƒ"
    unicode256Char &= "ƓƔƕƖƗƘƙƚƛƜƝƞƟƠơƢƣƤƥƦƧƨƩƪƫƬƭƮƯưƱƲƳƴƵƶƷƸƹƺƻƼƽƾƿǀǁǂǃǄǅǆ"
    unicode256Char &= "ǇǈǉǊǋǌǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǟǠǡǢǣǤǥǦǧǨǩǪǫǬǭǮǯǰǱǲǳǴǵǶǷǸǹǺǻǼ"
    unicode256Char &= "ǽǾǿȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȜȝȞȟȠȡȢȣȤȥφχψωϊϋόύώϐϑϒϓϔ"
    unicode256Char &= "ϕϖϗϘϙϚϛϜϝϞϟϠϡϢϣϤϥϦϧϨϩϪϫϬϭϮϯϰϱϲϳϴϵ϶ϷϸϹϺϻϼϽϾϿЀЁ"
    doAssert getBaseValidity(unicode256Char) == (true, "")
    doAssert getBaseValidity(unicode256Char & 'X') == (false, "maximum base size is 256")
    doAssert getBaseValidity("abcdefABCDEF01~.,") == (true, "")

  try:
    baseAlphabet.checkBaseValidity
  except Exception as e:
    return (false, e.msg)
  return (true, "")

func isBaseValid*(baseAlphabet: string):
  bool {.inline.} =
  ## Functional alias of `getBaseValidity <#getBaseValidity,string,bool>`_.
  ## Omits fetching of exception message.
  ## Should be run before any base switch,
  ## in case of using default encode/decode functions which omit the base check.
  ## Singular check using this on a change will be more efficient.
  ##
  ## Returns a boolean indicating true for valid and false for invalid.

  runnableExamples:
    doAssert isBaseValid("") == false
    doAssert isBaseValid("0") == false
    doAssert isBaseValid("010") == false
    doAssert isBaseValid("01") == true
    var unicode256Chars = "šŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƀƁƂƃƄƅƆƇƈƉƊƋƌƍƎƏƐƑƒ"
    unicode256Chars &= "ƓƔƕƖƗƘƙƚƛƜƝƞƟƠơƢƣƤƥƦƧƨƩƪƫƬƭƮƯưƱƲƳƴƵƶƷƸƹƺƻƼƽƾƿǀǁǂǃǄǅǆ"
    unicode256Chars &= "ǇǈǉǊǋǌǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǟǠǡǢǣǤǥǦǧǨǩǪǫǬǭǮǯǰǱǲǳǴǵǶǷǸǹǺǻǼ"
    unicode256Chars &= "ǽǾǿȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȜȝȞȟȠȡȢȣȤȥφχψωϊϋόύώϐϑϒϓϔ"
    unicode256Chars &= "ϕϖϗϘϙϚϛϜϝϞϟϠϡϢϣϤϥϦϧϨϩϪϫϬϭϮϯϰϱϲϳϴϵ϶ϷϸϹϺϻϼϽϾϿЀЁ"
    doAssert isBaseValid(unicode256Chars) == true
    doAssert isBaseValid("𓊽𓊸") == true
    let unicode257Chars = unicode256Chars & 'X'
    doAssert isBaseValid(unicode257Chars) == false
    doAssert isBaseValid("abcdefABCDEF01~.,") == true

  try:
    baseAlphabet.checkBaseValidity
  except:
    return false
  return true

func encode*(
  baseAlphabet: string,
  src: openArray[byte],
  checkBase: bool = false):
  string {.inline,
  raises: [NBaserError].} =
  ## Takes a `baseAlphabet` string to convert `src` bytes into the
  ## representative string for the base passed.
  ##
  ## Accepts optional `checkBase` bool which is off by default, on whether
  ## to run a sanity check on the base before hand (recommended on in
  ## case of user input or sanitize the base first using another func/proc
  ## if calling encode multiple times with same base for efficiency).
  ##
  ## Returns a string of the result.
  ##
  ## Throws a `NBaserError <#NBaserError>`_ on exception.

  runnableExamples:
    import unittest
    const
      base2 = "01"
      base32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
      base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    doAssert base2.encode(@[byte 255]) == "11111111"
    doAssert base2.encode(@[byte 254]) == "11111110"
    doAssert base2.encode(@[byte 0, 1]) == "01"
    doAssert base2.encode(@[byte 1, 0]) == "100000000"
    doAssert base32.encode(@[byte 0, 0]) == "AA"
    doAssert base32.encode(@[byte 0, 1]) == "AB"
    doAssert base32.encode(@[byte 0, 1, 0]) == "AIA"
    doAssert base58.encode(@[byte 0, 1, 2, 3, 4, 5]) == "17bWpTW"
    doAssert base58.encode(@[byte 0, 0, 0, 255]) == "1115Q"

    const invalidBase = "0102"
    expect NBaserError:
      discard invalidBase.encode(@[byte 0], true)
    expect InvalidBaseAlphabetError:
      discard invalidBase.encode(@[byte 0], true)

  if unlikely src.len == 0:
    return ""

  if unlikely checkBase:
    baseAlphabet.checkBaseValidity

  let (base, leader) = baseAlphabet.setupBaseVars
  let ifactor: float = 256.float.ln.static / base.float.ln

  var ldrCtr = 0

  while likely ldrCtr < src.len and
    unlikely src[ldrCtr] == 0:
    inc ldrCtr

  let size = ((src.len - ldrCtr).float * ifactor).ceil.int
  # let's provide sufficient capacity for our result
  result = newStringOfCap(size)
  result.shallow
  var bx = newSeq[byte](size)

  # convert b256 array to nbaser
  var length = 0
  for i in ldrCtr ..< src.len:
    var (carry, y, z) = (src[i].int, 0, bx.high)

    while likely carry > 0 or
      likely y < length and likely z != -1:
      carry += bx[z].int.shl 8
      bx[z] = carry.mod(base).byte
      carry = carry.div base
      inc y
      dec z

    ensure (carry == 0),
      "non-zero carry left over",
      NonZeroCarryError

    length = y

  # remove unused/overcompensated byte slots
  while (likely bx.len > 0 and unlikely bx[0] == 0):
    bx.delete 0

  # prepend any leaders and allocate null chars
  # optimized ascii-only
  #result = result & leader.repeat(ldrCtr) & newString(bx.len)
  result = result & leader.repeat(ldrCtr)

  # turn nbaser bytearray into corresponding chars in result string
  # optimized ascii-only
#  var l = ldrCtr
#  for b in bx:
#    result[l] = baseAlphabet[b.int]
#    inc l
  let runeAlphabetSeq = baseAlphabet.toRunes
  for b in bx:
    result.add(runeAlphabetSeq[b.int])

func decode* (
  baseAlphabet: string,
  src: string,
  checkBase: bool = false):
  seq[byte] {.inline
  raises: [NBaserError].} =
  ## Takes a `baseAlphabet` string to convert `src` string into representative
  ## bytes from the base.
  ## Accepts optional `checkBase` bool which is off by default, on whether
  ## to run a sanity check on the base provided.
  ##
  ## Returns a sequence of bytes as the result.
  ##
  ## Raises a `NBaserError <#NBaserError>`_ on internal exception.

  runnableExamples:
    import unittest
    const
      base2 = "01"
      base32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
      base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    doAssert base2.decode("11111111") == @[byte 255]
    doAssert base2.decode("11111110") == @[byte 254]
    doAssert base2.decode("01") == @[byte 0, 1]
    doAssert base2.decode("100000000") == @[byte 1, 0]
    doAssert base32.decode("AA") == @[byte 0, 0]
    doAssert base32.decode("AB") == @[byte 0, 1]
    doAssert base32.decode("AIA") == @[byte 0, 1, 0]
    doAssert base58.decode("17bWpTW") == @[byte 0, 1, 2, 3, 4, 5]
    doAssert base58.decode("1115Q") == @[byte 0, 0, 0, 255]
    const invalidBase = "0102"
    expect NBaserError:
      discard invalidBase.decode("0", true)
    expect InvalidBaseAlphabetError:
      discard invalidBase.decode("0", true)

  if unlikely src.runeLen == 0:
    return newSeq[byte](0)

  var ldrCtr = 0
  var length = 0

  # dupe check skipped for performance/flexibility reasons
  if unlikely checkBase:
    baseAlphabet.checkBaseValidity

  let (base, leader) = baseAlphabet.setupBaseVars
  let factor: float = base.float.ln / 256.float.ln.static

  while likely ldrCtr < src.runeLen and
    unlikely src.runeAtPos(ldrCtr) == leader:
    inc ldrCtr

  let size = ((src.runeLen - ldrCtr).float * factor).ceil.int
  var b256 = newSeq[byte](size)
  b256.shallow

  for i in ldrCtr ..< src.runeLen:
    # lets refer to rune as unicode char here
    let uchar = src.runeAtPos(i)
    # TODO consider binary search?
    var carry = baseAlphabet.toRunes.find uchar
    ensure carry >= 0,
      "Char`" & $uchar & "` is not one of the supported `" & baseAlphabet & "`",
      UnsupportedCharacterError

    var y = 0
    var z = b256.high

    while likely carry != 0 or
      likely y < length and likely z != -1:
      carry += b256[z].int * base
      b256[z] = carry.mod(256).byte
      carry = carry.div 256
      inc y
      dec z

    ensure (carry == 0),
      "Non-zero carry leftover",
      NonZeroCarryError

    length = y

  # remove any slot overcompensation
  while (likely b256.len > 0 and unlikely b256[0] == 0):
    b256.delete 0

  # prepend any leaders
  b256.insert newSeq[byte](ldrCtr)
  result = b256
