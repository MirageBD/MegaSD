

.define screen					$e000	; size = 80*50*2 = $1f40

.define uipal					$c700	; size = $0300
.define spritepal				$ca00
.define sprptrs					$cd00
.define sprites					$ce00
.define kbsprites				$cf00
.define emptychar				$ff80	; size = 64

.define uichars					$10000	; $10000 - $14000     size = $4000
.define glchars					$14000	; $14000 - $1d000     size = $9000

; ----------------------------------------------------------------------------------------------------

.segment "GLYPHSPAL"
		.incbin "../bin/glyphs_pal1.bin"
.segment "CURSORPAL"
		.incbin "../bin/cursor_pal1.bin"
.segment "CURSORSPRITES"
		.incbin "../bin/cursor_sprites1.bin"
.segment "KBCURSORSPRITES"
		.incbin "../bin/kbcursor_sprites1.bin"

.segment "FONTCHARS"
		.incbin "../bin/font_chars1.bin"
.segment "GLYPHSCHARS"
		.incbin "../bin/glyphs_chars1.bin"

.segment "MAIN"

entry_main

		sei

		lda #$35
		sta $01

		lda #%10000000									; Clear bit 7 - HOTREG
		trb $d05d

		lda #$00										; unmap
		tax
		tay
		taz
		map
		eom

		lda #$47										; enable C65GS/VIC-IV IO registers
		sta $d02f
		lda #$53
		sta $d02f
		eom

		lda #%10000000									; force PAL mode, because I can't be bothered with fixing it for NTSC
		trb $d06f										; clear bit 7 for PAL ; trb $d06f 
		;tsb $d06f										; set bit 7 for NTSC  ; tsb $d06f

		lda #$41										; enable 40MHz
		sta $00

		lda #$70										; Disable C65 rom protection using hypervisor trap (see mega65 manual)
		sta $d640
		eom

		lda #%11111000									; unmap c65 roms $d030 by clearing bits 3-7
		trb $d030

		lda #$05										; enable Super-Extended Attribute Mode by asserting the FCLRHI and CHR16 signals - set bits 2 and 0 of $D054.
		sta $d054

		lda #%10100000									; CLEAR bit7=40 column, bit5=Enable extended attributes and 8 bit colour entries
		trb $d031

		lda #40*2										; logical chars per row
		sta $d058
		lda #$00
		sta $d059

		ldx #$00
		lda #$00
:		sta emptychar,x
		inx
		cpx #64
		bne :-

		ldx #$00
:		lda #<(emptychar/64)
		sta screen+0*$0100+0,x
		sta screen+1*$0100+0,x
		sta screen+2*$0100+0,x
		sta screen+3*$0100+0,x
		sta screen+4*$0100+0,x
		sta screen+5*$0100+0,x
		sta screen+6*$0100+0,x
		sta screen+7*$0100+0,x
		lda #>(emptychar/64)
		sta screen+0*$0100+1,x
		sta screen+1*$0100+1,x
		sta screen+2*$0100+1,x
		sta screen+3*$0100+1,x
		sta screen+4*$0100+1,x
		sta screen+5*$0100+1,x
		sta screen+6*$0100+1,x
		sta screen+7*$0100+1,x
		inx
		inx
		bne :-

		DMA_RUN_JOB clearcolorramjob

		lda #<screen									; set pointer to screen ram
		sta $d060
		lda #>screen
		sta $d061
		lda #(screen & $ff0000) >> 16
		sta $d062
		lda #$00
		sta $d063

		lda #<$0800										; set (offset!) pointer to colour ram
		sta $d064
		lda #>$0800
		sta $d065

		lda #$7f										; disable CIA interrupts
		sta $dc0d
		sta $dd0d
		lda $dc0d
		lda $dd0d

		lda #$00										; disable IRQ raster interrupts because C65 uses raster interrupts in the ROM
		sta $d01a

		lda #$00
		sta $d012
		lda #<fastload_irq_handler
		sta $fffe
		lda #>fastload_irq_handler
		sta $ffff

		lda #$01										; ACK
		sta $d01a

		cli

/*
		jsr fl_init
		jsr fl_waiting
		FLOPPY_FAST_LOAD uichars,			$30, $30
		FLOPPY_FAST_LOAD glchars,			$30, $31
		FLOPPY_FAST_LOAD uipal,				$30, $32
		FLOPPY_FAST_LOAD sprites,			$30, $33
		FLOPPY_FAST_LOAD kbsprites,			$30, $34
		FLOPPY_FAST_LOAD spritepal,			$30, $35
		jsr fl_exit
*/

		sei

		lda #$35
		sta $01

		lda #$02
		sta $d020
		lda #$10
		sta $d021

		jsr mouse_init									; initialise drivers
		jsr ui_init										; initialise UI
		jsr ui_setup
		lda #$00
		sta $c800+0
		sta $c800+1
		sta $c800+2
		sta $c800+3
		jsr userfunc_readsector
		UICORE_CALLELEMENTFUNCTION fv1filebox, uifatview_draw

		lda #$7f										; disable CIA interrupts
		sta $dc0d
		sta $dd0d
		lda $dc0d
		lda $dd0d

		lda #$00										; disable IRQ raster interrupts because C65 uses raster interrupts in the ROM
		sta $d01a

		lda #$ff										; setup IRQ interrupt
		sta $d012
		lda #<irq1
		sta $fffe
		lda #>irq1
		sta $ffff

		lda #$01										; ACK
		sta $d01a

		cli
		
loop

		lda $d020
		jmp loop

; ----------------------------------------------------------------------------------------------------

irq1
		php
		pha
		phx
		phy
		phz

		jsr ui_update
		jsr ui_user_update

.if megabuild = 1
		lda #$ff
.else
		lda #$00
.endif
		sta $d012
		lda #<irq1
		sta $fffe
		lda #>irq1
		sta $ffff

		plz
		ply
		plx
		pla
		plp
		asl $d019
		rti

; ----------------------------------------------------------------------------------------------------