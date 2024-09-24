Nim/C implementation of Poseidon2 over the Goldilocks field
===========================================================

Experimental implementation of the [Poseidon2][1] cryptographic hash function,
specialized to the Goldilocks field `p=2^64-2^32+1` and `t=12`. 
Uses a C implementation internally.

Installation
------------

Use the [Nimble][2] package manager to add `poseidon2-goldilocks` to an existing
project. Add the following to its `.nimble` file:

```nim
requires "poseidon2-goldilocks >= 0.0.1 & < 0.0.1"
```

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
