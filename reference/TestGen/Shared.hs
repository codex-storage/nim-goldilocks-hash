
module TestGen.Shared where

--------------------------------------------------------------------------------

import Data.Array
import Data.List

import Goldilocks
import Common

--------------------------------------------------------------------------------

nimShowF_ :: F -> String
nimShowF_ x = show x ++ "'u64"

nimShowF :: F -> String
nimShowF x = "toF( " ++ show x ++ "'u64 )"

--------------------------------------------------------------------------------

nimShowPair :: (F,F) -> String
nimShowPair (x,y) = "( " ++ nimShowF_ x ++ " , " ++ nimShowF_ y ++ " )"

nimShowTriple :: (F,F,F) -> String
nimShowTriple (x,y,z) = "( " ++ nimShowF_ x ++ " , " ++ nimShowF_ y ++ " , " ++ nimShowF_ z ++ " )"

nimShowPairs :: [(F,F)] -> [String]
nimShowPairs xys = zipWith (++) prefix (map nimShowPair xys) where
  prefix = "  [ " : repeat "  , "

nimShowTriples :: [(F,F,F)] -> [String]
nimShowTriples xyzs = zipWith (++) prefix (map nimShowTriple xyzs) where
  prefix = "  [ " : repeat "  , "

----------------------------------------

nimShowState :: State -> String
nimShowState xs = "[ " ++ intercalate ", " (map nimShowF (elems xs)) ++ " ]"

nimShowStatePair :: (State,State) -> String
nimShowStatePair (x,y) = "( " ++ nimShowState x ++ " , " ++ nimShowState y ++ " )"

----------------------------------------

nimShowDigest :: Digest -> String
nimShowDigest (MkDigest a b c d) = "[ " ++ intercalate ", " (map nimShowF [a,b,c,d]) ++ " ]"

nimShowIntDigestPair :: (Integer,Digest) -> String
nimShowIntDigestPair (n,d) = "( " ++ show n ++ " , " ++ nimShowDigest d ++ " )"


showListWith :: (a -> String) -> [a] -> [String]
showListWith f xys = zipWith (++) prefix (map f xys) where
  prefix = "  [ " : repeat "  , "

----------------------------------------

digests :: String -> (Integer -> Digest) -> [Integer] -> String
digests varname f xs = unlines (header : stuff ++ footer) where
  header = "const " ++ varname ++ "* : array[" ++ show (length xs) ++ ", tuple[n:int,digest:F4]] = "
  footer = ["  ]",""]
  stuff  = showListWith nimShowIntDigestPair [ (x, f x) | x<-xs ]

--------------------------------------------------------------------------------
