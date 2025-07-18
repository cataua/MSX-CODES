; ___________________________________________________________
;/               __           _                              \
;|              / _|         (_)                             |
;|             | |_ _   _ ___ _  ___  _ __                   |
;|             |  _| | | / __| |/ _ \| '_ \                  |
;|             | | | |_| \__ \ | (_) | | | |                 |
;|             |_|  \__,_|___/_|\___/|_| |_| *               |
;|                                                           |
;|               The MSX C Library for SDCC                  |
;|                     V1.3 - 02 - 2020                      |
;|                                                           |
;|                Eric Boez &  Fernando Garcia               |
;|                                                           |
;|               A S M  S O U R C E   C O D E                |
;|                                                           |
;|                                                           |
;\___________________________________________________________/
;
;
;----------------------------------------------------------------------------;
; get AHL                                                       			 ;
;----------------------------------------------------------------------------;
; AHL is 17 bit value of
; Left upper corner of each pages:
; Provide page in A to set A,HL
;
;   0 -> A=0,HL=$0000
;   1 -> A=0,HL=$8000
;   2 -> A=1,HL=$0000
;   3 -> A=1,HL=$8000
;
_getAHL:
	ld	hl,#0
	and	#1
	jp	z,lb_ahl_0
	ld	h,#0x80
lb_ahl_0:
	ret