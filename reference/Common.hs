
module Common where

--------------------------------------------------------------------------------

import Data.Array
import Data.Bits
import Data.Word

import Goldilocks

--------------------------------------------------------------------------------

data Hash
  = Poseidon2
  | Monolith
--  | Tip4'
  deriving (Eq,Show)

--------------------------------------------------------------------------------

type State = Array Int F

listToState :: [F] -> State
listToState = listArray (0,11)

zeroState :: State
zeroState = listToState (replicate 12 0)

--------------------------------------------------------------------------------

data Digest 
  = MkDigest !F !F !F !F
  deriving (Eq,Show)

zeroDigest :: Digest
zeroDigest = MkDigest 0 0 0 0

extractDigest :: State -> Digest
extractDigest state = case elems state of 
  (a:b:c:d:_) -> MkDigest a b c d

--------------------------------------------------------------------------------

digestToWord64s :: Digest -> [Word64]
digestToWord64s (MkDigest a b c d) = [ fromF a, fromF b, fromF c, fromF d]

digestToBytes :: Digest -> [Word8]
digestToBytes = concatMap bytesFromWord64LE . digestToWord64s

--------------------------------------------------------------------------------

bytesFromWord64LE :: Word64 -> [Word8]
bytesFromWord64LE = go 0 where
  go 8  _  = []
  go !k !w = fromIntegral (w .&. 0xff) : go (k+1) (shiftR w 8)

bytesToWord64LE :: [Word8] -> Word64
bytesToWord64LE = fromInteger . bytesToIntegerLE

bytesToIntegerLE :: [Word8] -> Integer
bytesToIntegerLE = go where
  go []          = 0 
  go (this:rest) = fromIntegral this + 256 * go rest

--------------------------------------------------------------------------------
