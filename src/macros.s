.define COLOR_RAM $ff80000
.define SAFE_COLOR_RAM COLOR_RAM+2048
.define SAFE_COLOR_RAM_PLUS_ONE COLOR_RAM+2048+1

.define COLOR_RAM_FREESPACE COLOR_RAM+2048+8192

.macro QSTORE32 num, address
		lda #<.loword(num)
		ldx #>.loword(num)
		ldy #<.hiword(num)
		ldz #>.hiword(num)
		sta address+0
		stx address+1
		sty address+2
		stz address+3
.endmacro		

.macro DMA_RUN_JOB jobPointer
		lda #(jobPointer & $ff0000) >> 16
		sta $d702
		sta $d704
		lda #>jobPointer
		sta $d701
		lda #<jobPointer
		sta $d705
.endmacro

.macro DMA_INIT_FAST_JOB jobPointer
		lda #(jobPointer & $ff0000) >> 16
		sta $d702
		sta $d704
		lda #>jobPointer
		sta $d701
.endmacro

.macro DMA_RUN_JOB_FAST jobPointer
		lda #<jobPointer
		sta $d705
.endmacro

.macro DMA_HEADER sourceBank, destBank
		; f018a = 11 bytes, f018b is 12 bytes
		.byte $0a ; Request format is F018A
		.byte $80, sourceBank
		.byte $81, destBank
.endmacro

.macro DMA_FILL_JOB sourceByte, destination, length, chain
.scope
	.byte $00 ; No more options
	.if chain
		.byte $07 ; Fill and chain
	.else
		.byte $03 ; Fill and last request|
	.endif

	.word length ; Size of Copy
	.word sourceByte
	.byte $00
	.word destination & $ffff
	.byte ((destination >> 16) & $0f)

	.if chain
		.word $0000
	.endif
.endscope
.endmacro

.macro DMA_COPY_JOB source, destination, length, chain, backwards
.scope
	.byte $00 ; No more options

	.if chain
		.byte $04 ; Copy and chain
	.else
		.byte $00 ; Copy and last request
	.endif

	.if backwards
		.word length ; Size of Copy
		.word (source + length - 1) & $ffff
		.byte ((source + length - 1) >> 16) + $40
		.word (destination + length - 1) & $ffff
		.byte (((destination + length - 1) >> 16) & $0f) + $40
	.else
		.word length ; Size of Copy
		.word (source) & $ffff
		.byte ((source) >> 16)
		.word (destination) & $ffff
		.byte (((destination) >> 16) & $0f)
	.endif

	.if chain
		.word $0000
	.endif
.endscope
.endmacro

.macro FLOPPY_FAST_LOAD_OLD addr, fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #<.loword(addr)
			sta fastload_address+0
			lda #>.loword(addr)
			sta fastload_address+1
			lda #<.hiword(addr)
			sta fastload_address+2
			lda #>.hiword(addr)
			sta fastload_address+3

			ldx #<FileName
			ldy #>FileName
			jsr fl_set_filename

			lda #$01										; Request fastload job
			sta fastload_request
			jsr fl_waiting
.endscope
.endmacro

.macro FLOPPY_FAST_LOAD addr, char1, char2
.scope
			lda #<.loword(addr)
			sta fastload_address+0
			lda #>.loword(addr)
			sta fastload_address+1
			lda #<.hiword(addr)
			sta fastload_address+2
			lda #>.hiword(addr)
			sta fastload_address+3

			ldx #char1
			ldy #char2
			jsr fl_find_dir_entry
			jsr fl_waiting
.endscope
.endmacro

.macro FLOPPY_LOAD addr, fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #addr >> 20
			sta mbank+1
			lda #<addr
			ldx #>addr
			ldy #(addr & $f0000) >> 16
			jsr SetLoadAddress
			ldx #<FileName
			ldy #>FileName
			jsr LoadFile
.endscope
.endmacro

.macro SD_LOAD_CHIPRAM addr, fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #>FileName
			ldx #<FileName

			sta FileNameI+2
			stx FileNameI+1

			ldx #$00
FileNameI	lda $babe,x
			sta filebuffer,x
			inx
			bne FileNameI

			ldx #<filebuffer							; Make hypervisor call to set filename to load
			ldy #>filebuffer
			lda #$2e
			sta $d640									; Mega65.HTRAP00
			eom											; Wasted instruction slot required following hyper trap instruction

			ldx #<addr
			ldy #>addr
			ldz #(addr & $ff0000) >> 16

			lda #$36									; $36 for chip RAM at $00ZZYYXX
			sta $d640									; Mega65.HTRAP00
			eom											; Wasted instruction slot required following hyper trap instruction
			bcs :+
			inc $d021
:			
			; XXX Check for error (carry would be clear)
.endscope
.endmacro

.macro SD_ERROR_CODE
		lda #$38
		sta $d640
		clv
.endmacro

.macro SD_LOAD_ATTICRAM addr, fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #>FileName
			ldx #<FileName

			sta FileNameI+2
			stx FileNameI+1

			ldx #$00
FileNameI	lda $babe,x
			sta filebuffer,x
			inx
			bne FileNameI

			ldx #<addr
			ldy #>addr
			ldz #(addr & $ff0000) >> 16

			lda #$3e									; $3E for Attic RAM at $8000000 + $00ZZYYXX 
			sta $d640									; Mega65.HTRAP00
			eom											; Wasted instruction slot required following hyper trap instruction

			; XXX Check for error (carry would be clear)
.endscope
.endmacro

.macro SD_FIND_FILE fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #>FileName
			ldx #<FileName

			sta FileNameI+2
			stx FileNameI+1

			ldx #$00
FileNameI	lda $babe,x
			sta filebuffer,x
			inx
			bne FileNameI

			ldx #<filebuffer							; Make hypervisor call to set filename to find
			ldy #>filebuffer
			lda #$2e
			sta $d640
			clv

			lda #$34									; Find the file
			sta $d640
			clv
			bcs :+
			lda #$03
			sta $d020
			jmp *
:
.endscope
.endmacro

.macro SD_OPEN_FILE fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #>FileName
			ldx #<FileName

			sta FileNameI+2
			stx FileNameI+1

			ldx #$00
FileNameI	lda $babe,x
			sta filebuffer,x
			inx
			bne FileNameI

			ldx #<filebuffer							; Make hypervisor call to set filename to open
			ldy #>filebuffer
			lda #$2e
			sta $d640
			clv

			lda #$18									; Open the file
			sta $d640
			clv
			bcs :+
			lda #$04
			sta $d020
			jmp *
:
.endscope
.endmacro

.macro SD_CREATE_FILE size, fname
.scope
			bra :+
FileName	.byte .sprintf("%s", fname), 0
:			lda #>FileName
			ldx #<FileName

			sta FileNameI+2
			stx FileNameI+1

			ldx #$00
FileNameI	lda $babe,x
			sta filebuffer,x
			inx
			bne FileNameI

			ldx #<filebuffer							; Make hypervisor call to set filename to create
			ldy #>filebuffer
			lda #$2e
			sta $d640
			eom											; Wasted instruction slot required following hyper trap instruction

			ldx #<size
			ldy #>size
			ldz #(size & $ff0000) >> 16

			lda #$1e
			sta $d640
			clv

			bcs :+
			; XXX Check for error (carry would be clear)
			inc $d021
:
.endscope
.endmacro

.macro SD_READDIR
.scope
	phx
	ldy #>$0900

	lda #$14
	sta $d640
	clv

	plx
.endscope
.endmacro

.macro SD_RMFILE
.scope
	lda #$26
	sta $d640
	clv
.endscope
.endmacro
