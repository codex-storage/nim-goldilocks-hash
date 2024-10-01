
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

feltDigest :: Rate -> Integer -> Digest
feltDigest rate max = hashFieldElems' rate $ (map fromInteger [1..max] :: [F])

byteDigest :: Rate -> Integer -> Digest
byteDigest rate max = hashBytes' rate $ (map fromInteger [1..max] :: [Word8])

--------------------------------------------------------------------------------

printTests :: IO ()
printTests = hPrintTests stdout

hPrintTests :: Handle -> IO ()
hPrintTests h = hPutStrLn h $ unlines $ 
  [ digests ("testcases_field_rate" ++ show r) (feltDigest (Rate r)) [0..80] | r<-[1..8] ] ++
  [ digests ("testcases_bytes_rate" ++ show r) (byteDigest (Rate r)) [0..80] | r<-[4,8]  ]

writeTests :: IO ()
writeTests = withFile "spongeTestCases.nim" WriteMode $ \h -> do
  hPutStrLn   h "# generated by TestGen/TestSponge.hs\n"
  hPutStrLn   h "import goldilocks_hash/types\n"
  hPrintTests h

--------------------------------------------------------------------------------
