
import std/bitops
import types

#-------------------------------------------------------------------------------

func uint64ToBytesLE*(what: uint64): array[8, byte] =
  var   bytes : array[8,byte]
  var   x     : uint64 = what
  const mask  : uint64 = 0xff
  for i in 0..<8:
    bytes[i] = byte(bitand(x,mask))
    x = x shr 8
  return bytes

proc uint64ToBytesIntoLE[n: static int](what: uint64, tgt: var array[n,byte], ofs: int) =
  var   x    : uint64 = what
  const mask : uint64 = 0xff
  for i in 0..<8:
    tgt[ofs + i] = byte(bitand(x,mask))
    x = x shr 8

#---------------------------------------

# simply store a hash digest (4 Goldilocks field elements) as 32 bytes,
# encoding them as 64 bit little-endian integers
func digestToBytes*(digest: Digest): array[32, byte] =
  let arr   : F4 = fromDigest(digest)
  var bytes : array[32,byte]
  uint64ToBytesIntoLE[32]( fromF(arr[0]) , bytes , 0  )
  uint64ToBytesIntoLE[32]( fromF(arr[1]) , bytes , 8  )
  uint64ToBytesIntoLE[32]( fromF(arr[2]) , bytes , 16 )
  uint64ToBytesIntoLE[32]( fromF(arr[3]) , bytes , 24 )
  return bytes

#-------------------------------------------------------------------------------

func bytesToUint64FromLE(bytes: openarray[byte], ofs: int): uint64 =
  assert( ofs+7 < bytes.len )
  var x: uint64 = 0
  for i in 0..<8:
    x = x shl 8
    x = bitor( x , uint64(bytes[ofs+7-i]) )
  return x

func bytesToUint64LE*(bytes: array[8, byte]): uint64 = bytesToUint64FromLE(bytes, 0)

#-------------------------------------------------------------------------------

func decodeBytesToDigestFrom(bytes: openarray[byte], ofs: int): Digest =
  const mask : uint64 = 0x3fffffffffffffff'u64
  let p = bytesToUint64FromLE( bytes , ofs +  0 )
  let q = bytesToUint64FromLE( bytes , ofs +  7 )
  let r = bytesToUint64FromLE( bytes , ofs + 15 )
  let s = bytesToUint64FromLE( bytes , ofs + 23 )

  let a = bitand( p       , mask )
  let b = bitor(  q shr 6 , bitand(r , 0x0f) shl 58 )
  let c = bitor(  r shr 4 , bitand(s , 0x03) shl 60 )
  let d =         s shr 2

  return mkDigestU64(a,b,c,d)   

# takes 31 bytes (not 32!) and creates a unique Digest out of them
# this is used when hashing byte sequences (also to be a drop-in replacement for the BN254 field)
# what we do is we divide into 4 pieces of size 62 bits, and interpret
# them as little-endian integers, and further interpret those as field elements
func decodeBytesToDigest*(bytes: array[31, byte]): Digest = decodeBytesToDigestFrom( bytes, 0 )

#-------------------------------------------------------------------------------

# pad to a multiple of 31 bytes (with the 10* padding strategy) and decode into a sequence of digests
func padAndDecodeBytesToDigest31*(bytes: openarray[byte]): seq[Digest] =
  let m  = bytes.len
  let n1 = m div 31
  let n  = n1 + 1
  let r  = n*31 - m      # 1 <= r <= 31
  let q  = 31 - r        # 0 <= q <= 30

  var ds : seq[Digest] = newSeq[Digest](n)

  for i in 0..<n1:
    ds[i] = decodeBytesToDigestFrom(bytes, 31*i)

  var last : array[31,byte]
  for i in 0..<q: last[i] = bytes[31*n1 + i]
  last[q] = 0x01
  ds[n1] = decodeBytesToDigest(last)

  return ds

#---------------------------------------

# pad to a multiple of 62 bytes (with the 10* padding strategy) and decode into a sequence of digests
func padAndDecodeBytesToDigest62*(bytes: openarray[byte]): seq[Digest] =
  let m  = bytes.len
  let n1 = m div 62
  let n  = n1 + 1
  let r  = n*62 - m      # 1 <= r <= 62
  let q  = 62 - r        # 0 <= q <= 61

  var ds : seq[Digest] = newSeq[Digest](2*n)

  for i in 0..<2*n1:
    ds[i] = decodeBytesToDigestFrom(bytes, 31*i)

  var last : array[62,byte]
  for i in 0..<q: last[i] = bytes[62*n1 + i]
  last[q] = 0x01

  ds[2*n1  ] = decodeBytesToDigestFrom(last, 0 )
  ds[2*n1+1] = decodeBytesToDigestFrom(last, 31)

  return ds

#-------------------------------------------------------------------------------
