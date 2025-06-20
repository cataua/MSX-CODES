;--------------------------------------- 
; MSX Cartridge menu
;
; Main Module
;---------------------------------------
; (c) VWarlock, 2020
;---------------------------------------

LF		EQU	0Ah
CR		EQU	0Dh

PGSIZE		EQU	4000h	; 16kB

VDPReg0		EQU	0 ;
VDPReg1		EQU	1 ;
VDPReg2		EQU	2 ;
VDPReg3		EQU	3 ;
VDPReg4		EQU	4 ;
VDPReg5		EQU	5 ;
VDPReg6		EQU	6 ;
VDPReg7		EQU	7 ;

VDPWrRegMask	EQU	80h ;
VDPClrBlankMask	EQU	10111111B ;0BFh ;	VDP Reg#1  Clear Blank bit mask
VDPSetBlankMask	EQU	01000000B ;40h ;	VDP Reg#1  Set Blank bit mask		

VRAMDataPort	EQU	98h ; VRAM data read/write port
VDPCntrlPort	EQU	99h ; VDP register write port (bit 7=1 in second byte  = Register)
			    ; VRAM address register (bit 7=0 in second byte =  VRAM , bit 6: read/write access (0=read))
			    ; Status register read port
PalettePort	EQU 	9Ah ; Palette access port (only v9938/v9958)
IndRegPort	EQU	9Bh ; Indirect register access port (only v9938/v9958)


;VDP Registers Default Volumes
; VDP Register #0
;   Register O contains two VDP option control bits.
;   All other bits are reserved for future use and must be Os. 
;     Bit 1: M3 (mode bit 3)
;     Bit 0: External VDP (O disables 1 enables external VDP input)
;
;   default value =00h B00000000
;
VDPReg0DefVol	EQU	00000000b ; M3=0, Disable External VDP)

