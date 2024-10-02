
-- | Generate test cases for Nim

module TestGen.TestSponge where

--------------------------------------------------------------------------------

import Data.Array
import Data.List
import Data.Word

import System.IO

import Sponge
import Goldilocks
import Common

import TestGen.Shared

--------------------------------------------------------------------------------

feltDigest :: Hash -> Rate -> Integer -> Digest
feltDigest hash rate max = hashFieldElems' hash rate $ (map fromInteger [1..max] :: [F])

byteDigest :: Hash -> Rate -> Integer -> Digest
byteDigest hash rate max = hashBytes' hash rate $ (map fromInteger [1..max] :: [Word8])

--------------------------------------------------------------------------------

printTests :: Hash -> IO ()
printTests hash = hPrintTests stdout hash

hPrintTests :: Handle -> Hash -> IO ()
hPrintTests h hash = hPutStrLn h $ unlines $ 
  [ digests ("testcases_field_rate" ++ show r) (feltDigest hash (Rate r)) [0..80] | r<-[1..8] ] ++
  [ digests ("testcases_bytes_rate" ++ show r) (byteDigest hash (Rate r)) [0..80] | r<-[4,8]  ]

writeTests :: Hash -> IO ()
writeTests hash = withFile "spongeTestCases.nim" WriteMode $ \h -> do
  hPutStrLn   h "# generated by TestGen/TestSponge.hs\n"
  hPutStrLn   h "import goldilocks_hash/types\n"
  hPrintTests h hash

--------------------------------------------------------------------------------
