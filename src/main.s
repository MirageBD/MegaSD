.define screen							$e000	; size = 80*50*2 = $1f40

.define uipal							$c700	; size = $0300
.define spritepal						$ca00
.define sprptrs							$cd00
.define sprites							$ce00
.define kbsprites						$cf00

.define uichars							$10000	; $10000 - $14000     size = $4000
.define glchars							$14000	; $14000 - $1d000     size = $9000

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

.macro DEBUG_SECTOR address
		lda $d681
		sta address+0
		lda $d682
		sta address+1
		lda $d683
		sta address+2
		lda $d684
		sta address+3
.endmacro

.macro COPY_SECTORBUFFER_TO_MEM address
.scope
		ldx #$00
:		lda $c000+$0000,x
		sta address+$0000,x
		lda $c000+$0100,x
		sta address+$0100,x
		inx
		bne :-
.endscope
.endmacro

/*
		lda #$00
		sta $c800+0
		sta $c800+1
		sta $c800+2
		sta $c800+3
		jsr userfunc_readsector				; read MBR
		COPY_SECTORBUFFER_TO_MEM $c200

		ldx #$00
:		lda $c200 + mbr_partitionentry1_offset + pe_numberofsectorsbetweenmbrandfirstsectorinpartition_offset,x	; first partition entry
		sta $c400,x
		inx
		cpx #$05
		bne :-
*/




		SD_CREATE_FILE 540, "FOO.BIN"		; should normally fail, because file already exists

		SD_FIND_FILE "FOO.BIN"
		SD_OPEN_FILE "FOO.BIN"

		ldx #$00							; write all 2
:		lda #$02
		sta $c000+$0000,x
		sta $c000+$0100,x
		inx
		bne :-

		ldx #$00
:		lda uitxt_sectorwrite,x				; write debug string
		sta $c000,x
		inx
		cpx #29
		bne :-

		jsr sdc_writefilesector

		ldx #$00							; write all 3
:		lda #$03
		sta $c000+$0000,x
		sta $c000+$0100,x
		inx
		bne :-

		jsr sdc_writefilesector

		lda #$22							; close all filedescriptors
		sta $d640
		clv

		ldx #$00							; write 0 to verify readback
:		lda #$00
		sta $c000+$0000,x
		inx
		bne :-

		SD_FIND_FILE "FOO.BIN"
		;SD_OPEN_FILE "FOO.BIN"

		SD_RMFILE
		jsr sdc_debug_current_sector

		;jmp *









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

/*
		lda #$00										; start at sector 0
		sta $c800+0
		sta nbsectorlo_data+2
		sta $c800+1
		sta nbsectorlo_data+3
		sta $c800+2
		sta nbsectorhi_data+2
		sta $c800+3
		sta nbsectorhi_data+3
*/


		lda #$8f										; or at start of FAT (partition start $0800 + reserved sectors in partition $0238 = $0a38)
		sta $c800+0
		sta nbsectorlo_data+2
		lda #$0a
		sta $c800+1
		sta nbsectorlo_data+3
		lda #$00
		sta $c800+2
		sta nbsectorhi_data+2
		sta $c800+3
		sta nbsectorhi_data+3

														; or start at fileentry
/*
		lda $d681
		sta $c800+0
		sta nbsectorlo_data+2
		lda $d682
		sta $c800+1
		sta nbsectorlo_data+3
		lda $d683
		sta $c800+2
		sta nbsectorhi_data+2
		lda $d684
		sta $c800+3
		sta nbsectorhi_data+3
*/

		UICORE_CALLELEMENTFUNCTION nbsectorlo, uicnumericbutton_draw
		UICORE_CALLELEMENTFUNCTION nbsectorhi, uicnumericbutton_draw

		;jsr userfunc_readsector
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