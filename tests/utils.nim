import
  sequtils,
  strutils

converter castToSeqByte*(s: string): seq[byte] = cast[seq[byte]](s)

# convert byteSeq to hexString
func toHex*(ba: openArray[byte]): string =
  result = foldl(ba, a & b.toHex, "")

# convert string char to byte
func toByte*(s: string, i: int): byte =
  const hexMap = "0123456789abcdef"
  result = (hexMap.find(s[i]).shl(4) + hexMap.find(s[i + 1])).byte

# convert hex string to byte sequence
func fromHexToBytes*(src: string): seq[byte] =
  var s = src
  if s.len mod 2 != 0:
    s.insert "0"

  result = newSeq[byte](int s.len / 2)

  for i in 0..result.high:
    result[i] = s.toByte(i * 2)
