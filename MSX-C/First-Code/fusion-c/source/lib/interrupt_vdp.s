; ___________________________________________________________
;/               __           _                              \
;|              / _|         (_)                             |
;|             | |_ _   _ ___ _  ___  _ __                   |
;|             |  _| | | / __| |/ _ \| '_ \                  |
;|             | | | |_| \__ \ | (_) | | | |                 |
;|             |_|  \__,_|___/_|\___/|_| |_| *               |
;|                                                           |
;|               The MSX C Library for SDCC                  |
;|                     V1.3   -  04-2020                     |
;|                                                           |
;|                Eric Boez &  Fernando Garcia               |
;|              Revision by Oduvaldo Pavan Junior            |
;|          Using suggestion by MRC User DarkSchneider       |
;|                                                           |
;|               A S M  S O U R C E   C O D E                |
;|                                                           |
;|                                                           |
;\___________________________________________________________/
;
;
;	VDP Interrupt functions based on H.TIMI HOOK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	2020/04/09 Oduvaldo Pavan Junior - code based on MRC User DarkSchneider ;;
;;  example at :															;;
;; https://www.msx.org/forum/msx-talk/development/fusion-c-and-htimi?page=1 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;

 .area _CODE
  
; ---------------------------------------------------------
reset_vect	= 0x0000
bdos		= 0x0005
ramad1		= 0xF342
vdphookint	= 0xFD9F

; ---------------------------------------------------------
;	void InitVDPInterruptHandler(int VdpInterrupFunction)
; ---------------------------------------------------------
_InitVDPInterruptHandler::
	push	ix
	ld		ix,#0
	add		ix,sp
	ld		l,4(ix)
	ld		h,5(ix)
	pop		ix
	di
	ld		(vdp_intr_handler+2), hl; Replace in intr_handler the address
	
	;	save vdphookint 
	ld		hl, #vdphookint
	ld		de, #backup_vdp_hookint
	ld		bc, #5
	ldir
		
	ld		a, #0xF7				; RST_30 (interslot call both dos and bios)
	ld		(vdphookint), a
	ld		a, (ramad1)
	ld		(vdphookint+1), a
	ld		hl, #vdp_intr_handler
	ld		(vdphookint+2), hl
	ld		a, #0xc9
	ld		(vdphookint+4), a
	ei
	ret

backup_vdp_hookint:
	.ds		5

; ---------------------------------------------------------
;	void EndVDPInterruptHandler(void)
; ---------------------------------------------------------
_EndVDPInterruptHandler::
	di
	ld		hl, #backup_vdp_hookint
	ld		de, #vdphookint
	ld		bc, #5
	ldir
	ei
	ret

; ---------------------------------------------------------
;	vdp_intr_handler
; ---------------------------------------------------------
vdp_intr_handler:
	push	af					; Save VDP status
	call	dummy_vdp_handler	; This will be replaced by user routine address	
dummy_vdp_handler:
	pop		af					; Restore VDP status
	jp		backup_vdp_hookint	; And continue processing interrupt hooks
	ret