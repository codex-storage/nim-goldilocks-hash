
#include <stdint.h>
#include <stdio.h>      // for testing only
#include <assert.h>

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
  __uint128_t s = s0 + s1;

  for(int i=0; i<12; i++) { 
    out[i] = goldilocks_mul_add128( inp[i] , internal_diag[i] , s );
  }
}

//--------------------------------------

// multiplies a vector of size 4 by the 4x4 MDS matrix on the left:
//
//       [ 5 7 1 3 ]
//  M4 = [ 4 6 1 1 ]
//       [ 1 3 5 7 ]
//       [ 1 1 4 6 ]
//
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
void goldilocks_poseidon2_keyed_compress(const uint64_t *x, const uint64_t *y, uint64_t key, uint64_t *out) {
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
  goldilocks_poseidon2_keyed_compress(x, y, 0, out);
}

//------------------------------------------------------------------------------

// hash a sequence of field elements into a digest of 4 field elements
void goldilocks_poseidon2_felts_digest(int rate, int N, const uint64_t *input, uint64_t *hash) {
  // printf("rate = %d\n",rate);
  // printf("N    = %d\n",N   );

  assert( (rate >= 1) && (rate <= 8) );

  uint64_t domsep = rate + 256*12 + 65536*63;
  uint64_t state[12];
  for(int i=0; i<12; i++) state[i] = 0;
  state[8] = domsep;

  int nchunks = (N + rate) / rate;       // 10* padding
  const uint64_t *ptr = input;
  for(int k=0; k<nchunks-1; k++) {
    for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] , ptr[j] ); }
    goldilocks_poseidon2_permutation( state );
    ptr += rate;
  }

  int rem = nchunks*rate - N;       // 0 < rem <= rate
  int ofs = rate - rem; 

  // the last block, with padding
  uint64_t last[8];
  for(int i=0    ; i<ofs ; i++) last[i] = ptr[i];
  for(int i=ofs+1; i<rate; i++) last[i] = 0;
  last[ofs] = 0x01;
  for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] , last[j] ); }
  goldilocks_poseidon2_permutation( state );

  for(int j=0; j<4; j++) { hash[j] = state[j]; }
}

//--------------------------------------

#define MASK 0x3fffffffffffffffULL

// NOTE: we assume a little-endian architecture
void goldilocks_convert_31_bytes_to_4_field_elements(const uint8_t *ptr, uint64_t *felts) {
  const uint64_t *q0  = (const uint64_t*)(ptr   );
  const uint64_t *q7  = (const uint64_t*)(ptr+ 7);
  const uint64_t *q15 = (const uint64_t*)(ptr+15);
  const uint64_t *q23 = (const uint64_t*)(ptr+23);

  felts[0] =  (q0 [0]) & MASK;
  felts[1] = ((q7 [0]) >> 6) | ((uint64_t)(ptr[15] & 0x0f) << 58);
  felts[2] = ((q15[0]) >> 4) | ((uint64_t)(ptr[23] & 0x03) << 60); 
  felts[3] = ((q23[0]) >> 2);
}

void goldilocks_convert_bytes_to_field_elements(int rate, const uint8_t *ptr, uint64_t *felts) {
  switch(rate) {

    case 4:
      goldilocks_convert_31_bytes_to_4_field_elements(ptr, felts);
      break;

    case 8:
      goldilocks_convert_31_bytes_to_4_field_elements(ptr   , felts  ); 
      goldilocks_convert_31_bytes_to_4_field_elements(ptr+31, felts+4);
      break;

    default:
      assert( 0 );
      break;
  }
}

void goldilocks_poseidon2_bytes_digest(int rate, int N, const uint8_t *input, uint64_t *hash) {
  // printf("rate = %d\n",rate);
  // printf("N    = %d\n",N   );

  assert( (rate == 4) || (rate == 8) );

  uint64_t domsep = rate + 256*12 + 65536*8;
  uint64_t state[12];
  for(int i=0; i<12; i++) state[i] = 0;
  state[8] = domsep;

  uint64_t felts[8];

  int rate_in_bytes  = 31 * (rate>>2);                   // 31 or 62
  int nchunks = (N + rate_in_bytes) / rate_in_bytes;     // 10* padding
  const uint8_t *ptr = input;
  for(int k=0; k<nchunks-1; k++) {
    goldilocks_convert_bytes_to_field_elements(rate, ptr, felts);
    for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] , felts[j] ); }
    goldilocks_poseidon2_permutation( state );
    ptr += rate_in_bytes;
  }

  int rem = nchunks*rate_in_bytes - N;       // 0 < rem <= rate_in_bytes 
  int ofs = rate_in_bytes - rem; 
  uint8_t last[62];

  // last block, with padding
  for(int i=0    ; i<ofs          ; i++) last[i] = ptr[i];
  for(int i=ofs+1; i<rate_in_bytes; i++) last[i] = 0;
  last[ofs] = 0x01;
  goldilocks_convert_bytes_to_field_elements(rate, last, felts);
  for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] ,felts[j] ); }
  goldilocks_poseidon2_permutation( state );

  for(int j=0; j<4; j++) { hash[j] = state[j]; }
}

