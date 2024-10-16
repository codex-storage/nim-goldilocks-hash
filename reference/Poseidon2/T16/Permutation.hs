
{-# LANGUAGE Strict #-}
module Poseidon2.T16.Permutation where

--------------------------------------------------------------------------------

import Data.Word

import Data.Array (Array)
import Data.Array.IArray

import Poseidon2.T16.Constants
import Goldilocks
import Common

--------------------------------------------------------------------------------

-- | permutation of @[0..15]@, from HorizenLabs Rust impl
kats :: [Word64]
kats = 
  [ 0x85c54702470d9756
  , 0xaa53c7a7d52d9898
  , 0x285128096efb0dd7
  , 0xf3fde5edd3050ac8
  , 0xc7b65efd040df908
  , 0x4be3f6c467f57ae9
  , 0x274e9a67b41754fb
  , 0x0f7d39cd5de94dac
  , 0xd0224b9794d0b78c
  , 0x372f6139570042e1
  , 0xce6e8a93dc4ec26c
  , 0xace65e30a4daf7af
  , 0x016f2824cc1ba3db
  , 0x2e8f3af37c434dec
  , 0xc80831bb6e09da01
  , 0x3a7d670bf1a86ee8
  ]

--------------------------------------------------------------------------------

permutation :: State -> State
permutation 
  = finalRounds
  . internalRounds
  . initialRounds
  . externalDiffusion

--------------------------------------------------------------------------------

initialRounds :: State -> State
initialRounds
  = externalRound (initialRoundConsts ! 3) 
  . externalRound (initialRoundConsts ! 2) 
  . externalRound (initialRoundConsts ! 1) 
  . externalRound (initialRoundConsts ! 0) 

internalRounds :: State -> State
internalRounds = foldr1 (.) (map (internalRound $) (reverse internalRoundConsts))

finalRounds :: State -> State
finalRounds
  = externalRound (finalRoundConsts ! 3) 
  . externalRound (finalRoundConsts ! 2) 
  . externalRound (finalRoundConsts ! 1) 
  . externalRound (finalRoundConsts ! 0) 

--------------------------------------------------------------------------------

externalRound :: [F] -> State -> State
externalRound rcs = externalDiffusion . sboxExternal rcs

internalRound :: F -> State -> State
internalRound rc = internalDiffusion . sboxInternal rc

--------------------------------------------------------------------------------

sbox1 :: F -> F
sbox1 x = pow x 7

sboxRC :: F -> F -> F
sboxRC rc x = sbox1 (x+rc)

sboxInternal :: F -> State -> State
sboxInternal rc s = s // [ (0, sboxRC rc (s!0)) ]

sboxExternal :: [F] -> State -> State
sboxExternal rcs s = listArray (0,15) $ zipWith sboxRC rcs (elems s) 

--------------------------------------------------------------------------------

internalDiffusion :: State -> State
internalDiffusion state = listArray (0,15) $ [ s + (state!i * internalDiagElems!i) | i<-[0..15] ] where
  s = sum (elems state)

{-
matM4 :: Array (Int,Int) F
matM4 = amap toF $ listArray ((0,0),(3,3)) 
  [ 5 , 7 , 1 , 3
  , 4 , 6 , 1 , 1
  , 1 , 3 , 5 , 7
  , 1 , 1 , 4 , 6
  ]
-}

matM16:: Array (Int,Int) F
matM16 = amap toF $ listArray ((0,0),(15,15)) 
  [ 2*5 , 2*7 , 2*1 , 2*3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3
  , 2*4 , 2*6 , 2*1 , 2*1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1
  , 2*1 , 2*3 , 2*5 , 2*7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7
  , 2*1 , 2*1 , 2*4 , 2*6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6
  ,   5 ,   7 ,   1 ,   3 , 2*5 , 2*7 , 2*1 , 2*3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3
  ,   4 ,   6 ,   1 ,   1 , 2*4 , 2*6 , 2*1 , 2*1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1
  ,   1 ,   3 ,   5 ,   7 , 2*1 , 2*3 , 2*5 , 2*7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7
  ,   1 ,   1 ,   4 ,   6 , 2*1 , 2*1 , 2*4 , 2*6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6
  ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 , 2*5 , 2*7 , 2*1 , 2*3 ,   5 ,   7 ,   1 ,   3 
  ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 , 2*4 , 2*6 , 2*1 , 2*1 ,   4 ,   6 ,   1 ,   1 
  ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 , 2*1 , 2*3 , 2*5 , 2*7 ,   1 ,   3 ,   5 ,   7 
  ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 , 2*1 , 2*1 , 2*4 , 2*6 ,   1 ,   1 ,   4 ,   6 
  ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 , 2*5 , 2*7 , 2*1 , 2*3 
  ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 , 2*4 , 2*6 , 2*1 , 2*1 
  ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 , 2*1 , 2*3 , 2*5 , 2*7 
  ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 , 2*1 , 2*1 , 2*4 , 2*6 
  ]

externalDiffusion :: State -> State
externalDiffusion state = listArray (0,15)
  [ sum [ matM16!(i,j) * state!j | j<-[0..15] ] 
  | i<-[0..15]
  ]

--------------------------------------------------------------------------------