; VDP Register #1 
;   Register 1 contains 8 VDP option control bits
;     Bit 7:  4/16K selection (O selects 4027 RAM operation 1 selects 4108/4116 RAM operation 
;     Bit 6:  BLANK O causes the active display area to blank (show border color only) 1 enables the active display
;     Bit 5:  IE (Interrupt Enable) 0 disables 1 enables VDP interrupt
;     Bit 4:  M1
;     Bit 3:  M2 2 mode bits 1 and 2 M1, M2 and M3 determine the operating mode of the VDP: 
;        Graphics I mode:    M1=0 M2=0 M3=0
;        Graphics II mode:   M1=0 M2=0 M3=1
;        Multicolor Mode:    M1=0 M2=1 M3=0
;        Text mode:          M1=1 M2=0 M3=0
;    Bit 2:  Reserved
;    Bit 1:  Size (Sprite size select)
;        0 selects Size 0 sprites (8 � 8 bit)
;        1 selects Size 1 sprites (16 � 16 bits)
;    Bit 0:  MAG (Magnification option for sprites)
;        � selects MAGO sprites (1 �)
;        1 selects MAG1 sprites
;
;VDPReg1DefVol	EQU	10010000b ; (090h) 16K, BLANK enable, INT disable, M1=1 M2=0, 0, Normal sprite, No zoom -> TEXT I mode
VDPReg1DefVol	EQU	10100000b ; (0A0h) 16K, BLANK enable, INT enable, M1=0 M2=0, 0, Normal sprite, No zoom -> GRAPHICS I mode

; VDP Register #2
;   Register 2 contains 5 control bits
;     Bit 7-3:  Pattern Name Table Sub Block starting address
;         Strat Address = R2*0x400
;   default value =00h B00000000 -> 0000h
;   (PNTaddr = 0400h)
;VDPReg2DefVol	EQU	00h ; PNTaddr = 0000h
VDPReg2DefVol	EQU	01h ; PNTaddr = 0400h

; VDP Register #3
;   Register 2 contains 8 control bits
;     Bit 7-0:  Color Table Sub Block starting address
;         Strat Address = R3*0x40
;
;VDPReg3DefVol	EQU	00h ; CTBaddr = 0000h
VDPReg3DefVol	EQU	08h ; CTBaddr = 0200h 

; VDP Register #4
;   Register 4 contains 3 control bits
;     Bit 2-0:  Pattern Generator Sub Block starting address
;         Strat Address = R4*0x800
;
;VDPReg4DefVol	EQU	01h ; PGTaddr = 0800h
VDPReg4DefVol	EQU	01h ; PGTaddr = 0800h

; VDP Register #5
;   Register 5 contains 7 control bits
;     Bit 6-0:  Sprite Name (Attribute) Table Sub Block starting address
;         Strat Address = R5*0x80
;
;VDPReg5DefVol	EQU	00h ; SNTaddr = 0000h
VDPReg5DefVol	EQU	06h ; SNTaddr = 0300h

; VDP Register #6
;   Register 6 contains 3 control bits
;     Bit 2-0:  Sprite Pattern Gen Sub Block starting address
;       Strat Address = R6*0x800
;
;VDPReg6DefVol	EQU	00h ; SPTaddr = 0000h
VDPReg6DefVol	EQU	00h ; SPTaddr = 0000h

; VDP Register #7
;   Register 7 contains 8 control bits
;     Bit 7-4:  Color Code of Color 1 in the Text mode
;     Bit 3-0:  Color Code of Color O in the Text mode
;               and the Backdrop color in all modes.
;
VDPReg7DefVol	EQU	0F0h ; Text color = White(0Fh), Backdrop(Background) color = TRANSPARENT (00h)



; VRAM Addresses
PNTaddr		EQU	VDPReg2DefVol*400h ; Patterns Name Table Base Address
PGTaddr		EQU	VDPReg4DefVol*800h ; Patterns Generator Table Base Address
CTaddr		EQU	VDPReg3DefVol*40h ; Color Table Base Address
SNTaddr		EQU	VDPReg5DefVol*80h ; Sprite Attribute Table Base Address
SPTaddr		EQU	VDPReg6DefVol*800h ; Sprite Pattern Table Base Address	



		ORG	4000h

; ### ROM header ###

		db "AB"		; ID for auto-executable ROM
		dw START	; Main program execution address.
		dw 0		; STATEMENT
		dw 0		; DEVICE
		dw 0		; TEXT
		dw 0,0,0	; Reserved	

;----------------------- Variable -------------------------------
; VDP Registers Saved States
VDPReg0Vol:	DB VDPReg0DefVol
VDPReg1Vol:	DB VDPReg1DefVol
VDPReg2Vol:	DB VDPReg2DefVol
VDPReg3Vol:	DB VDPReg3DefVol
VDPReg4Vol:	DB VDPReg4DefVol
VDPReg5Vol:	DB VDPReg5DefVol
VDPReg6Vol:	DB VDPReg6DefVol
VDPReg7Vol:	DB VDPReg7DefVol


;------------------ Main Programm -------------------------

START:	; Program code entry point label
		CALL ClearVRAM
		CALL InitVDP
		CALL InitPGT
		CALL InitCT
		CALL ClearScreen
		CALL InitSPT
		CALL InitSNT
		CALL DisableDisplay

		JR Run


; Backdrop Color Change Test
LL1:  		LD D, 0Fh
LL2:		
		DI
		LD A, D
		ADD A, 0F0h
		OUT (VDPCntrlPort), A
		LD A, VDPReg7
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
		EI

 		LD B, 0Fh
 		CALL Delay

		DEC D
		JR NZ, LL2

; Output Messages
Run:		CALL EnableDisplay
		
		DI
		LD A, 0F4h ; set backdrop color
		OUT (VDPCntrlPort), A
		LD A, VDPReg7
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A

		LD HL, PNTaddr ; Set the VRAM address to writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A		
		LD HL, WelcomeStr1
		CALL PutStr
		EI
		NOP
		
		DI
		LD HL, PNTaddr+(32*1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, WelcomeStr2
		CALL PutStr
		EI
		NOP

		DI
		LD HL, PNTaddr+(32*2) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, WelcomeStr3
		CALL PutStr
		EI

; Menu
		DI
		LD HL, PNTaddr+(32*10+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem00
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*11+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem01
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*12+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem02
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*13+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem03
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*14+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem04
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*15+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem05
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*16+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem06
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*17+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem07
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*18+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem08
		CALL PutStr
		EI

		DI
		LD HL, PNTaddr+(32*19+1) ; Set the VRAM address to second row for writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD HL, MenuItem09
		CALL PutStr
		EI

Select:		LD HL, SNTaddr
		LD A, L
		ADD A, 4*0 ; Select VRAM Address for Apropriate Sprite No
		LD L, A
		
		LD B, 10
MoveDown:	DI
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OUT (VDPCntrlPort), A
		IN A, (VRAMDataPort)

 		ADD  A, 8
 		LD C, A

 		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD A, C
		OUT (VRAMDataPort), A
		EI
		
		PUSH BC
		LD B, 03Fh
 		CALL Delay
 		POP BC
 		DJNZ MoveDown

		LD B, 9
 MoveUp: 	DI
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OUT (VDPCntrlPort), A
		IN A, (VRAMDataPort)

 		SUB 8
 		LD C, A

 		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		LD A, C
		OUT (VRAMDataPort), A
		EI
		
		PUSH BC
		LD B, 03Fh
 		CALL Delay
 		POP BC
 		DJNZ MoveUp

LOOP:		JR LOOP
;  
;  myVDP.setVRAMaddress(VRAMwrite, myVDP.PNTaddr+(40*3)); // Set start address
;  myVDP.writeVRAM(Str);
;  
;  for (byte i = 1; i <= 15; i++)
;  {
;    myVDP.writeReg(7, i<<4);  // Set Register #7 to White text + i Background
;    delay(100); // Delay 0.5 second
;  }



;---------------Subroutines-----------------------
; Delay B= delay
Delay:
DLL1: 		PUSH BC
		LD B, 0FFh
DLL2:		PUSH BC
		PUSH AF
		POP AF
		PUSH AF
		POP AF
		PUSH AF
		POP AF
		POP BC
		DJNZ DLL2

		POP BC
		DJNZ DLL1

		RET


; Output String
PutStr:
	LD A, (HL)	; Load the byte from memory at address indicated by HL to A.
	AND A		; Same as CP 0 but faster.
	RET Z		; Back behind the call print if A = 0
	CALL PutChar	; Call the routine to display a character.
	INC HL		; Increment the HL value.
	JR PutStr	; Relative jump to the address in the label PutStr.

; Output Character
PutChar:
		OUT (VRAMDataPort), A
		RET


; Initialize VDP Registers
InitVDP:
		DI

		LD A, (VDPReg0Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg0
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
  
		LD A, (VDPReg1Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg1
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A

		LD A, (VDPReg2Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg2
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
     
		LD A, (VDPReg3Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg3
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
     
		LD A, (VDPReg4Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg4
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
     
		LD A, (VDPReg5Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg5
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
     
		LD A, (VDPReg6Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg6
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
     
		LD A, (VDPReg7Vol)
		OUT (VDPCntrlPort), A
		LD A, VDPReg7
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
  
		LD B, 0FFh
		CALL Delay
		EI
		RET		
 

; Clear VRAM
ClearVRAM:
		CALL DisableDisplay
		DI
		LD HL, 0000h
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		
		LD BC, 03FFFh
		LD A, 00h ; 00h to VRAM
CVLL1: 		OUT (VRAMDataPort), A
		DEC BC
		LD A, B
		OR C
		JR NZ, CVLL1
		
		EI
		CALL EnableDisplay
		RET		


; Clear Screen
ClearScreen:
		CALL DisableDisplay
		DI
		LD HL, PNTaddr
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		
		LD BC, 03FFh
CSLL1:		LD A, 20h ; Space
		OUT (VRAMDataPort), A
		DEC BC
		LD A, B
		OR C
		JR NZ, CSLL1
		
		EI
		CALL EnableDisplay
		RET

; Initialize Pattern Generator Table
InitPGT:
		CALL DisableDisplay
		DI
		LD HL, PGTaddr+(20h*8) ; Set the VRAM address to writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		
		LD HL, FontTable
		LD BC, 300h
IPGTLL1:	LD A, (HL)
		OUT (VRAMDataPort), A
		INC HL
		DEC BC
		LD A, B
		OR C
		JR NZ, IPGTLL1

		EI
		CALL EnableDisplay
		RET


; Initialize Color Table
InitCT:
		CALL DisableDisplay
		DI
		LD HL, CTaddr ; Set the VRAM address to writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		
		LD HL, ColorTable
		LD C, VRAMDataPort
		LD B, 32 ; number of ColorTable entres
		OTIR
		EI
		CALL EnableDisplay
		RET


; Initialize Sprite Name (Attribute) Table
InitSNT:
		CALL DisableDisplay
		DI
		LD HL, SNTaddr ; Set the VRAM address to writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		
		LD HL, SpriteNameTable
		LD C, VRAMDataPort
		LD B, 4*32  ; number of Sprite Attribute Table entres (32 x 4 bytes)
		OTIR
		EI
		CALL EnableDisplay
		RET

; Initialize Sprite Pattern Table
InitSPT:
		CALL DisableDisplay
		DI
		LD HL, SPTaddr ; Set the VRAM address to writing
		LD A, L
		OUT (VDPCntrlPort), A
		LD A, H
		AND 3Fh
		OR 40h
		OUT (VDPCntrlPort), A
		
		LD HL, SpriteTable
		LD BC, 8*2  ; number of Sprite Pattern Table entres (8 bytes per entry)
ISPTLL1:	LD A, (HL)
		OUT (VRAMDataPort), A
		INC HL
		DEC BC
		LD A, B
		OR C
		JR NZ, ISPTLL1

		EI
		CALL EnableDisplay
		RET


; Disable display
DisableDisplay:		
		DI
		LD A, (VDPReg1Vol) ; Load VDP Reg#1 Saved state
		AND VDPClrBlankMask ; Clear Blank bit
		LD (VDPReg1Vol), A ; Save VDP Reg#1 Saved state		
		OUT (VDPCntrlPort), A
		LD A, VDPReg1
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
		EI
		RET
; Enable display
EnableDisplay:	
		DI
		LD A, (VDPReg1Vol) ; Load VDP Reg#1 Saved state
		OR VDPSetBlankMask ; Set Blank bit
		LD (VDPReg1Vol), A ; Save VDP Reg#1 Saved state		
		OUT (VDPCntrlPort), A
		LD A, VDPReg1
		OR VDPWrRegMask
		OUT (VDPCntrlPort), A
		EI
		RET


;-------------------- DATA Section ------------------------
; Message data
WelcomeStr1:	DB "MENU DE OPCOES",0	; Zero indicates the end of text
WelcomeStr2:	DB "===============",0
WelcomeStr3:	DB "Escolha sabiamente",7Fh,0
; Menu entries	
MenuItem00:	DB "Menu item 0",0
MenuItem01:	DB "Menu item 1",0
MenuItem02:	DB "Menu item 2",0
MenuItem03:	DB "Menu item 3",0
MenuItem04:	DB "Menu item 4",0
MenuItem05:	DB "Menu item 5",0
MenuItem06:	DB "Menu item 6",0
MenuItem07:	DB "Menu item 7",0
MenuItem08:	DB "Menu item 8",0
MenuItem09:	DB "Menu item 9",0




;------------------- Includes ---------------------------

INCLUDE Font.asm

INCLUDE Sprites.asm

;--------------------------------------------------------
; Padding with 255 to make a fixed page of 16K size
	ds PGSIZE - ($ - 4000h),0FFh	; Fill the unused aera in page with 0FFh
	
	END


