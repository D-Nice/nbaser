import nbaser,
  json,
  strutils,
  sequtils,
  math,
  unittest,
  ../tests/utils

# convert byteSeq to hexString
func toHex(ba: openArray[byte]): string =
  result = foldl(ba, a & b.toHex, "")

# TODO leave for initial commit but remove thereafter
func toBytesOld(s: string): seq[byte] =
  result = newSeq[byte]((s.len / 2).ceil.int)
  var i = result.len - 1
  var evenOffset, oddOffset: int
  if (i*2+1) < s.len:
    evenOffset = 1
  else:
    oddOffset = 1

  while i >= 0:
    debugEcho i
    result[i] = (s[i*2 - oddOffset] & s[i*2 + evenOffset]).parseHexInt.byte
    i.dec

func toByte(s: string, i: int): byte =
  const hexMap = "0123456789abcdef"
  result = (hexMap.find(s[i]).shl(4) + hexMap.find(s[i + 1])).byte

# convert hex string to byte sequence
func fromHexToBytes(src: string): seq[byte] =
  var s = src
  if s.len mod 2 != 0:
    s.insert "0"

  result = newSeq[byte](int s.len / 2)

  for i in 0..result.high:
    result[i] = s.toByte(i * 2)

suite "test against cryptocoinjs fixtures":
  setup:
    let fixtures = "./tests/fixtures/cryptocoinjs.json".readFile
    let jsonNode = fixtures.parseJson
    let alphabetFixtures = jsonNode["alphabets"]
    let validFixtures = jsonNode["valid"]
    let invalidFixtures = jsonNode["invalid"]

  test "decode valid fixtures":
    for test in validFixtures:
      let base = test["alphabet"].getStr
      let baseAlphabet = alphabetFixtures[base].getStr
      let expected = test["hex"].getStr
      # decode op
      let res = baseAlphabet.decode test["string"].getStr
      let hexRes = res.toHex.toLowerAscii
      check hexRes == expected

  test "encode valid fixtures":
    for test in validFixtures:
      let base = test["alphabet"].getStr
      let baseAlphabet = alphabetFixtures[base].getStr
      let expected = test["string"].getStr
      let hex = test["hex"].getStr
      # encode op
      let res = baseAlphabet.encode hex.fromHexToBytes
      check res == expected

  test "decode invalid fixtures":
    for test in invalidFixtures:
      let expected = test["exception"].getStr
      # no need to test, enforced by compiler
      if expected.contains "Expected String":
        continue

      let base = test["alphabet"].getStr
      var baseAlphabet: string
      try:
        # if base is not one of the defined ones
        baseAlphabet = alphabetFixtures[base].getStr
      except:
        # assume a raw base is being sent and interpret as such
        baseAlphabet = base

        check baseAlphabet.isBaseValid == false
        check baseAlphabet.getBaseValidity ==
          (false, "alphabet must not have any char dupes")
        expect NBaserError:
          # with `checkBase` enabled for the decode, it
          # should throw an error.
          discard baseAlphabet.decode("deadbeef12340feeb", true)
        continue

      expect NBaserError:
        discard baseAlphabet.decode test["string"].getStr
      continue
