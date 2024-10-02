
import std/unittest

import goldilocks_hash/types
import goldilocks_hash/monolith/compress

import ./compressTestCases

#-------------------------------------------------------------------------------

suite "monolith compression":

  test "compression of [1..4] and [5..8] with key=0":
    let input1 : Digest = toDigest(refInp1)
    let input2 : Digest = toDigest(refInp2)
    let output : Digest = compress(input1, input2)
    check ( fromDigest(output) == refOutKey0 )

  test "compression of [1..4] and [5..8] with key=1":
    let input1 : Digest = toDigest(refInp1)
    let input2 : Digest = toDigest(refInp2)
    let output : Digest = compress(input1, input2, key=1)
    check ( fromDigest(output) == refOutKey1 )

  test "compression of [1..4] and [5..8] with key=2":
    let input1 : Digest = toDigest(refInp1)
    let input2 : Digest = toDigest(refInp2)
    let output : Digest = compress(input1, input2, key=2)
    check ( fromDigest(output) == refOutKey2 )

  test "compression of [1..4] and [5..8] with key=3":
    let input1 : Digest = toDigest(refInp1)
    let input2 : Digest = toDigest(refInp2)
    let output : Digest = compress(input1, input2, key=3)
    check ( fromDigest(output) == refOutKey3 )

#-------------------------------------------------------------------------------

