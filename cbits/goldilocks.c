
#include <stdint.h>
#include <stdio.h>      // for testing only

#include "goldilocks.h"

//==============================================================================
// *** Goldilocks field ***

uint64_t goldilocks_neg(uint64_t x) {
  return (x==0) ? 0 : (GOLDILOCKS_PRIME - x);
}

uint64_t goldilocks_add(uint64_t x, uint64_t y) {
  uint64_t z = x + y;
  return ( (z >= GOLDILOCKS_PRIME) || (z<x) ) ? (z - GOLDILOCKS_PRIME) : z;
}

uint64_t goldilocks_sub(uint64_t x, uint64_t y) {
  uint64_t z = x - y;
  return (z > x) ? (z + GOLDILOCKS_PRIME) : z;
}

uint64_t goldilocks_sub_safe(uint64_t x, uint64_t y) {
  return goldilocks_add( x , goldilocks_neg(y) );
}

/*

// add together 3 field elements
uint64_t goldilocks_add3( uint64_t x0, uint64_t x1, uint64_t x2 ) {
  uint64_t x01 = goldilocks_add( x0 , x1  );
  return goldilocks_add( x01, x2 );
}

//--------------------------------------

uint64_t goldilocks_div_by_2(uint64_t x) {
  return (x & 1) ? (x/2 + 0x7fffffff80000001) : (x/2);
}

uint64_t goldilocks_div_by_3(uint64_t x) {
  uint64_t m = x % 3;
  uint64_t r;
  switch(m) {
    case 0:
      r = (x/3);
      break;
    case 1:
      r = (x/3 + 0xaaaaaaaa00000001);      // (x+2*p) / 3 = x/3 + (2*p+1)/3
      break;
    case 2:
      r = (x/3 + 0x5555555500000001);      // (x+p) / 3 = x/3 + (p+1)/3 
      break;
  }
  return r;
}

uint64_t goldilocks_div_by_4(uint64_t x) {
  return goldilocks_div_by_2(goldilocks_div_by_2(x));
}

*/

//--------------------------------------

uint64_t goldilocks_rdc(__uint128_t x) {
  // x = n0 + 2^64 * n1 + 2^96 * n2
  uint64_t n0 = (uint64_t)x;
  uint64_t n1 = (x >> 64) & 0xffffffff;
  uint64_t n2 = (x >> 96);
  
  uint64_t mid = (n1 << 32) - n1;     // (2^32 - 1) * n1
  uint64_t tmp = n0 + mid;
  if (tmp < n0) { tmp -= GOLDILOCKS_PRIME; }

  uint64_t res = tmp - n2;
  if (res > tmp) { res += GOLDILOCKS_PRIME; }
  return (res >= GOLDILOCKS_PRIME) ? (res - GOLDILOCKS_PRIME) : res;
}

// reduce to 64-bit, but it can be still bigger than `p`
uint64_t goldilocks_rdc_to_uint64(__uint128_t x) {
  // x = n0 + 2^64 * n1 + 2^96 * n2
  uint64_t n0 = (uint64_t)x;
  uint64_t n1 = (x >> 64) & 0xffffffff;
  uint64_t n2 = (x >> 96);
  
  uint64_t mid = (n1 << 32) - n1;     // (2^32 - 1) * n1
  uint64_t tmp = n0 + mid;
  if (tmp < n0) { tmp -= GOLDILOCKS_PRIME; }

  uint64_t res = tmp - n2;
  if (res > tmp) { res += GOLDILOCKS_PRIME; }
  return res;
}

// we assume x < 2^96
uint64_t goldilocks_rdc_small(__uint128_t x) {
  // x = n0 + 2^64 * n1
  uint64_t n0 = (uint64_t)x;
  uint64_t n1 = (x >> 64);

  uint64_t mid = (n1 << 32) - n1;     // (2^32 - 1) * n1
  uint64_t tmp = n0 + mid;
  if (tmp < n0) { tmp -= GOLDILOCKS_PRIME; }

  uint64_t res = tmp;
  return (res >= GOLDILOCKS_PRIME) ? (res - GOLDILOCKS_PRIME) : res;
}

//--------------------------------------

uint64_t goldilocks_mul(uint64_t x, uint64_t y) {
  __uint128_t z = (__uint128_t)x * (__uint128_t)y;
  return goldilocks_rdc(z); 
}

