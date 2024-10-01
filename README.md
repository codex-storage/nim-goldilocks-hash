Nim/C implementation of Poseidon2 over the Goldilocks field
===========================================================

Experimental implementation of the [Poseidon2][1] cryptographic hash function,
specialized to the Goldilocks field `p = 2^64-2^32+1` and `t = 12`. 
Uses a C implementation internally.

The implementation is compatible with Horizen Lab's one at [3]

Installation
------------

Use the [Nimble][2] package manager to add `poseidon2-goldilocks` to an existing
project. Add the following to its `.nimble` file:

```nim
requires "poseidon2-goldilocks >= 0.0.1 & < 0.0.1"
```

Conventions
-----------

Hash digests consist of 4 field elements (approximately 256 bits). 

When constructing binary Merkle trees, we similarly work on units of 4 field 
elements.

When hashing bytes, first we pad the byte sequence to a multiple of 31 bytes using 
the `10*` padding strategy, and then we convert each 31 byte piece into 4 field 
elements by using the lowest 62 bits. We do this for two reasons: 1) to be a 
drop-in replacement for the BN254 implementation which also takes 31 bytes at 
a time; and 2) because hashing 31/62 bytes with one permutation is almost 11% 
more efficient than using only 28/56 bytes at a time.

Usage
-----

Hashing bytes into a field element with the sponge construction:
```nim
import poseidon2_goldilocks

let input = [1'u8, 2'u8, 3'u8] # some bytes that you want to hash
let digest: F = Sponge.digest(input) # a field element
```

Converting a hash digest (4 field elements) into bytes:
```nim
let output: array[32, byte] = digest.toBytes
```

Combining field elements, useful for constructing a binary Merkle tree:
```nim
let left  = Sponge.digest([1'u8, 2'u8, 3'u8])
let right = Sponge.digest([4'u8, 5'u8, 6'u8])
let combination = compress(left, right)
```

[1]: https://eprint.iacr.org/2023/323.pdf
[2]: https://github.com/nim-lang/nimble
[3]: https://github.com/HorizenLabs/poseidon2
