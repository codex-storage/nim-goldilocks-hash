
#include <stdint.h>

//------------------------------------------------------------------------------

#define GOLDILOCKS_PRIME 0xffffffff00000001

//------------------------------------------------------------------------------

uint64_t goldilocks_neg(uint64_t x);
uint64_t goldilocks_add(uint64_t x, uint64_t y);
uint64_t goldilocks_sub(uint64_t x, uint64_t y);
uint64_t goldilocks_mul(uint64_t x, uint64_t y);
uint64_t goldilocks_mul_small(uint64_t x, uint32_t y);

//------------------------------------------------------------------------------

void goldilocks_poseidon2_permutation   (uint64_t *state);
void goldilocks_poseidon2_keyed_compress(const uint64_t *x, const uint64_t *y, uint64_t key, uint64_t *out);
void goldilocks_poseidon2_compress      (const uint64_t *x, const uint64_t *y,               uint64_t *out);
void goldilocks_poseidon2_bytes_digest  (int rate, int N, const uint8_t  *input, uint64_t *hash);
void goldilocks_poseidon2_felts_digest  (int rate, int N, const uint64_t *input, uint64_t *hash);

//--------------------------------------

void goldilocks_monolith_permutation   (uint64_t *state);
void goldilocks_monolith_keyed_compress(const uint64_t *x, const uint64_t *y, uint64_t key, uint64_t *out);
void goldilocks_monolith_compress      (const uint64_t *x, const uint64_t *y,               uint64_t *out);
void goldilocks_monolith_bytes_digest  (int rate, int N, const uint8_t  *input, uint64_t *hash);
void goldilocks_monolith_felts_digest  (int rate, int N, const uint64_t *input, uint64_t *hash);

//------------------------------------------------------------------------------
