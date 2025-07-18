; ___________________________
; ██▀█▀██▀▀▀█▀▀█▀█  ▄▄▄ ▄▄   │   ▄▄       ▄▄   ▄▄ 
; █  ▄ █▄ ▀██▄ ▀▄█ ██   ██   │  ██ ▀ ██▄▀ ██▀ █ ██
; █  █ █▀▀ ▄█  █ █ ▀█▄█ ██▄▄ │  ▀█▄▀ ██   ▀█▄ ▀▄█▀
; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀───────────┘
;------------------------------------------------------------------------------
; crt0 header for mapped ROM program
;------------------------------------------------------------------------------
; By Guillaume 'Aoineko' Blanchard for MSX Game Library 
; (ɔ) 2022 under CC-BY-AS license
;------------------------------------------------------------------------------
; Code address: 0x4010 (right after the header)
; Data address: 0xC000
;------------------------------------------------------------------------------
.module	crt0

.module	crt0

;------------------------------------------------------------------------------
; Global symbols
.globl	_main
.globl  l__INITIALIZER
.globl  s__INITIALIZED
.globl  s__INITIALIZER
.globl  s__HEADER
.globl  s__GSFINAL
.globl  s__HEAP

;------------------------------------------------------------------------------
; I/O ports
PPI_A 			= #0xA8
VDP_S 			= #0x99

;------------------------------------------------------------------------------
; Main-ROM variables
ROMVER 			= #0x002B
MSXVER 			= #0x002D

;------------------------------------------------------------------------------
; RAM work area variables
EXPTBL			= #0xFCC1
SLTSL			= #0xFFFF

;------------------------------------------------------------------------------
; ROM Mappers
ROM_PLAIN      = 0
ROM_ASCII8     = 1
ROM_ASCII16    = 2
ROM_KONAMI     = 3
ROM_KONAMI_SCC = 4

;------------------------------------------------------------------------------
; Default values
ROM_MAPPER     = ROM_KONAMI
ADDR_BOOT      = 0x4000

;------------------------------------------------------------------------------
; Initialize globals
.macro INIT_GLOBALS

	crt0_init_globals:
		ld		bc, #l__INITIALIZER
		ld		a, b
		or		a, c
		jp		z, crt0_skip_globals	
		ld		de, #s__INITIALIZED
		ld		hl, #s__INITIALIZER
		ldir
	crt0_skip_globals:

.endm

;------------------------------------------------------------------------------
; Set page #2 at the same slot than the page #1 (for 32K ROM)
.macro INIT_P1_TO_P2

	crt0_p1_to_p2:
		; Set pages #1 & #3 primary slot equal to page #1
		in		a, (PPI_A)				; A=[P3|P2|P1|P0] Get primary slots info 
		ld		d, a					; D=[P3|P2|P1|P0] Backup original primary slots info
		and		a, #0b00001100			; A=[00|00|P1|00] Mask all pages slots but P1 
		ld		c, a					; C=[00|00|P1|00] Backup
		add		a, a					;                 A<<1
		add		a, a					; A=[00|P1|00|00] A<<1
		or		a, c					; A=[00|P1|P1|00] Merge P1 in P2
		add		a, a					;                 A<<1
		add		a, a					; A=[P1|P1|00|00] A<<1
		or		a, c					; A=[P1|P1|P1|00] Merge P1 in P2 & P3
		ld		c, a					; C=[P1|P1|P1|00] Backup
		ld		a, d					; A=[P3|P2|P1|P0] Restore primary slots info 
		and		a, #0b00000011			; A=[00|00|00|P0] Mask all pages slots but P0 
		or		a, c					; A=[P1|P1|P1|P0] Merge original P0 with P1 in all other pages
		out		(PPI_A), a				;                 Set primary slots info
		ld		e, a					; E=[P1|P1|P1|P0] Backup new primary slots

		; Set page #2 seconday slot equal to page #1
		ld		a, (SLTSL)				; A=[~3|~2|~1|~0] Read secondary slots register of selected primary slot
		cpl								; A=[S3|S2|S1|S0] Reverses the bits
		ld		b, a					; B=[S3|S2|S1|S0] Backup secondary slot
		and		a, #0b00001100			; A=[00|00|S1|00] Mask all pages slots but P1 
		ld		c, a					; C=[00|00|S1|00] Backup P1
		add		a, a					;                 P1<<1
		add		a, a					; A=[00|S1|00|00] P1<<1
		or		a, c					; A=[00|S1|S1|00] Merge P1 in P2
		ld		c, a					; C=[00|S1|S1|00]
		ld		a, b					; A=[S3|S2|S1|S0] Restore primary slots info 
		and		a, #0b11000011			; A=[S3|00|00|S0] Mask all pages slots but P0 
		or		a, c					; A=[S3|S1|S1|S0] Merge original S0 and S3 with S1 in other pages
		ld		(SLTSL), a				;                 Set secondary slot info

		; Restore initial page #3 primary slot
		ld		a, d					; A=[P3|P2|P1|P0] Restore initiale primary slots
		and		a, #0b11000011			; A=[P3|00|00|P0] Keep pages #0 and #3 slot
		ld		c, a					; B=[P3|00|00|P0] Backup
		ld		a, e					; A=[P1|P1|P1|P0] Restore new promary slots
		and		a, #0b00111100			; A=[00|P1|P1|00] Keep pages #1 and #2 slot
		or		a, c					; A=[P3|P1|P1|P0] Merge
		out		(PPI_A), a
