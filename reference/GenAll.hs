
module GenAll where

--------------------------------------------------------------------------------

import qualified TestGen.TestGoldilocks  as F
import qualified TestGen.TestPermutation as P
import qualified TestGen.TestSponge      as S
import qualified TestGen.TestMerkle      as M

import Common

--------------------------------------------------------------------------------

writeSingleHash :: Hash -> IO ()
writeSingleHash hash = do
  P.writeTests hash
  S.writeTests hash
  M.writeTests hash

--------------------------------------------------------------------------------
