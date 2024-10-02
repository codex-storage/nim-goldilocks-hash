
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

import Permutations
import Goldilocks
import Common

--------------------------------------------------------------------------------

type Key = Int

--------------------------------------------------------------------------------

compress :: Hash -> Digest -> Digest -> Digest
compress which (MkDigest a b c d) (MkDigest p q r s) = extractDigest output where
  input  = listArray (0,11) [ a,b,c,d , p,q,r,s , 0,0,0,0 ]
  output = permute which input

keyedCompress ::  Hash -> Int -> Digest -> Digest -> Digest
keyedCompress which key (MkDigest a b c d) (MkDigest p q r s) = extractDigest output where
  k = fromIntegral key :: F
  input  = listArray (0,11) [ a,b,c,d , p,q,r,s , k,0,0,0 ]
  output = permute which input

--------------------------------------------------------------------------------

-- | bit masks
keyBottom = 1 :: Key
keyOdd    = 2 :: Key

--------------------------------------------------------------------------------

merkleRoot :: Hash -> [Digest] -> Digest
merkleRoot which []  = error "merkleRoot: empty input"
merkleRoot which [x] = keyedCompress which (keyBottom + keyOdd) x zeroDigest
merkleRoot which xs  = worker True xs where

  worker :: Bool -> [Digest] -> Digest
  worker _        [x] = x
  worker isBottom xs  = worker False (go xs) where

    key0 = if isBottom then keyBottom else 0

    go :: [Digest] -> [Digest]
    go (x:y:rest) = keyedCompress which key0 x y : go rest
    go [x]        = [ keyedCompress which (key0 + keyOdd) x zeroDigest ]
    go []         = []

--------------------------------------------------------------------------------