.endm

;------------------------------------------------------------------------------
; Set pages #0 and #2 at the same slot than the page #1 (for 48K ROM)
.macro INIT_P1_TO_P02

	crt0_p1_to_p02:
		; Set all pages primary slot equal to page #1
		in		a, (PPI_A)				; A=[P3|P2|P1|P0] Get primary slots info
		ld		d, a					; B=[P3|P2|P1|P0] Backup full slots info
		and		a, #0b00001100			; A=[00|00|P1|00] Mask all pages slots but P1 
		ld		c, a					; C=[00|00|P1|00] Backup P1
		rrca							;                 A>>1
		rrca							; A=[00|00|00|P1] A>>1
		or		a, c					; A=[00|00|P1|P1]
		ld		c, a					; C=[00|00|P1|P1] Backup 
		add		a, a					;                 A<<1
		add		a, a					; A=[00|P1|P1|00] A<<1
		add		a, a					;                 A<<1
		add		a, a					; A=[P1|P1|00|00] A<<1
		or		a, c					; A=[P1|P1|P1|P1] Merge
		out		(PPI_A), a				;                 Set primary slots info
		ld		e, a					; E=[P1|P1|P1|P1] Backup new slots

		; Set page #0 and 2 at the same secondary slot than page #1
		ld		a, (SLTSL)				; A=[~3|~2|~1|~0] Read secondary slots register of selected primary slot
		cpl								; A=[S3|S2|S1|S0] Reverses the bits
		ld		b, a					; B=[S3|S2|S1|S0] Backup secondary slot
		and		a, #0b00001100			; A=[00|00|S1|00] Mask all pages secondary slots but P1 
		ld		c, a					; C=[00|00|S1|00] Backup
		rrca							;                 A>>1
		rrca							; A=[00|00|00|S1] A>>1
		or		a, c					; A=[00|00|S1|S1] Merge
		ld		c, a					; C=[00|00|S1|S1] Backup
		add		a, a					;                 A<<1
		add		a, a					; A=[00|S1|S1|00] A<<1
		or		a, c					; A=[00|S1|S1|S1] Merge
		ld		c, a					; C=[00|S1|S1|S1] Backup
		ld		a, b					; A=[S3|S2|S1|S0] Restore primary slots info 
		and		a, #0b11000000			; A=[S3|00|00|00] Mask all pages slots but P0 
		or		a, c					; A=[S3|S1|S1|S0] Merge original P0 and P1 in all other page
		ld		(SLTSL), a				;                 Set secondary slot info

		; Restore initial Page 3 slot
		ld		a, d					; A=[P3|P2|P1|P0] Restore initiale primary slots
		and		a, #0b11000000			; A=[P3|00|00|00] Keep page #3 primary slot
		ld		c, a					; C=[P3|00|00|00] Backup
		ld		a, e					; A=[P1|P1|P1|P1] Restore new primary slots
		and		a, #0b00111111			; A=[00|P1|P1|P1] Keep all pages but page #3
		or		a, c					; A=[P3|P1|P1|P1] Merge
		out		(PPI_A), a				;                 Set primary slots info
