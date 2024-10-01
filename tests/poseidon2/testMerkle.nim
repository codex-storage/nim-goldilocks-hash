
import std/unittest
# import std/sequtils

import poseidon2/types
import poseidon2/merkle

import ./merkleTestCases

#-------------------------------------------------------------------------------

func digestSeq(n: int): seq[Digest] = 
  var input : seq[Digest] = newSeq[Digest](n)
  for i in 0..<n: 
    let x = uint64(i+1)
    input[i] = mkDigestU64(x,0,0,0)
  return input

func isOkDigestNim( testcases: openarray[tuple[n:int,digest:F4]] ): bool =
  var ok = true
  for (n,refdigest) in testcases:
    let input : seq[Digest] = digestSeq(n)
    if merkleRoot(input) != toDigest(refdigest):
      ok = false
  return ok

suite "merkle/Nim":

  test "merkle root of digest sequences": check isOkDigestNim( testcases_merkleroot )
 
#-------------------------------------------------------------------------------
