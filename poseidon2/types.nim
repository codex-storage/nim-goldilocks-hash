
#-------------------------------------------------------------------------------

type F* = distinct uint64

func `==`* (x, y: F): bool =
  return (uint64(x) == uint64(y))

func fromF* (x: F): uint64 = 
  return uint64(x)

func toF* (x: uint64): F = 
  return F(x)

#-------------------------------------------------------------------------------

const zero* : F = toF(0)
const one*  : F = toF(1)
const two*  : F = toF(2)

#-------------------------------------------------------------------------------

type F4*  = array[4 , F]
type F12* = array[12, F]

type Digest* = distinct F4
type State*  = distinct F12

#-------------------------------------------------------------------------------
