
import std/sequtils
import std/unittest

import goldilocks_hash/types
import goldilocks_hash/marshal

#-------------------------------------------------------------------------------

type U4 = array[4,uint64]

func F4SeqToDigestSeq( inp : seq[F4] ): seq[Digest] = inp.map(toDigest   )
func U4SeqToDigestSeq( inp : seq[U4] ): seq[Digest] = inp.map(toDigestU64)

func intToByte(x: int): byte = byte(x)

#-------------------------------------------------------------------------------

suite "marshalling to/from Digests":

  test "uint64ToBytesLE":
    let word  : uint64        = 0x123456789abcdef3'u64
    let bytes : array[8,byte] = [ 0xf3, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12 ]
    check ( bytes == uint64ToBytesLE(word) );

  test "bytesToUint64LE":
    let word  : uint64        = 0x123456789abcdef3'u64
    let bytes : array[8,byte] = [ 0xf3, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12 ]
    check ( bytesToUint64LE(bytes) == word );

  #-----------------
  
  test "digestToBytes":
    let dig = mkDigestU64( 0x123456789abcdef3'u64
                         , 0x43f5a2d9c2871a4b'u64
                         , 0xb2d79201f9771e0e'u64
                         , 0x2074c7946509c3a5'u64
                         )
    let bytes : array[32, uint8] = 
          [ 0xf3, 0xde, 0xbc, 0x9a, 0x78, 0x56, 0x34, 0x12
          , 0x4b, 0x1a, 0x87, 0xc2, 0xd9, 0xa2, 0xf5, 0x43
          , 0x0e, 0x1e, 0x77, 0xf9, 0x01, 0x92, 0xd7, 0xb2
          , 0xa5, 0xc3, 0x09, 0x65, 0x94, 0xc7, 0x74, 0x20
          ]
    check ( bytes == digestToBytes(dig) )

  #-----------------

  test "decodeBytesToDigest [1..31]":
    let bytes : array[31,byte]  = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    let words : array[4,uint64] = [ 0x0807060504030201'u64 , 0x003c3834302c2824'u64 , 0x0171615141312111'u64 , 0x07c7874706c68646'u64 ]
    check ( decodeBytesToDigest(bytes) == toDigestU64(words) )

  test "decodeBytesToDigest [51..81]":
    let bytes : array[31,byte]  = [51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81]
    let words : array[4,uint64] = [ 0x3a39383736353433'u64 , 0x090500fcf8f4f0ec'u64 , 0x2494847464544434'u64 , 0x145413d3935312d2'u64 ]
    check ( decodeBytesToDigest(bytes) == toDigestU64(words) )

  test "decodeBytesToDigest [171..201]":
    let bytes : array[31,byte]  = [171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201]
    let words : array[4,uint64] = [ 0x32b1b0afaeadacab'u64 , 0x2ae6e2dedad6d2ce'u64 , 0x2c1c0bfbebdbcbbb'u64 , 0x327231f1b17130f0'u64 ]
    check ( decodeBytesToDigest(bytes) == toDigestU64(words) )

  #-----------------

  test "padAndDecodeBytes31 []":
    check U4SeqToDigestSeq( @[ [1'u64, 0'u64, 0'u64, 0'u64] ]) == padAndDecodeBytesToDigest31( @[] )

  test "padAndDecodeBytes31 [1..11]":
    let f4s : seq[U4] = @[ [0x0807060504030201'u64,0x00000000042c2824'u64,0x0000000000000000'u64,0x0000000000000000'u64] ]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest31( (1..11).toSeq().map(intToByte) )

  test "padAndDecodeBytes31 [1..30]":
    let f4s : seq[U4] = @[ [0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x0047874706c68646'u64] ]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest31( (1..30).toSeq().map(intToByte) )

  test "padAndDecodeBytes31 [1..31]":
    let f4s : seq[U4] = @[ [0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                         , [0x0000000000000001'u64,0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64]
                         ]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest31( (1..31).toSeq().map(intToByte) )

  test "padAndDecodeBytes31 [1..51]":
    let f4s : seq[U4] = @[ [0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                         , [0x2726252423222120'u64,0x3cb8b4b0aca8a4a0'u64,0x0000001333231302'u64,0x0000000000000000'u64]
                         ]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest31( (1..51).toSeq().map(intToByte) )

  test "padAndDecodeBytes31 [1..71]":
    let f4s : seq[U4] = @[ [0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                         , [0x2726252423222120'u64,0x3cb8b4b0aca8a4a0'u64,0x3363534333231302'u64,0x0f8f4f0ece8e4e0d'u64]
                         , [0x064544434241403f'u64,0x000000000000051d'u64,0x0000000000000000'u64,0x0000000000000000'u64]
                         ]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest31( (1..71).toSeq().map(intToByte) )

  #-----------------

  test "padAndDecodeBytes62 []":
    check U4SeqToDigestSeq( @[ [1'u64, 0'u64, 0'u64, 0'u64] , [0'u64, 0'u64, 0'u64, 0'u64] ]) == padAndDecodeBytesToDigest62( @[] )

  test "padAndDecodeBytes62 [1..11]":
    let f4s : seq[U4] = @[ [0x0807060504030201'u64,0x00000000042c2824'u64,0x0000000000000000'u64,0x0000000000000000'u64]
                         , [0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64] ]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest62( (1..11).toSeq().map(intToByte) )

  test "padAndDecodeBytes62 [1..31]":
    let f4s : seq[U4] = 
               @[[0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                ,[0x0000000000000001'u64,0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64]]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest62( (1..31).toSeq().map(intToByte) )

  test "padAndDecodeBytes62 [1..51]":
    let f4s : seq[U4] = 
               @[[0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                ,[0x2726252423222120'u64,0x3cb8b4b0aca8a4a0'u64,0x0000001333231302'u64,0x0000000000000000'u64]]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest62( (1..51).toSeq().map(intToByte) )

  test "padAndDecodeBytes62 [1..61]":
    let f4s : seq[U4] = 
               @[[0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                ,[0x2726252423222120'u64,0x3cb8b4b0aca8a4a0'u64,0x3363534333231302'u64,0x004f4f0ece8e4e0d'u64]]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest62( (1..61).toSeq().map(intToByte) )

  test "padAndDecodeBytes62 [1..62]":
    let f4s : seq[U4] = 
               @[[0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                ,[0x2726252423222120'u64,0x3cb8b4b0aca8a4a0'u64,0x3363534333231302'u64,0x0f8f4f0ece8e4e0d'u64]
                ,[0x0000000000000001'u64,0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64]
                ,[0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64]]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest62( (1..62).toSeq().map(intToByte) )

  test "padAndDecodeBytes62 [1..71]":
    let f4s : seq[U4] = 
               @[[0x0807060504030201'u64,0x003c3834302c2824'u64,0x0171615141312111'u64,0x07c7874706c68646'u64]
                ,[0x2726252423222120'u64,0x3cb8b4b0aca8a4a0'u64,0x3363534333231302'u64,0x0f8f4f0ece8e4e0d'u64]
                ,[0x064544434241403f'u64,0x000000000000051d'u64,0x0000000000000000'u64,0x0000000000000000'u64]
                ,[0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64,0x0000000000000000'u64]]
    check U4SeqToDigestSeq(f4s) == padAndDecodeBytesToDigest62( (1..71).toSeq().map(intToByte) )

##-------------------------------------------------------------------------------
#