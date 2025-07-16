#include <stdio.h>
#include <string.h>
#include "fusion-c/header/msx_fusion.h"
#include "fusion-c/header/vdp_graph1.h"
#include "fusion-c/header/io.h"

// Dimensões da tela (SCREEN 0 padrão: 40x24 colunas/linhas)
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 23

// Cores (dependem do MSX)
#define FOREGROUND_COLOR 2
#define BG_COLOR 1
#define BORDER_COLOR 1
#define HEADER_COLOR TXT_WHITE 15
#define FOOTER_COLOR TXT_CYAN 4
#define MENU_COLOR TXT_YELLOW 8
#define TXT_BLACK 1
#define KEY_UP 30
#define KEY_DOWN 31
#define KEY_ENTER 13

typedef struct {
    const char* label;
    const char* value;
} OptionsType;


char com_files[50][13];

OptionsType menuOptions[] = {
    {"1. Opcao 1", "Executar Programa 1"},
    {"2. Opcao 2", "Executar Programa 2"},
    {"3. Opcao 3", "Executar Programa 3"},
};

void ExecuteCOMFile(const char *filename) {
    int handle;
    unsigned long size;
    unsigned char *buffer;
    
    // // Abre o arquivo
    // handle = Open(filename, O_RDONLY);
    // if(handle == -1) {
    //     Print("Erro ao abrir arquivo");
    //     return;
    // }
    
    // // Obtém tamanho
    // size = Lseek(handle, 0, SEEK_END);
    // Lseek(handle, 0, SEEK_SET);
    
    // // Aloca buffer na RAM (0x0100 para .COM)
    // buffer = (unsigned char *)0x0100;
    
    // // Lê o arquivo
    // if(Read(handle, buffer, size) != size) {
    //     Print("Erro na leitura");
    //     Close(handle);
    //     return;
    // }
    
    // Close(handle);
    
    // Executa o programa
    // __asm
    //     di           ; Desabilita interrupções
    //     ld hl, 0x0100
    //     jp (hl)      ; Salta para o programa
    // __endasm;
    
    // // Se retornar (improvável para .COM)
    // __asm
    //     ei           ; Reabilita interrupções
    // __endasm;
}

void DrawBox(int x1, int y1, int x2, int y2) {
    int i, j;
    // Borda superior (caracteres ASCII: ┌, ─, ┐)
    Locate(x1, y1);
    Print("\x01\x58"); // ┌ (canto superior esquerdo)
    
    for (i = x1 + 1; i < x2; i++) Print("\x01\x57"); // ─ (linha horizontal)

    Print("\x01\x59"); // ┐ (canto superior direito)

    // Bordas laterais (│)
    for (j = y1 + 1; j < y2; j++) {
        Locate(x1, j); Print("\x01\x56"); // │ (linha vertical esquerda)
        Locate(x2, j); Print("\x01\x56"); // │ (linha vertical direita)
    }

    // Borda inferior (└, ─, ┘)
    Locate(x1, y2);
    Print("\x01\x5A"); // └ (canto inferior esquerdo)
    for (i = x1 + 1; i < x2; i++) {
        // PrintChar(0x01); 
        Print("\x01\x57"); // ─ (linha horizontal)
    }
    Print("\x01\x5B"); // ┘ (canto inferior direito)
}

void ShowMessage(int x, int y,const char* text)
{
    Locate(x, y);
    Print(text);
}

void CenterText(int y, const char* text) {
    int x = (int)(SCREEN_WIDTH - StrLen(text)) / 2;
    ShowMessage(x, y, text);
}

void RightText(int y, const char* text) {
    int x = (int)((SCREEN_WIDTH - 1) - StrLen(text));
    ShowMessage(x, y, text);
}

void LeftText(int y, const char* text) {
    int x = 1;
    ShowMessage(x, y, text);
}

int PrintOptions(void) {
    int totalFiles = 0;
    char fileBuffer[255];
    int n;
    // int totalOptions = sizeof(menuOptions) / sizeof(menuOptions[0]);
    int x = 3;
    int y = 5;
    n = FindFirst("*.COM", fileBuffer, 0);
    for (;!n;)
    {
            Locate(x, y);
            Print(fileBuffer);
            y = y + 1;
            strcpy(com_files[totalFiles], fileBuffer);
            totalFiles++;
            n = FindNext(fileBuffer);
    }
    return totalFiles; // Retorna o array de arquivos e o total de arquivos encontrados
}

void main(void) {
    int opcao = 0;
    int opcaoY = 5; // Posição Y inicial do menu
    int opcaoYMax = 5; // Posição Y máxima do menu
    int opcaoYAnt = (opcaoY - 1);
    SetColors(FOREGROUND_COLOR, BG_COLOR, BORDER_COLOR);
    Screen(0);
    Width(SCREEN_WIDTH);
    Cls(); // Limpa a tela
    // HideDisplay();
    // 1. Header (linhas 0 a 2)
    DrawBox(0, 0, (SCREEN_WIDTH - 1), 2);
    Locate(2, 1);
    CenterText(1, "=== APLICACAO MSX ===");
    
    // 2. Área do Menu (linhas 3 a 20)
    DrawBox(0, 3, (SCREEN_WIDTH - 1), 19);
    int totalFiles = PrintOptions();

    // 3. Footer (linhas 21 a 23)
    DrawBox(0, 20, (SCREEN_WIDTH - 1), 22);
    Locate(2, 21);
    LeftText(21,"Pressione ENTER para selecionar");

    // Cursor de escolha opcao
    Locate(2,opcaoY);
    Print(">"); // Cursor de seleção
    
    // ShowDisplay();
    while(1) { 
        int mov = WaitKey();
        if (mov == KEY_UP) {
            opcaoYAnt = opcaoY; // Armazena a opção anterior
            opcaoY--;
            opcao--;
            if (opcao <= 0) {
                opcaoY = 5 + totalFiles; // vai para o ultimo item da lista
                opcao = totalFiles - 1;  // Reseta a opção para o fim da lista
            }
            Locate(2, opcaoYAnt);
            Print(" ");
            Locate(2, opcaoY);
            Print(">");
        }
        if (mov == KEY_DOWN) {
            opcaoYAnt = opcaoY; // Armazena a opção anterior    
            
            opcaoY++;
            opcao++;
            if (opcao >= totalFiles) {
                opcaoY = opcaoYMax; // Limita a opção máxima e volta ao inicio
                opcao = 1; // Reseta a opção para o início
            }
            Locate(2, opcaoYAnt);
            Print(" ");
            Locate(2, opcaoY);
            Print(">");
        }
        if (mov == KEY_ENTER) {
            // Executa o arquivo selecionado
            if (opcao > 0 && opcao <= totalFiles) {
                Cls();
                Print("Opcao escolhida ");
                PrintNumber(opcao);
                // ExecuteCOMFile(com_files[opcao - 1]);
            } else {
                Print("Opcao invalida");
            }
            return;
        }
    }    
}

