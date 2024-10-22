
import std/sequtils
import std/strformat

#-------------------------------------------------------------------------------

type F* = distinct uint64

func fromF* (x: F): uint64 = return uint64(x)
func toF*   (x: uint64): F = return F(x)
func toF*   (x: int   ): F =
  assert(x >= 0)
  return F(uint64(x))

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

func toDigest*   (x : F4 ): Digest = Digest(x)
func toState*    (x : F12): State  = State(x)

func mkDigest*   (a,b,c,d: F): Digest = toDigest( [a,b,c,d] )

func mkDigestU64*(a,b,c,d: uint64): Digest = toDigest( [toF(a),toF(b),toF(c),toF(d) ] )
func toDigestU64*(x : array[4,uint64]): Digest = mkDigestU64( x[0], x[1], x[2], x[3] )

func uint64ToDigest*(x: uint64): Digest = mkDigestU64( x,0,0,0 )
func intToDigest*   (x: int   ): Digest = uint64ToDigest( uint64(x) )

const zeroDigest* : Digest = mkDigestU64(0,0,0,0)

func `==`* (x, y: State ): bool = return (fromState(x) == fromState(y))
func `==`* (x, y: Digest): bool = return (fromDigest(x) == fromDigest(y))

proc `$`*(x: State ): string = return $(fromState(x))
proc `$`*(x: Digest): string = return $(fromDigest(x))

#-------------------------------------------------------------------------------

func digestToFeltSeq*( d: Digest ): seq[F] = 
  var output: seq[F] = newSeq[F]( 4 )
  let f4 = fromDigest( d )
  output[0] = f4[0]
  output[1] = f4[1]
  output[2] = f4[2]
  output[3] = f4[3]
  return output

func digestSeqToFeltSeq*( ds: seq[Digest] ): seq[F] = 
  let n = ds.len
  var output: seq[F] = newSeq[F]( 4*n )
  for k in 0..<n:
    let f4 = fromDigest( ds[k] )
    let j = 4*k
    output[j+0] = f4[0]
    output[j+1] = f4[1]
    output[j+2] = f4[2]
    output[j+3] = f4[3]
  return output

func digestSeqToFeltSeqSeq*( ds: seq[Digest] ): seq[seq[F]] 
  = ds.map(digestToFeltSeq)

#-------------------------------------------------------------------------------

func numberOfBits*(T: type): int {.compileTime.} =
  when T is F:
    63
#  elif T is uint32:
#    32
#  elif T is uint16:
#    16
  elif T is byte:
    8
  elif T is bool:
    1
  else:
    {.error: "unsupported input type for sponge construction".}

#-------------------------------------------------------------------------------
