
# sponge construction for linear hashing.
#
# we recommend to use rate=8
# (note that we have the state width fixed to t=12)
#
# we use the 10* padding strategy (that is, always append an 1, and append
# as many zeros as required so that the final length is divisible by the rate)
# both when hashing bytes and when hashing field elements

import ../types
import ../goldilocks
import ./permutation
#import ./io

#-------------------------------------------------------------------------------

type
  Sponge*[T: type, rate: static int] = object
    state:      F12
    lenModRate: uint

func initialize(sponge: var Sponge) =
  when not Sponge.rate >= 1 and Sponge.rate <= 8:
    {.error: "with t=12, rate must be at most 8 (and positive)".}
  const nbits = numberOfBits(Sponge.T)
  const IV = toF( 0x10000*uint64(nbits) + 0x100*12 + uint64(Sponge.rate) )  # domain separation IV := (65536*nbits + 256*t + r)
  sponge.state[8] = IV;

#---------------------------------------

func extractDigestF4(sponge: var Sponge) : F4 =
  var digest : F4
  for i in 0..<4: digest[i] = sponge.state[i]
  return digest

func extractDigest(sponge: var Sponge) : Digest =
  return toDigest(sponge.extractDigestF4())

#---------------------------------------

func update*[rate](sponge: var Sponge[F, rate], x: F) =
  sponge.state[sponge.lenModRate] += x
  sponge.lenModRate = (sponge.lenModRate + 1) mod rate
  if (sponge.lenModRate == 0):
    permInPlaceF12( sponge.state );

func finish*(sponge: var Sponge): Digest =
  # padding
  sponge.update(one)
  while( sponge.lenModRate != 0):
    sponge.update(zero)
  return sponge.extractDigest()

#-------------------------------------------------------------------------------

func init*(_: type Sponge, T: type, rate: static int): Sponge[T,rate] =
  when (rate < 1 or rate > 8):
    {.error: "only rates between 1 and 8 are supported".}
  var sponge: Sponge[T, rate]
  initialize(sponge)
  return sponge

#---------------------------------------

# digest a sequence of field elements
func digestNim*(rate: static int = 8, elements: openArray[F]): Digest =
  var sponge : Sponge[F,rate] = Sponge.init(F, rate)
  for element in elements:
    sponge.update(element)
  return sponge.finish()

# # digest a sequence of bytes
#func digestNim*(rate: static int = 8, bytes: openArray[byte],): F =
#  var sponge = Sponge.init(nbits=8, rate)
#  for element in bytes.elements(F):
#    sponge.update(element)
#  return sponge.finish()

#---------------------------------------

proc digestFeltsRawC(rate: int, len: int, input: ptr F   , hash: var F4) {. header: "../goldilocks_hash/cbits/goldilocks.h", importc: "goldilocks_monolith_felts_digest", cdecl .}
proc digestBytesRawC(rate: int, len: int, input: ptr byte, hash: var F4) {. header: "../goldilocks_hash/cbits/goldilocks.h", importc: "goldilocks_monolith_bytes_digest", cdecl .}

func digestFeltsC*(rate: static int = 8, felts: openArray[F]): Digest =
  var digest : F4
  let input = if felts.len > 0: unsafeAddr felts[0] else: nil
  digestFeltsRawC(rate, felts.len, input, digest)
  return toDigest(digest)

func digestBytesC*(rate: static int = 8, bytes: openArray[byte]): Digest =
  var digest : F4
  let input = if bytes.len > 0: unsafeAddr bytes[0] else: nil
  digestBytesRawC(rate, bytes.len, input, digest)
  return toDigest(digest)

#-------------------------------------------------------------------------------

