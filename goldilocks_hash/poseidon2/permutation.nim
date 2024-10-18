
import ../types

# the Poseidon2 permutation (mutable, in-place version)
proc permInPlace*   (state: var State) {. header: "../goldilocks_hash/cbits/goldilocks.h", importc: "goldilocks_poseidon2_permutation", cdecl .}
proc permInPlaceF12*(state: var F12  ) {. header: "../goldilocks_hash/cbits/goldilocks.h", importc: "goldilocks_poseidon2_permutation", cdecl .}

# the Poseidon2 permutation (pure version)
func perm*(state: State): State =
  var tmp = state
  permInPlace(tmp)
  return tmp

func permF12*(state: F12): F12 =
  var tmp = state
  permInPlaceF12(tmp)
  return tmp
