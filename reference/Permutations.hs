
module Permutations where

--------------------------------------------------------------------------------

import qualified Poseidon2.Permutation as Poseidon2
import qualified Monolith.Permutation  as Monolith

import Common

--------------------------------------------------------------------------------

permute :: Hash -> State -> State
permute hash = case hash of
  Poseidon2 -> Poseidon2.permutation
  Monolith  -> Monolith.permutation

--------------------------------------------------------------------------------
