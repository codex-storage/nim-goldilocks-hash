
// $ gcc -O2 bench_perm.c ../cbits/goldilocks.c

#include <stdint.h>

#include "../cbits/goldilocks.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>

//------------------------------------------------------------------------------

int64_t get_usec() {
  int64_t start;
  struct timeval timecheck;
  gettimeofday(&timecheck, NULL);
  start = (int64_t)timecheck.tv_sec * 1000000 + (int64_t)timecheck.tv_usec;
  return start;
}

void print_elapsed_time(const char *msg, int64_t start, int64_t stop) {
  printf("%s took %lld usecs\n" ,msg, stop-start );
}

//------------------------------------------------------------------------------

void benchmark_poseidon2_perm(int N) {  
  printf("\nbenchmarking iterated Poseidon2 permutations with N = %d\n",N);

  uint64_t state[12];
  for(int i=0; i<12; i++) state[i] = i;

  int64_t start = get_usec();
  for(int i=0; i<N; i++) { 
    goldilocks_poseidon2_permutation(state);
  }
  int64_t stop = get_usec();
  print_elapsed_time( "N iterated Poseidon2 permutations" , start, stop );
}


void benchmark_monolith_perm(int N) {
  printf("\nbenchmarking iterated Monolith permutations with N = %d\n",N);

  uint64_t state[12];
  for(int i=0; i<12; i++) state[i] = i;

  int64_t start = get_usec();
  for(int i=0; i<N; i++) { 
    goldilocks_monolith_permutation(state);
  }
  int64_t stop = get_usec();
  print_elapsed_time( "N iterated Monolith permutations" , start, stop );
}
 

//------------------------------------------------------------------------------

int main(int argc, char *argv[]) {
  int N = 1000000;

  if (argc >= 2) {
    N = atoi(argv[1]);
  }

  benchmark_poseidon2_perm(N);
  benchmark_monolith_perm (N);

  return 0;
}
