Nim / C implementations of arithmetic hash functions over the Goldilocks field
==============================================================================

Experimental implementation of arithmetic hash functions (like for example 
[Poseidon2][1] and [Monolith][2]) specialized to the Goldilocks field 
`p = 2^64 - 2^32 + 1`. Mostly uses C implementations internally.

Hash functions supported
------------------------

- [x] Poseidon2 with `t=12`
- [x] Monolith with `t=12`
- [ ] Tip4' with `t=12`

The Poseidon2 permutation is compatible with [Horizen Lab's one][4].
The Monolith permutation is compatible with [ZKFriendlyHashZoo][6].


Installation
------------

Use the [Nimble][3] package manager to add `goldilocks_hash` to an existing
project. Add the following to its `.nimble` file:

```nim
requires "goldilocks_hash >= 0.0.1 & < 1.0.0"
```

Conventions
-----------

Hash digests consist of 4 field elements (approximately 256 bits). 

When constructing binary Merkle trees, we similarly work on units of 4 field 
elements. We use a custom "safe" Merkle tree building convention, which ensures
that different input sequences can never produce the same Merkle root (except with 
negligible probability).

When hashing bytes, first we pad the byte sequence to a multiple of 31 (or 62) bytes using 
the `10*` padding strategy, and then we convert each 31 byte piece into 4 field 
elements by filling their lowest 62 bits (note that 31 bytes = 248 bits = 4 x 62 bits). 
We do this for two reasons: 1) to be a drop-in replacement for the BN254 implementation 
which also takes 31 bytes at a time; and 2) because hashing 31 (or 62) bytes with one permutation 
is almost 11% more efficient than using only 28 (or 56) bytes at a time.

When hashing field elements, similarly we pad using the `10*` strategy. Domain
separation ensures that using different sponge rates, or different types of
input won't produce the same hash.


Usage
-----

Hashing bytes into with the sponge construction:
```nim
import goldilocks_hash/poseidon2

let input = [1'u8, 2'u8, 3'u8]                 # some bytes that you want to hash
let digest: Digest = Sponge.digest(input) 
```

Converting a hash digest (4 field elements) into bytes:
```nim
let output: array[32, byte] = digest.toBytes
```

Combining field elements, useful for constructing a binary Merkle tree:
```nim
let left  = Sponge.digest( [1'u8, 2'u8, 3'u8] )
let right = Sponge.digest( [4'u8, 5'u8, 6'u8] )
let combination = compress(left, right)
```

Building Merkle trees:
```nim
let input: seq[Digest] = ...
let digest: F = Merkle.digest(input) 
```

[1]: https://eprint.iacr.org/2023/323
[2]: https://eprint.iacr.org/2023/1025
[3]: https://github.com/nim-lang/nimble
[4]: https://github.com/HorizenLabs/poseidon2
[5]: https://github.com/HorizenLabs/monolith
[6]: https://extgit.iaik.tugraz.at/krypto/zkfriendlyhashzoo

