
import std/unittest
# import std/sequtils

import poseidon2/types
import poseidon2/goldilocks

import ./fieldTestCases

#-------------------------------------------------------------------------------

suite "field":

  test "negation":
    var ok = true
    for (x0,y0) in testcases_neg:
      let x = toF(x0)
      let y = toF(y0)
      if neg(x) != y: 
        ok = false
        break
    check ok
    
  test "addition":
    var ok = true
    for (x0,y0,z0) in testcases_add:
      let x = toF(x0)
      let y = toF(y0)
      let z = toF(z0)
      if x + y != z: 
        ok = false
        break
    check ok

  test "subtraction":
    var ok = true
    for (x0,y0,z0) in testcases_sub:
      let x = toF(x0)
      let y = toF(y0)
      let z = toF(z0)
      if x - y != z: 
        ok = false
        break
    check ok

  test "multiplication":
    var ok = true
    for (x0,y0,z0) in testcases_mul:
      let x = toF(x0)
      let y = toF(y0)
      let z = toF(z0)
      if x * y != z: 
        ok = false
        break
    check ok

#-------------------------------------------------------------------------------