uint64_t goldilocks_mul_add128(uint64_t x, uint64_t y, __uint128_t z) {
  __uint128_t w = (__uint128_t)x * (__uint128_t)y + z;
  return goldilocks_rdc(w); 
}

uint64_t goldilocks_sqr(uint64_t x) {
  __uint128_t z = (__uint128_t)x * (__uint128_t)x;
  return goldilocks_rdc(z); 
}

uint64_t goldilocks_sqr_add(uint64_t x, uint64_t y) {
  __uint128_t z = (__uint128_t)x * x + y;
  return goldilocks_rdc(z); 
}

// only reduce to uint64, not to [0..p-1]
uint64_t goldilocks_sqr_add_to_uint64(uint64_t x, uint64_t y) {
  __uint128_t z = (__uint128_t)x * x + y;
  return goldilocks_rdc_to_uint64(z); 
}

uint64_t goldilocks_mul_small(uint64_t x, uint32_t y) {
  __uint128_t z = (__uint128_t)x * (__uint128_t)y;
  return goldilocks_rdc_small(z); 
}

//==============================================================================
// *** debugging ***

void debug_print_state(const char *msg, int n, uint64_t *state) {
  printf("-----------------\n");
  printf("%s\n",msg);
  for(int i=0;i<n;i++) {
    printf(" - 0x%016llx = %llu\n",state[i],state[i]);
  }
}

//==============================================================================
// *** Poseidon2 ***
//
// compatible with <https://github.com/HorizenLabs/poseidon2>
// NOT compatible with <https://extgit.iaik.tugraz.at/krypto/zkfriendlyhashzoo>
// (presumably they use different constants or whatever)
//

#include "poseidon2_constants.inc"

/* 
poseidon2 test vector (permutation of [0..11]) 
----------------------------------------------
from <https://github.com/HorizenLabs/poseidon2/blob/main/plain_implementations/src/poseidon2/poseidon2.rs#L284>

0x01eaef96bdf1c0c1
0x1f0d2cc525b2540c
0x6282c1dfe1e0358d
0xe780d721f698e1e6
0x280c0b6f753d833b
0x1b942dd5023156ab
0x43f0df3fcccb8398
0xe8e8190585489025
0x56bdbf72f77ada22
0x7911c32bf9dcd705
0xec467926508fbe67
0x6a50450ddf85a6ed
*/

uint64_t goldilocks_poseidon2_sbox(uint64_t x0, uint64_t rc) {
  uint64_t x  = goldilocks_add( x0 , rc );
  uint64_t x2 = goldilocks_sqr( x       );
  uint64_t x4 = goldilocks_sqr( x2      );
  uint64_t x6 = goldilocks_mul( x4 , x2 );
  uint64_t x7 = goldilocks_mul( x6 , x  );
  return x7;
}

// remark: (p-1)^2 + 12*(p-1) does not overflow in 2^128
void goldilocks_poseidon2_internal_diffusion(uint64_t *inp, uint64_t *out) {
  __uint128_t s0 = inp[0];
  __uint128_t s1 = inp[6];
  s0 += inp[1]; s1 += inp[7];
  s0 += inp[2]; s1 += inp[8];
  s0 += inp[3]; s1 += inp[9];
  s0 += inp[4]; s1 += inp[10];
  s0 += inp[5]; s1 += inp[11];
//  uint64_t s = goldilocks_rdc_small( s0 + s1 );
  __uint128_t s = s0 + s1;

  for(int i=0; i<12; i++) { 
    out[i] = goldilocks_mul_add128( inp[i] , internal_diag[i] , s );
  }
}

//--------------------------------------

