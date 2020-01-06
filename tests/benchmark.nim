import random, times, nbaser, sequtils, unicode

{.
  checks: off,
  warnings: off,
  hints: off,
  optimization: speed,
  passC: "-march=native -O3 -flto -fno-strict-aliasing",
  passL: "-s -static"
.}

const FIXTURE_SIZE: int = 10_000
const MAX_BYTES: int = 48

proc gen(
  encodeFixtures: var array[FIXTURE_SIZE, seq[byte]],
  size: int
  ):
  void {.inline.} =

  var rng = initRand(74961379746663)

  for i in 0 .. encodeFixtures.high:
    encodeFixtures[i] = newSeqUninitialized[byte](size)
    for j in 0 .. encodeFixtures[i].high:
      encodeFixtures[i][j] = byte rng.next mod 256

proc benchmark(
  base: string,
  encodeFixtures: var array[FIXTURE_SIZE, seq[byte]],
  decodeFixtures: var array[FIXTURE_SIZE, string],
  loopTo: int = 500,
  useBytes: int = MAX_BYTES
  ):
  void {.inline.} =

  echo "base", base.runeLen, " ", useBytes, " bytes"

  encodeFixtures.gen(useBytes)

  # encode benchmark
  var t0 = epochTime()

  for i in 0 .. loopTo:
    {.unroll.}
    for fixture in encodeFixtures:
      {.unroll.}
      discard base.encode fixture

  var t1 = epochTime() - t0
  var opsPerSec = (encodeFixtures.len * loopTo).float / t1
  echo "  encode ", opsPerSec.int, " ops/s"

  # let's populate decodeFixtures using passed base's encode
  for i in 0 .. encodeFixtures.high:
    {.unroll.}
    decodeFixtures[i] = base.encode encodeFixtures[i]

  # decode benchmark
  t0 = epochTime()
  for i in 0 .. loopTo:
    {.unroll.}
    for fixture in decodeFixtures:
      {.unroll.}
      discard base.decode fixture

  t1 = epochTime() - t0
  opsPerSec = (encodeFixtures.len * loopTo).float / t1
  echo "  decode ", opsPerSec.int, " ops/s\n"

proc main =
  const base2 = "01"
  const base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  const base256 = "€™£¥©®¶¼½4ͶΛXΔΓΞΠΣΨΩ⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬"

  var encodeFixtures: array[FIXTURE_SIZE, seq[byte]]
  var decodeFixtures: array[FIXTURE_SIZE, string]

  echo "\nstarting benchmarks...\n"

  base58.benchmark(encodeFixtures, decodeFixtures, 40, (MAX_BYTES/3).int)
  base58.benchmark(encodeFixtures, decodeFixtures, 20, (MAX_BYTES/3*2).int)
  base58.benchmark(encodeFixtures, decodeFixtures, 5)
  base2.benchmark(encodeFixtures, decodeFixtures, 10, (MAX_BYTES/3).int)
  base2.benchmark(encodeFixtures, decodeFixtures, 5, (MAX_BYTES/3*2).int)
  base2.benchmark(encodeFixtures, decodeFixtures, 3)
  base256.benchmark(encodeFixtures, decodeFixtures, 40, (MAX_BYTES/3).int)
  base256.benchmark(encodeFixtures, decodeFixtures, 20, (MAX_BYTES/3*2).int)
  base256.benchmark(encodeFixtures, decodeFixtures, 5)

main()
