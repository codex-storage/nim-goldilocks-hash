
{-| Merkle tree construction

Conventions:

  * we use a "keyed compression function" to avoid collisions for different inputs

  * when hashing the bottom-most layer, we use the key bit 0x01

  * when hashing an odd layer, we pad with a single 0 hash and use the key bit 0x02

  * when building a tree on a singleton input, we apply 1 round of compression 
    (with key 0x03, as it's both the bottom-most layer and odd)

-}

module Merkle where

--------------------------------------------------------------------------------

import Data.Array

import Poseidon2
import Goldilocks
import Common

--------------------------------------------------------------------------------

type Key = Int

--------------------------------------------------------------------------------

compress :: Digest -> Digest -> Digest
compress (MkDigest a b c d) (MkDigest p q r s) = extractDigest output where
  input  = listArray (0,11) [ a,b,c,d , p,q,r,s , 0,0,0,0 ]
  output = permutation input

keyedCompress :: Int -> Digest -> Digest -> Digest
keyedCompress key (MkDigest a b c d) (MkDigest p q r s) = extractDigest output where
  k = fromIntegral key :: F
  input  = listArray (0,11) [ a,b,c,d , p,q,r,s , k,0,0,0 ]
  output = permutation input

--------------------------------------------------------------------------------

-- | bit masks
keyBottom = 1 :: Key
keyOdd    = 2 :: Key

--------------------------------------------------------------------------------

merkleRoot :: [Digest] -> Digest
merkleRoot []  = error "merkleRoot: empty input"
merkleRoot [x] = keyedCompress (keyBottom + keyOdd) x zeroDigest
merkleRoot xs  = worker True xs where

  worker :: Bool -> [Digest] -> Digest
  worker _        [x] = x
  worker isBottom xs  = worker False (go xs) where

    key0 = if isBottom then keyBottom else 0

    go :: [Digest] -> [Digest]
    go (x:y:rest) = keyedCompress key0 x y : go rest
    go [x]        = [ keyedCompress (key0 + keyOdd) x zeroDigest ]
    go []         = []

--------------------------------------------------------------------------------
