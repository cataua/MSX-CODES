#include "common.h"

#ifndef FUNCTIONS_MSX1_H
#define FUNCTIONS_MSX1_H

// Declarações das funções
unsigned char GetCurrentRAMBank(void);
void HandleMemoryError(unsigned int location);

// Implementação das funções (se for header-only)
#ifdef IMPLEMENT_FUNCTIONS

unsigned char GetCurrentRAMBank(void) __naked {
   __asm
        ld a,(0xFFFF)
        cpl
        ld l,a     // Retorna em L (convenção SDCC)
        ret
    __endasm;
}

void HandleMemoryError(unsigned int location) {
    Screen(0);
    Print("Memory error at:");
    PrintNumber(location);
    while(1) { WaitVsync(); } // Loop infinito seguro
}

#endif // IMPLEMENT_FUNCTIONS
#endif // FUNCTIONS_MSX1_H

void CopyMenuToSafeZone(void) {
    // Desativa interrupções durante a cópia
    __asm__("di");
    
    // Copia usando LDIR (rápido e eficiente)
    __asm__(
        "ld hl, _MENU_START\n"
        "ld de, _SAFE_ZONE\n"
        "ld bc, _MENU_SIZE\n"
        "ldir\n"
        "ei\n"
    );
    // if(ComputeCRC(MENU_START, MENU_SIZE) != ComputeCRC(SAFE_ZONE, MENU_SIZE)) {
    //     HandleCopyError();
    // }
}

// Métodos avançado com suporte a ram expandida
void CopyMenuToSafeZoneEx(void) {
    unsigned char original_bank = 0;
    
    // 1. Detecta e configura RAM expandida
    if(DetectExpandedRAM()) {
        original_bank = GetCurrentRAMBank();
        SetRAMBank(3);  // Usa banco 3 da RAM expandida
    }
    
    // 2. Copia o código com verificação
    unsigned char *src = (unsigned char *)MENU_START;
    unsigned char *dst = (unsigned char *)SAFE_ZONE;
    
    for(unsigned i = 0; i < MENU_SIZE; i++) {
        dst[i] = src[i];
        
        // Verificação imediata (opcional para segurança)
        if(dst[i] != src[i]) {
            HandleMemoryError(i);
            break;
        }
    }
    
    // 3. Restaura banco de RAM se necessário
    if(DetectExpandedRAM()) {
        SetRAMBank(original_bank);
    }
}
