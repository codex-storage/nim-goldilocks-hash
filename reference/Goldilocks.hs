
-- | Reference (slow) implementation of the Goldilocks prime field

{-# LANGUAGE BangPatterns, NumericUnderscores #-}
module Goldilocks where

--------------------------------------------------------------------------------

import Prelude hiding ( div )
import qualified Prelude

import Data.Bits
import Data.Word
import Data.Ratio

import Text.Printf

--------------------------------------------------------------------------------

type F = Goldilocks

fromF :: F -> Word64
fromF (Goldilocks x) = fromInteger x

toF :: Word64 -> F
toF = mkGoldilocks . fromIntegral

--------------------------------------------------------------------------------

newtype Goldilocks 
  = Goldilocks Integer 
  deriving Eq

instance Show Goldilocks where
  show (Goldilocks k) = printf "0x%016x" k

--------------------------------------------------------------------------------

instance Num Goldilocks where
  fromInteger = mkGoldilocks
  negate = neg
  (+)    = add
  (-)    = sub
  (*)    = mul
  abs    = id
  signum _ = Goldilocks 1

instance Fractional Goldilocks where
  fromRational y = fromInteger (numerator y) `div` fromInteger (denominator y)
  recip  = inv
  (/)    = div

--------------------------------------------------------------------------------

-- | @p = 2^64 - 2^32 + 1@
goldilocksPrime :: Integer
goldilocksPrime = 0x_ffff_ffff_0000_0001

modp :: Integer -> Integer
modp a = mod a goldilocksPrime

mkGoldilocks :: Integer -> Goldilocks
mkGoldilocks = Goldilocks . modp

--------------------------------------------------------------------------------

neg :: Goldilocks -> Goldilocks
neg (Goldilocks k) = mkGoldilocks (negate k) 

add :: Goldilocks -> Goldilocks -> Goldilocks
add (Goldilocks a) (Goldilocks b) = mkGoldilocks (a+b) 

sub :: Goldilocks -> Goldilocks -> Goldilocks
sub (Goldilocks a) (Goldilocks b) = mkGoldilocks (a-b) 

sqr :: Goldilocks -> Goldilocks
sqr x = mul x x

mul :: Goldilocks -> Goldilocks -> Goldilocks
mul (Goldilocks a) (Goldilocks b) = mkGoldilocks (a*b) 

inv :: Goldilocks -> Goldilocks
inv x = pow x (goldilocksPrime - 2)

div :: Goldilocks -> Goldilocks -> Goldilocks
div a b = mul a (inv b)

--------------------------------------------------------------------------------

pow :: Goldilocks -> Integer -> Goldilocks
pow x e 
  | e == 0    = 1
  | e <  0    = pow (inv x) (negate e)
  | otherwise = go 1 x e
  where
    go !acc _  0     = acc
    go !acc !s !expo = case expo .&. 1 of
      0 -> go acc     (sqr s) (shiftR expo 1)
      _ -> go (acc*s) (sqr s) (shiftR expo 1)

--------------------------------------------------------------------------------

