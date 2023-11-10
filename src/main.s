

.define screen					$e000	; size = 80*50*2 = $1f40

.define uipal					$c700	; size = $0300
.define spritepal				$ca00
.define sprptrs					$cd00
.define sprites					$ce00
.define kbsprites				$cf00

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

thishere
		SD_CREATE_FILE 540, "FOO.BIN"
		SD_FIND_FILE "FOO.BIN"
		SD_OPEN_FILE "FOO.BIN"

		ldx #$00							; write increasing numbers
:		txa
		sta $c000+$0000,x
		inx
		bne :-

		ldx #$00							; write decreasing numbers
:		txa
		eor #$ff
		sta $c000+$0100,x
		inx
		bne :-

		jsr sdc_writefilesector
		bcs :+
		inc $d020
		jmp *-3

:
		stx $8000
		sty $8001

		ldx #$00							; write babe
:		lda #$ba
		sta $c000+$0000,x
		inx
		lda #$be
		sta $c000+$0000,x
		inx
		bne :-

		ldx #$00							; write code
:		lda #$c0
		sta $c000+$0100,x
		inx
		lda #$de
		sta $c000+$0100,x
		inx
		bne :-

		jsr sdc_writefilesector

		stx $8002
		sty $8003

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