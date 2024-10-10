
import ../types

proc c_compress(a, b: var Digest, key: uint64, output: var Digest) {. header: "../cbits/goldilocks.h", importc: "goldilocks_monolith_keyed_compress", cdecl .}

# keyed compression function
func compress*(a, b: Digest, key: uint64 = 0) : Digest =
  var x: Digest = a
  var y: Digest = b
  var output: Digest
  c_compress(x,y,key,output)
  return output
