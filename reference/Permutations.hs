
module Permutations where

--------------------------------------------------------------------------------

import qualified Poseidon2.T12.Permutation as Poseidon2_T12
import qualified Poseidon2.T16.Permutation as Poseidon2_T16
import qualified Monolith.Permutation      as Monolith

import Common

--------------------------------------------------------------------------------

permute :: Hash -> State -> State
permute hash = case hash of
  Poseidon2_T12 -> Poseidon2_T12.permutation
  Poseidon2_T16 -> Poseidon2_T16.permutation
  Monolith      -> Monolith.permutation

--------------------------------------------------------------------------------
