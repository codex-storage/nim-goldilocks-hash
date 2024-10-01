
# binary merkle trees, where the nodes and leaves are four-tuples of field elements
#
# we use a custom "safe" merkle tree API, so that:
#
# - there is no collision between different input lengths
# - there is no collision if you remove the bottommost layer (or several layers)
# - the merkle root of the singleton is not itself

import ./types
import ./compress
#import ./io

#-------------------------------------------------------------------------------

const KeyNone              : uint64 = 0x0
const KeyBottomLayer       : uint64 = 0x1
const KeyOdd               : uint64 = 0x2
const KeyOddAndBottomLayer : uint64 = 0x3

#-------------------------------------------------------------------------------

type Merkle* = object
  todo : seq[Digest]  # nodes that haven't been combined yet
  width: int          # width of the current subtree
  leafs: int          # amount of leafs processed

func init*(_: type Merkle): Merkle =
  Merkle(width: 2)

func internalCompress(merkle: var Merkle, odd: static bool) =
  when odd:
    let a = merkle.todo.pop()
    let b = zeroDigest
    let key = if merkle.width == 2: KeyOddAndBottomLayer else: KeyOdd
    merkle.todo.add(compress(a, b, key = key))
    merkle.leafs += merkle.width div 2 # zero node represents this many leafs
  else:
    let b = merkle.todo.pop()
    let a = merkle.todo.pop()
    let key = if merkle.width == 2: KeyBottomLayer else: KeyNone
    merkle.todo.add(compress(a, b, key = key))
  merkle.width *= 2

func update*(merkle: var Merkle, element: Digest) =
  merkle.todo.add(element)
  inc merkle.leafs
  merkle.width = 2
  while merkle.width <= merkle.leafs and merkle.leafs mod merkle.width == 0:
    merkle.internalCompress(odd = false)

func finish*(merkle: var Merkle): Digest =
  assert merkle.todo.len > 0, "merkle root of empty sequence is not defined"

  if merkle.leafs == 1:
    merkle.internalCompress(odd = true)

  while merkle.todo.len > 1:
    if merkle.leafs mod merkle.width == 0:
      merkle.internalCompress(odd = false)
    else:
      merkle.internalCompress(odd = true)

  return merkle.todo[0]

func digest*(_: type Merkle, elements: openArray[Digest]): Digest =
  var merkle = Merkle.init()
  for element in elements:
    merkle.update(element)
  return merkle.finish()

func merkleRoot*(elements: openArray[Digest]): Digest = Merkle.digest(elements)

#-------------------------------------------------------------------------------


