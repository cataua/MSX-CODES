#include "fusion-c/header/msx_fusion.h"
#include "fusion-c/header/vdp_graph2.h"

int main(void) {
  char nome[12];
  Screen(0);
  Locate(8,9);
  Print("Digite seu nome:\n");
  InputString(nome, 12);
  Cls();
  Locate(8,9);
  Print("Hi, ");
  Print(nome);
  Print("! How u doing?!\n");

  WaitKey();
  Cls();
  return 0;
}