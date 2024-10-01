
import std/strformat

#-------------------------------------------------------------------------------

type F* = distinct uint64

func fromF* (x: F): uint64 = return uint64(x)
func toF*   (x: uint64): F = return F(x)

func `==`* (x, y: F): bool =  return (uint64(x) == uint64(y))

func uint64ToHex* (x: uint64): string = fmt"{x:#016x}"

proc `$`*(x: F): string = return uint64ToHex(fromF(x))

#-------------------------------------------------------------------------------

const zero* : F = toF(0)
const one*  : F = toF(1)
const two*  : F = toF(2)

#-------------------------------------------------------------------------------

type F4*  = array[4 , F]
type F12* = array[12, F]

type Digest* = distinct F4
type State*  = distinct F12

func fromDigest* (x : Digest): F4  = return F4(x)  
func fromState * (x : State):  F12 = return F12(x) 

func toDigest* (x : F4 ): Digest = Digest(x)
func toState*  (x : F12): State  = State(x)

func `==`* (x, y: State ): bool = return (fromState(x) == fromState(y))
func `==`* (x, y: Digest): bool = return (fromDigest(x) == fromDigest(y))

proc `$`*(x: State ): string = return $(fromState(x))
proc `$`*(x: Digest): string = return $(fromDigest(x))

#-------------------------------------------------------------------------------
