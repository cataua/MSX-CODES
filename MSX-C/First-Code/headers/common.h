#include "../fusion-c/header/msx_fusion.h"

// Definições de endereços
#define MENU_START   0x4000  // Endereço típico para código em cartucho
#define MENU_SIZE    0x4000  // Tamanho máximo do menu (16KB)
#define SAFE_ZONE    0xC000  // Área segura na RAM (ajuste conforme disponível)

// Cálculo de CRC 
unsigned short ComputeCRC(void *data, unsigned size) {
    unsigned short crc = 0xFFFF;
    unsigned char *ptr = (unsigned char *)data;
    
    while(size--) {
        crc ^= (unsigned short)(*ptr++) << 8;
        for(unsigned char i = 0; i < 8; i++) {
            crc = (crc & 0x8000) ? ((crc << 1) ^ 0x1021) : (crc << 1);
        }
    }
    return crc;
}

// Versão mais segura do DetectExpandedRAM
unsigned char DetectExpandedRAM(void) {
    unsigned char slots = 0;
    __asm
        in a, (0xA8)
        and #0x0F
        ld (slots), a
    __endasm;
    return slots;  // Retorna o valor escolhido
}

// Versão otimizada do SetRAMBank
void SetRAMBank(unsigned char bank) __naked {
    (void)bank;  // Evita warning de parâmetro não usado
    __asm
        pop af    // Remove endereço de retorno
        pop bc    // Pega o parâmetro (bank em C)
        push bc   // Recoloca para retorno correto
        push af
        
        ld a, c   ; Usa o valor do parâmetro
        ld (0xFFFF), a
        out (0xFE), a
        ret
    __endasm;
}


void WaitVsync(void) {
     unsigned short timeout = 65535; // Prevenção contra loop infinito
    while(!IsVsync()) {
        __asm
            halt
        __endasm;
    }
}