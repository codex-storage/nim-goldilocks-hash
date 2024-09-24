
import std/unittest
# import std/sequtils

import poseidon2/types
import poseidon2/compress

#-------------------------------------------------------------------------------

const refInp1: array[4,F] = 
  [ toF( 1'u64 )
  , toF( 2'u64 )
  , toF( 3'u64 )
  , toF( 4'u64 )
  ]

const refInp2: array[4,F] =  
  [ toF( 5'u64 )
  , toF( 6'u64 )
  , toF( 7'u64 )
  , toF( 8'u64 )
  ]

#---------------------------------------

const refOutKey0: array[4,F] =  
  [ toF( 0xc4a4082f411ba790'u64 )
  , toF( 0x98c2ed7546c44cce'u64 )
  , toF( 0xc9404f373b78c979'u64 )
  , toF( 0x65d6b3c998920f59'u64 )
  ]

const refOutKey1: array[4,F] =  
  [ toF( 0xca47449a05283778'u64 )
  , toF( 0x08d3ced2020391ac'u64 )
  , toF( 0xda461ea45670fb12'u64 )
  , toF( 0x57f2c0b6c98a05c5'u64 )
  ]

const refOutKey2: array[4,F] =  
  [ toF( 0xe6fcec96a7a7f4b0'u64 )
  , toF( 0x3002a22356daa551'u64 )
  , toF( 0x899e2c1075a45f3f'u64 )
  , toF( 0xf07e38ccb3ade312'u64 )
  ]

const refOutKey3: array[4,F] =  
  [ toF( 0x9930cff752b046fb'u64 )
  , toF( 0x41570687cadcea0b'u64 )
  , toF( 0x3ac093a5a92066c7'u64 )
  , toF( 0xc45c75a3911cde87'u64 )
  ]

#-------------------------------------------------------------------------------

suite "compression":

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

