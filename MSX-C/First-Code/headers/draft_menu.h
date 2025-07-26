#pragma disable_warning 110  // Ignorar aviso de chamada não seguida de retorno

#include <string.h>

// Área de backup (usando a RAM entre 0xC000-0xFFFF como exemplo)
unsigned char *system_backup = (unsigned char *)0xC000;
unsigned char *menu_code_backup = (unsigned char *)0xC800;
unsigned char *vdp_regs_backup = (unsigned char *)0xD000;

void SetupExecutionEnvironment(void) {
    // 1. Backup do código do menu (0x4000-0x7FFF)
    memcpy(menu_code_backup, (void *)0x4000, 0x4000);
    
    // 2. Backup dos registradores VDP
    __asm
        ld hl, _vdp_regs_backup
        ld a, 0x80
        ld c, 0x99
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
    // Adicione outras variáveis conforme necessário
    
    // 4. Desativa sistema temporário
    KillSystemVariables();
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

unsigned char CalcChecksum(void *data, unsigned size) {
    unsigned char sum = 0;
    unsigned char *p = (unsigned char *)data;
    while(size--) sum += *p++;
    return sum;
}

void RestoreSystem(void) {
    // 1. Restaura registradores VDP
    __asm       
        ld hl, _vdp_regs_backup
        ld a, 0x80
        ld c, 0x99
    restore_loop:
        out (c), a
        ld a, (hl)
        nop
        out (c), a
        inc hl
        ld a, l
        add a, 0x80
        cp 0x90
        jr nz, restore_loop
    __endasm;
    
    // 2. Restaura código do menu
    memcpy((void *)0x4000, menu_code_backup, 0x4000);
    
    // 3. Restaura variáveis do sistema
    if(system_backup[0]) __asm ei __endasm;
    *(unsigned char *)0xF3E0 = system_backup[1];
    
    // 4. Reinicia drivers básicos
    InitBasicSystem();
}

void InitBasicSystem(void) {
    // Reativa funções do sistema
    __asm
        ld a, 1
        ld (0xFC9E), a  ; CLIKSW
        ld (0xFD89), a  ; CSRSW
        call #0x006C     ; Inicialização básica
        call #0x009F     ; CHGET
    __endasm;
    
    // Restaura modo de vídeo
    Screen(0);
}

void ExecuteWithEnvironment(const char *filename) {
    // 1. Prepara ambiente
    SetupExecutionEnvironment();
    
    // 2. Carrega o .COM para 0x0100
    int handle = Open(filename, O_RDONLY);
    if(handle != -1) {
        unsigned size = Seek(handle, 0, SEEK_END);
        Seek(handle, 0, SEEK_SET);
        
        if(size <= 0xFEFF) {  // Tamanho máximo (0xFFFF - 0x0100)
            Read(handle, (void *)0x0100, size);
            Close(handle);
            
            // 3. Executa o programa
            __asm
                di
                ld hl, #0x0100
                jp (hl)
            __endasm;
            
            // (O código abaixo só executa se o programa retornar)
            __asm ei __endasm;
        } else {
            Print("Arquivo muito grande!");
            Close(handle);
        }
    }
    
    // 4. Restaura sistema
    RestoreSystem();
}

void VRAMBackup(void) {
    // Usa a VRAM como área de backup temporária
    SetVDPWrite(0x8000);  // Endereço VRAM seguro
    
    __asm
        ld bc, #0x1898  ; Porta VDP data, contador
        ld hl, #0x4000  ; Origem RAM
    backup_vram:
        outi            ; 16 ciclos
        jp nz, backup_vram
    __endasm;
}

void SafeRestore(void) {
    // Verifica se o backup é válido
    if(menu_code_backup[0] == 0xC3) {  // Verifica se tem JP
        RestoreSystem();
    } else {
        // Recuperação de emergência
        HardReset();
    }
}

void HardReset(void) {
    __asm
        di
        im 1
        ld sp, #0xF380
        jp #0x0000      ; Reset básico
    __endasm;
}