
import std/unittest
# import std/sequtils

import goldilocks_hash/types
import goldilocks_hash/monolith/permutation

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
  [ toF( 0x516dd661e959f541'u64 )
  , toF( 0x082c137169707901'u64 )
  , toF( 0x53dff3fd9f0a5beb'u64 )
  , toF( 0x0b2ebaa261590650'u64 )
  , toF( 0x89aadb57e2969cb6'u64 )
  , toF( 0x5d3d6905970259bd'u64 )
  , toF( 0x6e5ac1a4c0cfa0fe'u64 )
  , toF( 0xd674b7736abfc5ce'u64 )
  , toF( 0x0d8697e1cd9a235f'u64 )
  , toF( 0x85fc4017c247136e'u64 )
  , toF( 0x572bafd76e511424'u64 )
  , toF( 0xbec1638e28eae57f'u64 )
  ]

#-------------------------------------------------------------------------------

suite "monolith permutation":

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

