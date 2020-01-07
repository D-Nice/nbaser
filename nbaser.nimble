
# Package
version       = "1.0.0"
author        = "D-Nice"
description   = "Encoder/decoder for any base alphabet up to 256 with leading zero compression"
license       = "MIT"
srcDir        = "src"

# Dependencies
requires "nim >= 1.0.0"


# Nimscript Tasks
import sugar, sequtils, strutils


func srcPaths: seq[string] =
  const dirs =
    @[
      "src/"
    ]

  for dir in dirs:
    result.add(dir.listFiles.filter(x => x[dir.len .. x.high].endsWith(".nim")))

func testPaths: seq[string] =
  const dir = "tests/"
  return dir.listFiles.filter(x => x[dir.len .. x.high].startsWith('t'))

## docs
task docgen, "Generate documentation":
  exec "nim doc2 src/nbaser.nim"

## checks
const checkCmd = "nim c -cf -w:on --hints:on -o:/dev/null --styleCheck:"
task check_src, "Compile src with all checks on":
  for src in srcPaths():
    exec checkCmd & "error " & src
task check_tests, "Compile tests with all checks on":
  for test in testPaths():
    exec checkCmd & "hint " & test
task check_all, "Compile check everything and run tests":
  exec "nimble check_src; nimble check_tests; nimble test -c"

## benching
task benchmark, "Runs built-in benchmark":
  exec "nim c -f --verbosity:0 --hints:off -d:danger --gc:markAndSweep -o:/tmp/nim/nbaser/bench -r tests/benchmark.nim"

## fuzzing
task fuzz_decoder, "Runs afl on decoder":
  exec "nim c -f -o:/tmp/nim/nbaser/decoder tests/fuzzer/decoder.nim && afl-fuzz -t 10 -T \"NBaser Decoder fuzzing\" -i tests/fuzzer/in-decoder/ -o tests/fuzzer/out-decoder/ /tmp/nim/nbaser/decoder"
task fuzz_encoder, "Runs afl on encoder":
  exec "nim c -f -o:/tmp/nim/nbaser/encoder tests/fuzzer/encoder.nim && afl-fuzz -t 10 -T \"NBaser Encoder fuzzing\" -i tests/fuzzer/in-encoder/ -o tests/fuzzer/out-encoder/ /tmp/nim/nbaser/encoder"