//==============================================================================
// *** Monolith hash ***
//
// compatible with <https://extgit.iaik.tugraz.at/krypto/zkfriendlyhashzoo>
//

/* 
monolith test vector (permutation of [0..11]) 
---------------------------------------------
from <https://extgit.iaik.tugraz.at/krypto/zkfriendlyhashzoo/-/blob/master/plain_impls/src/monolith_64/monolith_64.rs?ref_type=heads#L653>

0x516dd661e959f541 = 5867581605548782913
0x082c137169707901 = 588867029099903233
0x53dff3fd9f0a5beb = 6043817495575026667
0x0b2ebaa261590650 = 805786589926590032
0x89aadb57e2969cb6 = 9919982299747097782
0x5d3d6905970259bd = 6718641691835914685
0x6e5ac1a4c0cfa0fe = 7951881005429661950
0xd674b7736abfc5ce = 15453177927755089358
0x0d8697e1cd9a235f = 974633365445157727
0x85fc4017c247136e = 9654662171963364206
0x572bafd76e511424 = 6281307445101925412
0xbec1638e28eae57f = 13745376999934453119

*/

//--------------------------------------
// ** sbox layer

// based on the reference implementation from 
// <https://extgit.iaik.tugraz.at/krypto/zkfriendlyhashzoo>
uint64_t goldilocks_monolith_single_bar(uint64_t x) {
//  uint64_t y1 = ((x & 0x8080808080808080) >> 7) | ((x & 0x7F7F7F7F7F7F7F7F) << 1); 
//  uint64_t y2 = ((x & 0xC0C0C0C0C0C0C0C0) >> 6) | ((x & 0x3F3F3F3F3F3F3F3F) << 2); 
//  uint64_t y3 = ((x & 0xE0E0E0E0E0E0E0E0) >> 5) | ((x & 0x1F1F1F1F1F1F1F1F) << 3); 
//  uint64_t z  = x ^ ((~y1) & y2 & y3);
//  uint64_t r  = ((z  & 0x8080808080808080) >> 7) | ((z  & 0x7F7F7F7F7F7F7F7F) << 1);

  const uint64_t mask80 = 0x8080808080808080;
  const uint64_t mask7F = ~mask80;
  uint64_t y1 = ((x  & mask80) >> 7) | ((x  & mask7F) << 1); 
  uint64_t y2 = ((y1 & mask80) >> 7) | ((y1 & mask7F) << 1); 
  uint64_t y3 = ((y2 & mask80) >> 7) | ((y2 & mask7F) << 1); 
  uint64_t z  = x ^ ((~y1) & y2 & y3);
  uint64_t r  = ((z  & mask80) >> 7) | ((z  & mask7F) << 1);
  return r;
}

// the sbox-layer (note: it's only applied to the first 4 field elements!)
void goldilocks_monolith_bars(uint64_t *state) {
  for(int j=0; j<4; j++) { state[j] = goldilocks_monolith_single_bar(state[j]); }
}

//--------------------------------------
// ** nonlinear layer

// the nonlinear layer
//
// remark: since the next layer is always the linear diffusion, it's enough
// to reduce to 64 bit, don't have to reduce to [0..p-1]. 
// As in the linear layer we split into two 32 bit words anyway.
void goldilocks_monolith_bricks(uint64_t *state) {
  for(int i=11; i>0; i--) state[i] = goldilocks_sqr_add_to_uint64( state[i-1] , state[i] );
}

//--------------------------------------
// ** fast diffusion layer

#include "monolith_conv_uint64.inc"

// we split the input to low and high 32 bit words
// do circular convolution on them, which safe because there is no overflow in 64 bit words
// but should be much faster as there are no modulo operations just 64-bit machine word ops
// then reconstruct and reduce at the end
void goldilocks_monolith_concrete(uint64_t *state) {
  uint64_t lo[12];
  uint64_t hi[12];
 
  for(int i=0; i<12; i++) { 
    uint64_t x = state[i];
    lo[i] = x & 0xffffffff;
    hi[i] = x >> 32;
  }

  uint64_circular_conv_12_with( lo , lo );
  uint64_circular_conv_12_with( hi , hi );

  for(int i=0; i<12; i++) {
    __uint128_t x = (((__uint128_t)hi[i]) << 32) + lo[i];
    state[i] = goldilocks_rdc_small(x);
  }
}

