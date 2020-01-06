# nbaser

### benchmarks

OUTDATED ASCII(old non-unicode version) benchmarks

on i5-82xx @ 3.9 GHz
nim v0.20.0

base58 32 bytes
  encode 612566 ops/s
  decode 1365126 ops/s

base2 32 bytes
  encode 18773 ops/s
  decode 59958 ops/s

base58 32 bytes
  encode 636264 ops/s
  decode 1330023 ops/s

base2 32 bytes
  encode 232449 ops/s
  decode 76536 ops/s

base58 32 bytes
  encode 611436 ops/s
  decode 1280487 ops/s

base2 32 bytes
  encode 218686 ops/s
  decode 73879 ops/s

### TODO

- [x] make unicode compatible version
- [ ] read raw binary data for the encoder fuzz entrypoint
- [ ] test performance increase if doing binary search on base lookup table
- [ ] consider making the table static/predefinining baseAlphabet.toRunes
outside of the loop (presuming backend or compiler already optimize this)
- [ ] implement code coverage once a non-obtrusive one becomes available for Nim
