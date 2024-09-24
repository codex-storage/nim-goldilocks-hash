
import ./types

# the Poseidon2 permutation (mutable, in-place version)
proc permInPlace*(state: var State) {. header: "../cbits/goldilocks.h", importc: "goldilocks_poseidon2_permutation", cdecl .}

# the Poseidon2 permutation (pure version)
func perm*(state: State): State =
  var tmp = state
  permInPlace(tmp)
  return tmp
