import nbaser,
  random,
  sequtils,
  unittest

{.
  checks: off,
  hints: off,
  warnings: off,
  optimization: speed
.}

const fixtureLength = 5
var rng = initRand(8404281593283)
const baseFixtures = [
  "01",
  "01234567",
  "0123456789a",
  "0123456789abcdef",
  "0123456789ABCDEFGHJKMNPQRSTVWXYZ",
  "ybndrfg8ejkmcpqxot1uwisza345h769",
  "0123456789abcdefghijklmnopqrstuvwxyz",
  "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz",
  "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~",
  "ʰʱʲʳʴʵʸʹʺʻʼʽʾʿˀˁ˂˅ˆˇˈˉˊˋˌˍˎˏːˑ˒˗˘˙˚˛˜˝˞˟ˠˡˢˣˤ˥˦˪˫ˬ˭ˮ˯˰˱˲˳˴˵˶˷˸˹˺˻˼˽˾ᾦ‽ةך",
  "ກຂຄງຈຊຍດຕຖທນບປຜຝພຟມຢຣລວສຫອຮຯະັາຳິີຶືຸູົຼຽເແໂໃໄໆ່້໊໋໌ໍ໐໑໒໓໔໕໖໗໘໙ໜໝ"
]
var encodeFixtures: array[fixtureLength, seq[byte]]
var decodeFixtures: array[baseFixtures.len, array[fixtureLength, string]]

proc encodeDecode(base: string, i: int): seq[byte] =
  let encoded = base.encode(encodeFixtures[i])
  let baseIdx = baseFixtures.find(base)
  decodeFixtures[baseIdx][i] = encoded
  result = base.decode(encoded)

proc decodeEncode(base: string, i: int): string =
  let baseIdx = baseFixtures.find(base)
  let decoded = base.decode(decodeFixtures[baseIdx][i])
  result = base.encode(decoded)

suite "test for input/output convertibility between encode/decode":
  setup:
    for i in 0 .. encodeFixtures.high:
      let thisLen = max(i.uint8, 1)
      encodeFixtures[i] = newSeq[byte](thisLen)
      for j in 0 .. encodeFixtures[i].high:
        encodeFixtures[i][j] = rng.next.byte

  test "check encode <-> decode reversibility":
    for b in baseFixtures:
      for i in 0 .. encodeFixtures.high:
        check (b.encodeDecode(i) == encodeFixtures[i])

  test "check decode <-> encode reversibility":
    for b in baseFixtures:
      let baseIdx = baseFixtures.find(b)
      for i in 0 .. encodeFixtures.high:
        check (b.decodeEncode(i) == decodeFixtures[baseIdx][i])
