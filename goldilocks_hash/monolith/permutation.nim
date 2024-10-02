
import ../types

# the Monolith permutation (mutable, in-place version)
proc permInPlace*   (state: var State) {. header: "../cbits/goldilocks.h", importc: "goldilocks_monolith_permutation", cdecl .}
proc permInPlaceF12*(state: var F12  ) {. header: "../cbits/goldilocks.h", importc: "goldilocks_monolith_permutation", cdecl .}

# the Monolith permutation (pure version)
func perm*(state: State): State =
  var tmp = state
  permInPlace(tmp)
  return tmp

func permF12*(state: F12): F12 =
  var tmp = state
  permInPlaceF12(tmp)
  return tmp