/*

// multiplies a vector of size 4 by the 4x4 MDS matrix on the left:
//
//       [ 5 7 1 3 ]
//  M4 = [ 4 6 1 1 ]
//       [ 1 3 5 7 ]
//       [ 1 1 4 6 ]
//
void goldilocks_mul_by_M4(uint64_t *inp, uint64_t *out) {
  uint64_t a = inp[0];
  uint64_t b = inp[1];
  uint64_t c = inp[2];
  uint64_t d = inp[3];

  uint64_t a2 = goldilocks_add( a  , a  );
  uint64_t a4 = goldilocks_add( a2 , a2 );
  uint64_t a5 = goldilocks_add( a4 , a  );

  uint64_t b2 = goldilocks_add( b  , b  );
  uint64_t b3 = goldilocks_add( b2 , b  );
  uint64_t b6 = goldilocks_add( b3 , b3 );
  uint64_t b7 = goldilocks_add( b6 , b  );

  uint64_t c2 = goldilocks_add( c  , c  );
  uint64_t c4 = goldilocks_add( c2 , c2 );
  uint64_t c5 = goldilocks_add( c4 , c  );

  uint64_t d2 = goldilocks_add( d  , d  );
  uint64_t d3 = goldilocks_add( d2 , d  );
  uint64_t d6 = goldilocks_add( d3 , d3 );
  uint64_t d7 = goldilocks_add( d6 , d  );

  out[0] = goldilocks_add( goldilocks_add( a5 , b7 ) , goldilocks_add( c  , d3 ) );
  out[1] = goldilocks_add( goldilocks_add( a4 , b6 ) , goldilocks_add( c  , d  ) );
  out[2] = goldilocks_add( goldilocks_add( a  , b3 ) , goldilocks_add( c5 , d7 ) );
  out[3] = goldilocks_add( goldilocks_add( a  , b  ) , goldilocks_add( c4 , d6 ) );
}

// returns 2*a + b + c
uint64_t goldilocks_weighted_add_211(uint64_t a, uint64_t b, uint64_t c) {
  uint64_t a2 = goldilocks_add( a , a );
  uint64_t bc = goldilocks_add( b , c );
  return goldilocks_add( a2 , bc );
}

// multiplies by 12x12 block-circulant matrix [2*M4, M4, M4]
void goldilocks_poseidon2_external_diffusion(uint64_t *inp, uint64_t *out) {
  uint64_t us[4];
  uint64_t vs[4];
  uint64_t ws[4];

  goldilocks_mul_by_M4( inp + 0 , us );
  goldilocks_mul_by_M4( inp + 4 , vs );
  goldilocks_mul_by_M4( inp + 8 , ws );

  out[0]  = goldilocks_weighted_add_211( us[0] , vs[0] , ws[0] );
  out[1]  = goldilocks_weighted_add_211( us[1] , vs[1] , ws[1] );
  out[2]  = goldilocks_weighted_add_211( us[2] , vs[2] , ws[2] );
  out[3]  = goldilocks_weighted_add_211( us[3] , vs[3] , ws[3] );

  out[4]  = goldilocks_weighted_add_211( vs[0] , ws[0] , us[0] );
  out[5]  = goldilocks_weighted_add_211( vs[1] , ws[1] , us[1] );
  out[6]  = goldilocks_weighted_add_211( vs[2] , ws[2] , us[2] );
  out[7]  = goldilocks_weighted_add_211( vs[3] , ws[3] , us[3] );

  out[ 8] = goldilocks_weighted_add_211( ws[0] , us[0] , vs[0] );
  out[ 9] = goldilocks_weighted_add_211( ws[1] , us[1] , vs[1] );
  out[10] = goldilocks_weighted_add_211( ws[2] , us[2] , vs[2] );
  out[11] = goldilocks_weighted_add_211( ws[3] , us[3] , vs[3] );
}

*/

//--------------------------------------

// multiplies a vector of size 4 by the 4x4 MDS matrix on the left
void uint64_mul_by_M4(uint64_t *inp, uint64_t *out) {
  uint64_t a = inp[0];
  uint64_t b = inp[1];
  uint64_t c = inp[2];
  uint64_t d = inp[3];

  uint64_t a4 = a << 2;
  uint64_t a5 = a4 + a;

  uint64_t b2 = b  + b  ;
  uint64_t b3 = b2 + b  ;
  uint64_t b6 = b3 + b3 ;
  uint64_t b7 = b6 + b  ;

  uint64_t c4 = c << 2 ;
  uint64_t c5 = c4 + c ;

  uint64_t d2 = d  + d  ;
  uint64_t d3 = d2 + d  ;
  uint64_t d6 = d3 + d3 ;
  uint64_t d7 = d6 + d  ;

  out[0] = a5 + b7 + c  + d3 ;
  out[1] = a4 + b6 + c  + d  ;
  out[2] = a  + b3 + c5 + d7 ;
  out[3] = a  + b  + c4 + d6 ;
}

