
# Package
version       = "1.0.1"
author        = "D-Nice"
description   = "Encoder/decoder for any base alphabet up to 256 with leading zero compression"
license       = "Apache-2.0"
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
task docs, "Deploy doc html + search index to public/ directory":
  let
    deployDir = projectDir() & "/public/"
    docOutBaseName = "index"
    deployHtmlFile = deployDir & docOutBaseName & ".html"
    gitUrl = "https://github.com/D-Nice/nbaser"
    genDocCmd = "nim doc --out:$1 --index:on --git.url:$2 $3" % [deployHtmlFile, gitUrl, srcPaths()[0]]
    genTheIndexCmd = "nim buildIndex -o:$1/theindex.html $1" % [deployDir]
    deployJsFile = deployDir & "dochack.js"
    docHackJsSource = "https://nim-lang.github.io/Nim/dochack.js" # devel docs dochack.js
  mkDir(deployDir)
  exec(genDocCmd)
  exec(genTheIndexCmd)
  if not fileExists(deployJsFile):
    withDir deployDir:
      exec("curl -LO " & docHackJsSource)

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
  exec "nim c -f -o:/tmp/nim/nbaser/decoder tests/fuzzer/decoder.nim && afl-fuzz -T \"NBaser Decoder fuzzing\" -i tests/fuzzer/in-decoder -o tests/fuzzer/out-decoder /tmp/nim/nbaser/decoder"
task fuzz_encoder, "Runs afl on encoder":
  exec "nim c -f -o:/tmp/nim/nbaser/encoder tests/fuzzer/encoder.nim && afl-fuzz -T \"NBaser Encoder fuzzing\" -i tests/fuzzer/in-encoder -o tests/fuzzer/out-encoder /tmp/nim/nbaser/encoder"
