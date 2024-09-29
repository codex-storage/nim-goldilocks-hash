
{-# LANGUAGE ScopedTypeVariables, NumericUnderscores #-}

{-| Sponge construction

Conventions:

  * when hashing a sequence of field elements, we pad using the @10*@ padding 
    strategy to the next multiple of the rate

  * when hashing a sequence of bytes, we only allow a rate of 4 or 8; we pad
    to a multiple of 31 or 62 bytes (depending on the rate) using again the
    @10*@ strategy, but now with bytes. We don't do extra padding on the 
    resulting field element sequence, as it's unnecessary.

  * when converting 31 bytes to 4 field elements, we use 62 bits for each
    field element, interpreting them as a little-endian 62 bit numbers.

  * when serializing a digest of four field elements, we interpret them
    as 64 bit numbers (resulting in a 32 byte long hash digest)

-}

module Sponge where

--------------------------------------------------------------------------------

import Data.Array
import Data.Bits
import Data.Word
import Data.List

import Goldilocks
import Poseidon2

--------------------------------------------------------------------------------

newtype Rate 
  = Rate Int
  deriving (Eq,Ord,Show)

-- | Pad with @10*@ strategy
splitAndPadSequence :: forall a. Num a => Int -> [a] -> [[a]]
splitAndPadSequence r xs = go xs1 where
  xs1 = xs ++ [0x01]
  go :: [a] -> [[a]]
  go list = case splitAt r list of 
         (this,rest) -> case rest of
           [] -> [this ++ replicate (r - length this) 0]
           _  -> this : go rest

--------------------------------------------------------------------------------

data Digest 
  = MkDigest !F !F !F !F
  deriving (Eq,Show)

--------------------------------------------------------------------------------

digestToWord64s :: Digest -> [Word64]
digestToWord64s (MkDigest a b c d) = [ fromF a, fromF b, fromF c, fromF d]

digestToBytes :: Digest -> [Word8]
digestToBytes = concatMap bytesFromWord64LE . digestToWord64s

bytesFromWord64LE :: Word64 -> [Word8]
bytesFromWord64LE = go 0 where
  go 8  _  = []
  go !k !w = fromIntegral (w .&. 0xff) : go (k+1) (shiftL w 8)

bytesToWord64LE :: [Word8] -> Word64
bytesToWord64LE = fromInteger . bytesToIntegerLE

bytesToIntegerLE :: [Word8] -> Integer
bytesToIntegerLE = go where
  go []          = 0 
  go (this:rest) = fromIntegral this + 256 * go rest

--------------------------------------------------------------------------------

hashFieldElems :: [F] -> Digest
hashFieldElems = hashFieldElems' (Rate 8)

hashFieldElems' :: Rate -> [F] -> Digest
hashFieldElems' rate@(Rate r) fels 
  | r < 1 || r > 8  = error "the rate should be between 1 and 8"
  | otherwise       = internalSponge 63 rate (splitAndPadSequence r fels) 
  where
{-
    iv     = listArray (0,11) $ [ 0,0,0,0 , 0,0,0,0 , domSep,0,0,0 ] 
    bits   = 64  -- input is a sequence of field elements, each approx 64 bits long 
    domSep = fromIntegral (65536*bits + 256*t + r)
    t      = 12
    step  block state = permutation (addToState block state)
    sponge list state = case list of
      (this:rest) -> sponge rest (step this state)
      []          -> state
-}

-- | @nbits@ is how many bits is the size of a single element of the original input sequence.
-- This is used for domain separation, which is encoded as @domSep = 65536*nbits + 256*t + r@.
--
-- Some possible values:
--
--  * 1 for bit sequence
--
--  * 8 for byte sequence
--
--  * 63 for field element sequence
--
internalSponge :: Int -> Rate -> [[F]] -> Digest
internalSponge nbits (Rate r) blocks = extractDigest (loop blocks iv) where
  iv     = listArray (0,11) $ [ 0,0,0,0 , 0,0,0,0 , domSep,0,0,0 ] :: State
  domSep = fromIntegral (65536*nbits + 256*t + r) :: F
  t      = 12

  step :: [F] -> State -> State
  step block state = permutation (addToState block state)

  loop :: [[F]] -> State -> State
  loop list state = case list of
    (this:rest) -> loop rest (step this state)
    []          -> state

extractDigest :: State -> Digest
extractDigest state = case elems state of 
  (a:b:c:d:_) -> MkDigest a b c d

addToState :: [F] -> State -> State
addToState xs arr = listArray (0,11) $ zipWith (+) (xs ++ repeat 0) (elems arr)

--------------------------------------------------------------------------------

hashBytes :: [Word8] -> Digest
hashBytes = hashBytes' (Rate 8)

hashBytes' :: Rate -> [Word8] -> Digest
hashBytes' rate input = case rate of
  Rate 4 -> internalSponge nbits rate $ map decode31Bytes $ splitAndPadSequence 31 input
  Rate 8 -> internalSponge nbits rate $ map decode62Bytes $ splitAndPadSequence 62 input
  _      -> error "for hashing of byte sequences, we only support rate = 4 or 8"
  where
    nbits = 8

--------------------------------------------------------------------------------

mask62bits :: Integer -> Word64
mask62bits n = fromInteger (n .&. 0x_3fff_ffff_ffff_ffff) 

decode31Bytes :: [Word8] -> [F]
decode31Bytes input
  | length input /= 31  = error "consume31Bytes: input is not exactly 31 bytes"
  | otherwise           = [a,b,c,d]
  where
    a = toF $ mask62bits                 $ bytesToIntegerLE           input
    b = toF $ mask62bits $ flip shiftR 6 $ bytesToIntegerLE $ drop  7 input
    c = toF $ mask62bits $ flip shiftR 4 $ bytesToIntegerLE $ drop 15 input
    d = toF $ mask62bits $ flip shiftR 2 $ bytesToIntegerLE $ drop 23 input

decode62Bytes :: [Word8] -> [F]
decode62Bytes input = decode31Bytes as ++ decode31Bytes bs where
  (as,bs) = splitAt 31 input

--------------------------------------------------------------------------------
