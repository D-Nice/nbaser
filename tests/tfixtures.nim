import
  nbaser,
  json,
  strutils,
  unittest,
  ../tests/utils

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