// multiplies by 12x12 block-circulant matrix [2*M4, M4, M4]
void uint64_mul_by_poseidon2_circulant12(uint64_t *inp, uint64_t *out) {
  uint64_t us[4];
  uint64_t vs[4];
  uint64_t ws[4];

  uint64_mul_by_M4( inp + 0 , us );
  uint64_mul_by_M4( inp + 4 , vs );
  uint64_mul_by_M4( inp + 8 , ws );

  out[0]  = 2*us[0] + vs[0] + ws[0];
  out[1]  = 2*us[1] + vs[1] + ws[1];
  out[2]  = 2*us[2] + vs[2] + ws[2];
  out[3]  = 2*us[3] + vs[3] + ws[3];

  out[4]  = us[0] + 2*vs[0] + ws[0];
  out[5]  = us[1] + 2*vs[1] + ws[1];
  out[6]  = us[2] + 2*vs[2] + ws[2];
  out[7]  = us[3] + 2*vs[3] + ws[3];

  out[ 8] = us[0] + vs[0] + 2*ws[0];
  out[ 9] = us[1] + vs[1] + 2*ws[1];
  out[10] = us[2] + vs[2] + 2*ws[2];
  out[11] = us[3] + vs[3] + 2*ws[3];
}

void goldilocks_poseidon2_external_diffusion_split(uint64_t *inp, uint64_t *out) {
  uint64_t inp_lo[12];
  uint64_t inp_hi[12];
  uint64_t out_lo[12];
  uint64_t out_hi[12];

  for(int i=0; i<12; i++) { 
    uint64_t x = inp[i];
    inp_lo[i] = x & 0xffffffff;
    inp_hi[i] = x >> 32;
  }

  uint64_mul_by_poseidon2_circulant12(inp_lo, out_lo);
  uint64_mul_by_poseidon2_circulant12(inp_hi, out_hi);

  for(int i=0; i<12; i++) {
    __uint128_t x = (((__uint128_t)out_hi[i]) << 32) + out_lo[i];
    out[i] = goldilocks_rdc_small(x);
  }
}

//--------------------------------------

// 0 <= round_idx < 22
void goldilocks_poseidon2_internal_round(int round_idx, uint64_t *state) {
  state[0] = goldilocks_poseidon2_sbox( state[0] , internal_round_consts[round_idx] );
  goldilocks_poseidon2_internal_diffusion( state, state );
}

void goldilocks_poseidon2_external_round(const uint64_t *rcs, uint64_t *state) {
  for (int i=0; i<12; i++) {
    state[i] = goldilocks_poseidon2_sbox( state[i] , rcs[i] );
  }
  goldilocks_poseidon2_external_diffusion_split( state, state );
}

void goldilocks_poseidon2_permutation(uint64_t *state) {
  goldilocks_poseidon2_external_diffusion_split( state, state );
  goldilocks_poseidon2_external_round( intial_round_consts + 0  , state );
  goldilocks_poseidon2_external_round( intial_round_consts + 12 , state );
  goldilocks_poseidon2_external_round( intial_round_consts + 24 , state );
  goldilocks_poseidon2_external_round( intial_round_consts + 36 , state );
  for(int idx=0; idx<22; idx++) {
    goldilocks_poseidon2_internal_round( idx, state );
  }
  goldilocks_poseidon2_external_round( final_round_consts + 0  , state );
  goldilocks_poseidon2_external_round( final_round_consts + 12 , state );
  goldilocks_poseidon2_external_round( final_round_consts + 24 , state );
  goldilocks_poseidon2_external_round( final_round_consts + 36 , state );
}

//------------------------------------------------------------------------------

// compression function: input is two 4-element vector of field elements, 
// and the output is a vector of 4 field elements
void goldilocks_poseidon2_keyed_compress(uint64_t key, const uint64_t *x, const uint64_t *y, uint64_t *out) {
  uint64_t state[12];
  for(int i=0; i<4; i++) {
    state[i  ] = x[i];
    state[i+4] = y[i];
    state[i+8] = 0;
  }
  state[8] = key;
  goldilocks_poseidon2_permutation(state);
  for(int i=0; i<4; i++) {
    out[i] = state[i];
  }
}

void goldilocks_poseidon2_compress(const uint64_t *x, const uint64_t *y, uint64_t *out) {
  goldilocks_poseidon2_keyed_compress(0, x, y, out);
}

//------------------------------------------------------------------------------