void goldilocks_monolith_concrete_rc(uint64_t *state, const uint64_t *rc) {
  uint64_t lo[12];
  uint64_t hi[12];
 
  for(int i=0; i<12; i++) { 
    uint64_t x = state[i];
    lo[i] = x & 0xffffffff;
    hi[i] = x >> 32;
  }

  uint64_circular_conv_12_with( lo , lo );
  uint64_circular_conv_12_with( hi , hi );

  for(int i=0; i<12; i++) {
    __uint128_t x = (((__uint128_t)hi[i]) << 32) + lo[i] + rc[i];
    state[i] = goldilocks_rdc_small(x);
  }
}

//--------------------------------------
// ** rounds

#include "monolith_constants.inc"

void goldilocks_monolith_round(int round_idx, uint64_t *state) {
  goldilocks_monolith_bars       (state);
  goldilocks_monolith_bricks     (state);
  goldilocks_monolith_concrete_rc(state , &(monolith_t12_round_constants[round_idx][0]) );
}

void goldilocks_monolith_permutation(uint64_t *state) {
  // initial layer
  goldilocks_monolith_concrete(state);
  // five rounds with RC
  for(int r=0; r<5; r++) {
    goldilocks_monolith_round(r, state);
  }
  // last round, no RC
  goldilocks_monolith_bars    (state);
  goldilocks_monolith_bricks  (state);
  goldilocks_monolith_concrete(state);
}

//------------------------------------------------------------------------------

// compression function: input is two 4-element vector of field elements, 
// and the output is a vector of 4 field elements
void goldilocks_monolith_keyed_compress(const uint64_t *x, const uint64_t *y, uint64_t key, uint64_t *out) {
  uint64_t state[12];
  for(int i=0; i<4; i++) {
    state[i  ] = x[i];
    state[i+4] = y[i];
    state[i+8] = 0;
  }
  state[8] = key;
  goldilocks_monolith_permutation(state);
  for(int i=0; i<4; i++) {
    out[i] = state[i];
  }
}

void goldilocks_monolith_compress(const uint64_t *x, const uint64_t *y, uint64_t *out) {
  goldilocks_monolith_keyed_compress(x, y, 0, out);
}

//------------------------------------------------------------------------------

// hash a sequence of field elements into a digest of 4 field elements
void goldilocks_monolith_felts_digest(int rate, int N, const uint64_t *input, uint64_t *hash) {

  assert( (rate >= 1) && (rate <= 8) );

  uint64_t domsep = rate + 256*12 + 65536*63;
  uint64_t state[12];
  for(int i=0; i<12; i++) state[i] = 0;
  state[8] = domsep;

  int nchunks = (N + rate) / rate;       // 10* padding
  const uint64_t *ptr = input;
  for(int k=0; k<nchunks-1; k++) {
    for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] , ptr[j] ); }
    goldilocks_monolith_permutation( state );
    ptr += rate;
  }

  int rem = nchunks*rate - N;       // 0 < rem <= rate
  int ofs = rate - rem; 

  // the last block, with padding
  uint64_t last[8];
  for(int i=0    ; i<ofs ; i++) last[i] = ptr[i];
  for(int i=ofs+1; i<rate; i++) last[i] = 0;
  last[ofs] = 0x01;
  for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] , last[j] ); }
  goldilocks_monolith_permutation( state );

  for(int j=0; j<4; j++) { hash[j] = state[j]; }
}

//--------------------------------------

void goldilocks_monolith_bytes_digest(int rate, int N, const uint8_t *input, uint64_t *hash) {

  assert( (rate == 4) || (rate == 8) );

  uint64_t domsep = rate + 256*12 + 65536*8;
  uint64_t state[12];
  for(int i=0; i<12; i++) state[i] = 0;
  state[8] = domsep;

  uint64_t felts[8];

  int rate_in_bytes  = 31 * (rate>>2);                   // 31 or 62
  int nchunks = (N + rate_in_bytes) / rate_in_bytes;     // 10* padding
  const uint8_t *ptr = input;
  for(int k=0; k<nchunks-1; k++) {
    goldilocks_convert_bytes_to_field_elements(rate, ptr, felts);
    for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] , felts[j] ); }
    goldilocks_monolith_permutation( state );
    ptr += rate_in_bytes;
  }

  int rem = nchunks*rate_in_bytes - N;       // 0 < rem <= rate_in_bytes 
  int ofs = rate_in_bytes - rem; 
  uint8_t last[62];

  // last block, with padding
  for(int i=0    ; i<ofs          ; i++) last[i] = ptr[i];
  for(int i=ofs+1; i<rate_in_bytes; i++) last[i] = 0;
  last[ofs] = 0x01;
  goldilocks_convert_bytes_to_field_elements(rate, last, felts);
  for(int j=0; j<rate; j++) { state[j] = goldilocks_add( state[j] ,felts[j] ); }
  goldilocks_monolith_permutation( state );

  for(int j=0; j<4; j++) { hash[j] = state[j]; }
}

//------------------------------------------------------------------------------
