
#include <stdint.h>

//------------------------------------------------------------------------------

#define GOLDILOCKS_PRIME 0xffffffff00000001

//------------------------------------------------------------------------------

uint64_t goldilocks_neg(uint64_t x);
uint64_t goldilocks_add(uint64_t x, uint64_t y);
uint64_t goldilocks_sub(uint64_t x, uint64_t y);
uint64_t goldilocks_mul(uint64_t x, uint64_t y);
uint64_t goldilocks_mul_small(uint64_t x, uint32_t y);

uint64_t goldilocks_div_by_2(uint64_t x);
uint64_t goldilocks_div_by_3(uint64_t x);
uint64_t goldilocks_div_by_4(uint64_t x);

uint64_t goldilocks_add3(uint64_t x, uint64_t y, uint64_t z);

//uint64_t goldilocks_rdc(__uint128_t x);

//------------------------------------------------------------------------------

void goldilocks_poseidon2_permutation(uint64_t *state);
void goldilocks_monolith_permutation (uint64_t *state);

void monolith_print_sbox_table();
void monolith_print_sbox_table_c_format();

//------------------------------------------------------------------------------
