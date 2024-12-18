
{-# LANGUAGE Strict #-}
module Poseidon2.T12.Permutation where

--------------------------------------------------------------------------------

import Data.Word

import Data.Array (Array)
import Data.Array.IArray

import Poseidon2.T12.Constants
import Goldilocks
import Common

--------------------------------------------------------------------------------

-- | permutation of @[0..15]@, from HorizenLabs Rust impl
kats :: [Word64]
kats = 
  [ 0x01eaef96bdf1c0c1
  , 0x1f0d2cc525b2540c
  , 0x6282c1dfe1e0358d
  , 0xe780d721f698e1e6
  , 0x280c0b6f753d833b
  , 0x1b942dd5023156ab
  , 0x43f0df3fcccb8398
  , 0xe8e8190585489025
  , 0x56bdbf72f77ada22
  , 0x7911c32bf9dcd705
  , 0xec467926508fbe67
  , 0x6a50450ddf85a6ed
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
sboxExternal rcs s = listArray (0,11) $ zipWith sboxRC rcs (elems s) 

--------------------------------------------------------------------------------

internalDiffusion :: State -> State
internalDiffusion state = listArray (0,11) $ [ s + (state!i * internalDiagElems!i) | i<-[0..11] ] where
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

matM12:: Array (Int,Int) F
matM12 = amap toF $ listArray ((0,0),(11,11)) 
  [ 2*5 , 2*7 , 2*1 , 2*3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3
  , 2*4 , 2*6 , 2*1 , 2*1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1
  , 2*1 , 2*3 , 2*5 , 2*7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7
  , 2*1 , 2*1 , 2*4 , 2*6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6
  ,   5 ,   7 ,   1 ,   3 , 2*5 , 2*7 , 2*1 , 2*3 ,   5 ,   7 ,   1 ,   3
  ,   4 ,   6 ,   1 ,   1 , 2*4 , 2*6 , 2*1 , 2*1 ,   4 ,   6 ,   1 ,   1
  ,   1 ,   3 ,   5 ,   7 , 2*1 , 2*3 , 2*5 , 2*7 ,   1 ,   3 ,   5 ,   7
  ,   1 ,   1 ,   4 ,   6 , 2*1 , 2*1 , 2*4 , 2*6 ,   1 ,   1 ,   4 ,   6
  ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 , 2*5 , 2*7 , 2*1 , 2*3 
  ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 , 2*4 , 2*6 , 2*1 , 2*1 
  ,   1 ,   3 ,   5 ,   7 ,   1 ,   3 ,   5 ,   7 , 2*1 , 2*3 , 2*5 , 2*7 
  ,   1 ,   1 ,   4 ,   6 ,   1 ,   1 ,   4 ,   6 , 2*1 , 2*1 , 2*4 , 2*6 
  ]

externalDiffusion :: State -> State
externalDiffusion state = listArray (0,11)
  [ sum [ matM12!(i,j) * state!j | j<-[0..11] ] 
  | i<-[0..11]
  ]

--------------------------------------------------------------------------------
