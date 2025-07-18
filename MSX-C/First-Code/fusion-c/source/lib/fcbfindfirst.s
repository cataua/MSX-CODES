; ___________________________________________________________
;/               __           _                              \
;|              / _|         (_)                             |
;|             | |_ _   _ ___ _  ___  _ __                   |
;|             |  _| | | / __| |/ _ \| '_ \                  |
;|             | | | |_| \__ \ | (_) | | | |                 |
;|             |_|  \__,_|___/_|\___/|_| |_| *               |
;|                                                           |
;|               The MSX C Library for SDCC                  |
;|                   V1.0 - 09-10-11 2018                    |
;|                                                           |
;|                Eric Boez &  Fernando Garcia               |
;|                                                           |
;|               A S M  S O U R C E   C O D E                |
;|                                                           |
;|                                                           |
;\___________________________________________________________/
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	fcb_access.s for MSX													;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	2006/12/02	t.hara														;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	FcbFindfirst
;
	.area _CODE

;;	unsigned char FcbFindFirst( FCB *p_fcb, FCB_FIND *p_result );
_FcbFindFirst::
	ld		hl, #2
	add		hl, sp

	push	ix
	ld		c, (hl)				;;	bc <= p_fcb
	inc		hl
	ld		b, (hl)
	inc		hl
	push	bc
	ld		e, (hl)				;;	de <= p_result
	inc		hl
	ld		d, (hl)

	ld		c, #0x1A			;;	set DTA (DOS function)
	call	0x0005				;;	call system

	pop		de					;;	de <= p_fcb
	ld		c, #0x11			;;	find first (DOS function)
	call	0x0005				;;	call system
	pop		ix
	ld		l, a
	ret