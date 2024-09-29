
import std/unittest
# import std/sequtils

import poseidon2/types
import poseidon2/permutation

import ./permTestCases

#-------------------------------------------------------------------------------

const refInp: F12 = 
  [ toF(  0'u64 )
  , toF(  1'u64 )
  , toF(  2'u64 )
  , toF(  3'u64 )
  , toF(  4'u64 )
  , toF(  5'u64 )
  , toF(  6'u64 )
  , toF(  7'u64 )
  , toF(  8'u64 )
  , toF(  9'u64 )
  , toF( 10'u64 )
  , toF( 11'u64 )
  ]

const refOut: F12 = 
  [ toF( 0x01eaef96bdf1c0c1'u64 )
  , toF( 0x1f0d2cc525b2540c'u64 )
  , toF( 0x6282c1dfe1e0358d'u64 )
  , toF( 0xe780d721f698e1e6'u64 )
  , toF( 0x280c0b6f753d833b'u64 )
  , toF( 0x1b942dd5023156ab'u64 )
  , toF( 0x43f0df3fcccb8398'u64 )
  , toF( 0xe8e8190585489025'u64 )
  , toF( 0x56bdbf72f77ada22'u64 )
  , toF( 0x7911c32bf9dcd705'u64 )
  , toF( 0xec467926508fbe67'u64 )
  , toF( 0x6a50450ddf85a6ed'u64 )
  ]

#-------------------------------------------------------------------------------

suite "permutation":

  test "permutation of [0..11]":
    var input  = toState(refInp)
    var output = perm(input);
    check fromState(output) == refOut

  test "more permutation tests":
    var ok = true
    for (xs,ys) in testcases_perm:
      if permF12(xs) != ys: 
        ok = false
        break
    check ok
 
#-------------------------------------------------------------------------------

