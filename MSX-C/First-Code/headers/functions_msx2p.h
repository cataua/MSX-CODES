#include "common.h"

void CopyMenuToVRAM(void) {
    // 1. Configura VDP para escrita
    SetVDPWriteAddress(0x8000);  // Área não usada da VRAM
    
    // 2. Copia via porta VDP
    __asm(
        "ld hl, " + MENU_START + "\n"
                                 "ld bc, " +
            0x1898 + "\n" // Porta VDP data + contador
                     "ld de, " +
            MENU_SIZE + "\n"
                        "vram_copy_loop:\n"
                        "outi\n"  // Envia byte para VDP
        "jp nz, " +
        vram_copy_loop + "\n"
                         "dec de\n"
                         "ld a, d\n"
                         "or e\n"
                         "jr nz, " +
        vram_copy_loop);
    // __endasm;
}

void RestoreMenuFromSafeZone(void) {
    // 1. Desativa interrupções
    __asm("di __endasm;");

    // 2. Copia de volta usando stack (mais rápido)
    __asm(
        "ld sp, " + SAFE_ZONE + MENU_SIZE + "\n" // Prepara stack
                                            "ld de, " +
        MENU_START + MENU_SIZE - 2 + "\n"
                                     "ld bc, " +
        MENU_SIZE / 2 + "\n" // Copia em palavras
                        "restore_loop:"
                        "pop hl"
                        "ld (de), hl"
                        "dec de"
                        "dec de"
                        "djnz restore_loop");
    // __endasm;

    // 3. Restaura stack e interrupções
    __asm(
        "ld sp, #0xF380\n"  ; Stack padrão do MSX
        "ei"
    )
    // __endasm;
}

void RunProgramSafely(const char *filename) {
    // 1. Backup do menu
    CopyMenuToSafeZone();
    
    // 2. Configura ambiente seguro
    __asm
        di
        im 1
        ld a, #0xC9
        ld (0xFD9A), a  ; Desativa H.KEYI
    __endasm;
    
    // 3. Carrega e executa o programa
    LoadAndRunCOM(filename);
    
    // 4. Se retornar, restaura o sistema
    RestoreMenuFromSafeZone();
    RestoreSystem();
    
    // 5. Feedback visual
    Screen(0);
    Print("Retorno ao menu...");
    WaitKey();
}