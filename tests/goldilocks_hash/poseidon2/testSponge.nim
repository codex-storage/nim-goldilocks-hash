
import std/unittest
# import std/sequtils

import goldilocks_hash/types
import goldilocks_hash/poseidon2/sponge

import ./spongeTestCases

#-------------------------------------------------------------------------------

func byteSeq(n: int): seq[byte] = 
  var input : seq[byte] = newSeq[byte](n)
  for i in 0..<n: input[i] = byte(i+1)
  return input

func feltSeq(n: int): seq[F] = 
  var input : seq[F] = newSeq[F](n)
  for i in 0..<n: input[i] = toF(uint64(i+1))
  return input

#-------------------------------------------------------------------------------

func isOkFeltNim(r: static int, testcases: openarray[tuple[n:int,digest:F4]] ): bool =
  var ok = true
  for (n,refdigest) in testcases:
    let input : seq[F] = feltSeq(n)
    if digestNim(rate=r, input) != toDigest(refdigest):
      ok = false
  return ok

suite "poseidon2 sponge /Nim":

  test "sponge for field elements w/ rate = 1": check isOkFeltNim( 1 , testcases_field_rate1 )
  test "sponge for field elements w/ rate = 2": check isOkFeltNim( 2 , testcases_field_rate2 )
  test "sponge for field elements w/ rate = 3": check isOkFeltNim( 3 , testcases_field_rate3 )
  test "sponge for field elements w/ rate = 4": check isOkFeltNim( 4 , testcases_field_rate4 )
  test "sponge for field elements w/ rate = 5": check isOkFeltNim( 5 , testcases_field_rate5 )
  test "sponge for field elements w/ rate = 6": check isOkFeltNim( 6 , testcases_field_rate6 )
  test "sponge for field elements w/ rate = 7": check isOkFeltNim( 7 , testcases_field_rate7 )
  test "sponge for field elements w/ rate = 8": check isOkFeltNim( 8 , testcases_field_rate8 )
 
#-------------------------------------------------------------------------------

func isOkFeltC(r: static int, testcases: openarray[tuple[n:int,digest:F4]] ): bool =
  var ok = true
  for (n,refdigest) in testcases:
    let input : seq[F] = feltSeq(n)
    if digestFeltsC(rate=r, input) != toDigest(refdigest):
      ok = false
  return ok

func isOkBytesC(r: static int, testcases: openarray[tuple[n:int,digest:F4]] ): bool =
  var ok = true
  for (n,refdigest) in testcases:
    let input : seq[byte] = byteSeq(n)
    if digestBytesC(rate=r, input) != toDigest(refdigest):
      ok = false
  return ok

suite "poseidon2 sponge /C":

  test "sponge for field elements w/ rate = 1": check isOkFeltC( 1 , testcases_field_rate1 )
  test "sponge for field elements w/ rate = 2": check isOkFeltC( 2 , testcases_field_rate2 )
  test "sponge for field elements w/ rate = 3": check isOkFeltC( 3 , testcases_field_rate3 )
  test "sponge for field elements w/ rate = 4": check isOkFeltC( 4 , testcases_field_rate4 )
  test "sponge for field elements w/ rate = 5": check isOkFeltC( 5 , testcases_field_rate5 )
  test "sponge for field elements w/ rate = 6": check isOkFeltC( 6 , testcases_field_rate6 )
  test "sponge for field elements w/ rate = 7": check isOkFeltC( 7 , testcases_field_rate7 )
  test "sponge for field elements w/ rate = 8": check isOkFeltC( 8 , testcases_field_rate8 )

  test "sponge for bytes w/ rate = 4": check isOkBytesC( 4 , testcases_bytes_rate4 )
  test "sponge for bytes w/ rate = 8": check isOkBytesC( 8 , testcases_bytes_rate8 )
 
#-------------------------------------------------------------------------------

