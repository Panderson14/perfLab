#include "stdio.h"

int allEvenBits(int x);
int byteSwap(int x, int n, int m);
int multFiveEighths(int x);
int addOK(int x, int y);
int bitParity(int x);

int main() {
  allEvenBits(0xFFFFFFFF);
  byteSwap(0xdeadbeef, 0, 2);
  //printf("%d\n", multFiveEighths(1));
  //printf("%d\n", multFiveEighths(1073741824));
  addOK(-5,-5);
  bitParity(7);
  
  return 0;
}


int bitParity(int x) {
  x = x ^ (x >> 16);
  x = x ^ (x >> 8);
  x = x ^ (x >> 4);
  x = x ^ (x >> 2);
  x = x ^ (x >> 1);
  return (x & 1);
}




int addOK(int x, int y) {
  int z = x + y;
  z = z >> 31;
  x = x >> 31;
  y = y >> 31;
  return !(~(x^y) & (x^z));
}





int multFiveEighths(int x) {
  printf("%d\n", x);
  x = (x << 2) + x;
  printf("%d\n", x);
  x = x + (1 << 3) - 1;
  printf("%d\n", x);
  x = x >> 3;
  printf("%d\n", x);

  //x =  ((x << 2) + x) >> 3;
  return x;
}






int byteSwap(int x, int n, int m) {
  int y = x;
  m = m << 3;
  n = n << 3;
  int m_mask = 0xFF << m;
  int n_mask = 0xFF << n;
  int m_bits = x & m_mask;
  int n_bits = x & n_mask;
  m_bits = m_bits >> m;
  n_bits = n_bits >> n;
  x = x & ~(m_mask | n_mask);
  m_bits = m_bits << n;
  n_bits = n_bits << m;
  x = x | (m_bits + n_bits);
  printf("%d %d %d\n", x, m_bits, n_bits);
  m_bits = m_bits >> m;
  n_bits = n_bits >> n;
  x = x | ((0x00 << m) + (0x00 << n));
  //x = x & n_mask;
  printf("%d %d %d\n", x, m_mask, n_mask);
  m_bits = m_bits << n;
  n_bits = n_bits << m;
  x = x | (m_bits + n_bits);
  //y = y | n_bits;
  printf("%d %d %d\n", x, m_bits, n_bits);
  return x & ~(m_bits | n_bits);

  

  /*
  n = n << 3;
  m = m << 3;

  int swap1 = ((x & (0x7F << n)) >> n);
  int swap2 = ((x & (0x7F << m)) >> m);

  swap1 += (((x >> (n + 7)) & 0x01)) << 7;
  swap2 += (((x >> (m + 7)) & 0x01)) << 7;

  x = (x & ~(0xFF << n));
  x = (x & ~(0xFF << m));
  
  x = (x | (swap1 << m));
  x = (x | (swap2 << n));
  
  return x; */
}






int allEvenBits(int x) {
  int y = 0;
  y += (0x55 + (0x55 << 8) + (0x55 << 16) + (0x55 << 24));
  x = x & y;
  x = x ^ y;
  return !x;
}
