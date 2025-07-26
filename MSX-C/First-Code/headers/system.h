#include <string.h>
#include "../fusion-c/header/msx_fusion.h"

#pragma disable_warning 110  // Ignorar aviso de chamada não seguida de retorno
#pragma disable_warning 126 // Desativa avisos de chamadas não seguidas de retorno

// Área de backup (usando a RAM entre 0xC000-0xFFFF como exemplo)
unsigned char * const system_backup = (unsigned char *)0xC000;
unsigned char * const menu_code_backup = (unsigned char *)0xC800;
unsigned char * const vdp_regs_backup = (unsigned char *)0xD000;

unsigned char GetInterruptStatus(void) {
    unsigned char status;
    
    __asm
        ld a, i        ; A = registro de interrupção
        jp pe, int_enabled
        xor a          ; A = 0 (DI)
        jr int_end
    int_enabled:
        ld a, #1       ; A = 1 (EI)
    int_end:
        ld (status), a
    __endasm;

    return status;
}

void KillSystemVariables(void) {
    // Desativa rotinas do sistema que podem interferir
    __asm
        di
        xor a
        ld (0xFC9E), a  ; CLIKSW (click do teclado)
        ld (0xFCAF), a  ; SCRMOD (modo de tela)
        ld (0xFD89), a  ; CSRSW (cursor)
    __endasm;
}

void SetupExecutionEnvironment(void) {
    // 1. Backup do código do menu (0x4000-0x7FFF)
    memcpy(menu_code_backup, (void *)0x4000, 0x4000);
    
    // 2. Backup dos registradores VDP
    __asm
        ld hl, #_vdp_regs_backup
        ld a, #0x80
        ld c, #0x99
    backup_loop:
        out (c), a
        nop
        in a, (c)
        ld (hl), a
        inc hl
        inc a
        cp #0x90
        jr nz, backup_loop
    __endasm;

    // 3. Backup de variáveis críticas do sistema
    system_backup[0] = GetInterruptStatus();  // Estado EI/DI
    system_backup[1] = *(unsigned char *)0xF3E0;  // EXPTBL
    
    // 4. Desativa sistema temporário
    KillSystemVariables();
}

void BackupVDPRegisters(void) {
    for(unsigned char i = 0; i < 16; i++) {
        __asm
            ld a, i
            add a, #0x80
            ld c, #0x99
            out (c), a
            nop
            in a, (c)
            ld (_vdp_regs_backup + i), a
        __endasm;
    }
}

// void RestoreSystem(void) {
//     // 1. Restaura registradores VDP
//     __asm
//         ld hl, #vdp_regs_backup
//         ld a, #0x80
//         ld c, #0x99
//     restore_loop:
//         out (c), a
//         ld a, (hl)
//         nop
//         out (c), a
//         inc hl
//         ld a, l
//         add a, #0x80
//         cp #0x90
//         jr nz, restore_loop
//     __endasm;
    
//     // 2. Restaura código do menu
//     memcpy((void *)0x4000, menu_code_backup, 0x4000);
    
//     // 3. Restaura variáveis do sistema
//     if(system_backup[0]) __asm ei __endasm;
//     *(unsigned char *)0xF3E0 = system_backup[1];
    
//     // 4. Reinicia drivers básicos
//     InitBasicSystem();
// }

// void InitBasicSystem(void) {
//     // Reativa funções do sistema
//     __asm
//         ld a, 1
//         ld (0xFC9E), a  ; CLIKSW
//         ld (0xFD89), a  ; CSRSW
//         call #0x006C     ; Inicialização básica
//         call #0x009F     ; CHGET
//     __endasm;
    
//     // Restaura modo de vídeo
//     Screen(0);
// }