.endm


;==============================================================================
; ROM MAPPER
;==============================================================================

;------------------------------------------------------------------------------
.ifeq ROM_MAPPER-ROM_PLAIN
	.macro INIT_MAPPER
	.endm
.endif
;------------------------------------------------------------------------------
.ifeq ROM_MAPPER-ROM_ASCII8
	BANK0_ADDR = #0x6000
	BANK1_ADDR = #0x6800
	BANK2_ADDR = #0x7000
	BANK3_ADDR = #0x7800

	.macro INIT_MAPPER
		xor		a
		ld		(BANK0_ADDR), a ; Segment 0 in Bank 0
		inc		a
		ld		(BANK1_ADDR), a ; Segment 1 in Bank 1
		inc		a
		ld		(BANK2_ADDR), a ; Segment 2 in Bank 2
		inc		a
		ld		(BANK3_ADDR), a ; Segment 3 in Bank 3
	.endm
.endif
;------------------------------------------------------------------------------
.ifeq ROM_MAPPER-ROM_ASCII16
	BANK0_ADDR = #0x6000
	BANK1_ADDR = #0x7000

	.macro INIT_MAPPER
		xor		a
		ld		(BANK0_ADDR), a ; Segment 0 in Bank 0
		inc		a
		ld		(BANK1_ADDR), a ; Segment 1 in Bank 1
	.endm
.endif
;------------------------------------------------------------------------------
.ifeq ROM_MAPPER-ROM_KONAMI
	BANK1_ADDR = #0x6000
	BANK2_ADDR = #0x8000
	BANK3_ADDR = #0xA000

	.macro INIT_MAPPER
		ld		a, #1
		ld		(BANK1_ADDR), a ; Segment 1 in Bank 1
		inc		a
		ld		(BANK2_ADDR), a ; Segment 2 in Bank 2
		inc		a
		ld		(BANK3_ADDR), a ; Segment 3 in Bank 3
	.endm
.endif
;------------------------------------------------------------------------------
.ifeq ROM_MAPPER-ROM_KONAMI_SCC
	BANK0_ADDR = #0x5000
	BANK1_ADDR = #0x7000
	BANK2_ADDR = #0x9000
	BANK3_ADDR = #0xB000

	.macro INIT_MAPPER
		xor		a
		ld		(BANK0_ADDR), a ; Segment 0 in Bank 0
		inc		a
		ld		(BANK1_ADDR), a ; Segment 1 in Bank 1
		inc		a
		ld		(BANK2_ADDR), a ; Segment 2 in Bank 2
		inc		a
		ld		(BANK3_ADDR), a ; Segment 3 in Bank 3
	.endm
.endif








HIMEM = #0xFC4A

;------------------------------------------------------------------------------
.area	_HEADER (ABS)
	.org	ADDR_BOOT

_g_FirstAddr::
_g_HeaderAddr::
	; ROM header
	.db		0x41 ; A
	.db		0x42 ; B
	.dw		crt0_init
	.dw		0x0000
	.dw		0x0000
	.dw		0x0000
	.dw		0x0000
	.dw		0x0000
	.dw		0x0000

;------------------------------------------------------------------------------
.area	_CODE

crt0_init:
	di
	; Set stack address at the top of free memory
	ld		sp, (HIMEM)
	
	; Initialize heap address
	ld		hl, #s__HEAP
	ld		(#_g_HeapStartAddress), hl

	; Set Page 2 slot equal to Page 1 slot
	INIT_P1_TO_P2
	
	; Initialize ROM mapper segment
	INIT_MAPPER

	; Initialize globals
	INIT_GLOBALS

crt0_start:
	; start main() function
	ei
	call	_main
	rst		0

;------------------------------------------------------------------------------
; Ordering of segments for the linker

;-- ROM --
.area	_HOME
.area	_CODE
.area	_RODATA
.area	_INITIALIZER 
.area   _GSINIT
.area   _GSFINAL
_g_LastAddr::

;-- RAM --
.area	_DATA
_g_HeapStartAddress::
	.ds 2
.area	_INITIALIZED
.area	_BSEG
.area   _BSS
.area   _HEAP