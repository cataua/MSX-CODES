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

OptionsType menuOptions[] = {
    {"1. Opcao 1", "Executar Programa 1"},
    {"2. Opcao 2", "Executar Programa 2"},
    {"3. Opcao 3", "Executar Programa 3"},
};

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
            totalFiles++;
            n = FindNext(fileBuffer);
    }
    return totalFiles;
    // for (int i = 0; i < totalOptions; i++) {
    //     int x = 3;
    //     int y = i + 5;
    //     Locate(x, y);
    //     Print(menuOptions[i].label);
    // } 
}

void main(void) {
    int opcao = 1;
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
            if (opcao < totalFiles) {
                opcaoY = totalFiles; // Limita a opção mínima
                opcao = 1; // Reseta a opção para o início
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
            if (opcao > totalFiles) {
                opcaoY = opcaoYMax; // Limita a opção máxima e volta ao inicio
                opcao = 1; // Reseta a opção para o início
            }
            Locate(2, opcaoYAnt);
            Print(" ");
            Locate(2, opcaoY);
            Print(">");
        }
        if (mov == KEY_ENTER) {
            Cls();
            Locate(2, 22);
            Print("Opcao selecionada:\n");
            // Ação para a opção selecionada
            switch (opcao)
            {
                case 1:
                    Print("Rodar programa 1");
                break;
                case 2:
                    Print("Rodar programa 2");                
                break;
                case 3:
                    Print("Rodar programa 3");
                break;
                default:
                    Print("Opcao invalida");
            }
            WaitKey(); // Mantém a tela aberta
            return;
        }
    }    
}

