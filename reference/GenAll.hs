
module GenAll where

--------------------------------------------------------------------------------

import qualified TestGen.TestGoldilocks  as F
import qualified TestGen.TestPermutation as P
import qualified TestGen.TestCompress    as C
import qualified TestGen.TestSponge      as S
import qualified TestGen.TestMerkle      as M

import Common

--------------------------------------------------------------------------------

writeTestCasesFor :: Hash -> IO ()
writeTestCasesFor hash = do
  P.writeTests hash
  C.writeTests hash
  S.writeTests hash
  M.writeTests hash

--------------------------------------------------------------------------------
