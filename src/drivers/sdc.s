; ----------------------------------------------------------------------------------------------------

.define sdc_transferbuffer $0900

.define sd_address_byte0	$d681
.define sd_address_byte1	$d682
.define sd_address_byte2	$d683
.define sd_address_byte3	$d684

.define sdc_sectorbuffer	$c000

sdc_sectorcount			.word 0

sdcounter	.byte 0, 0, 0, 0

; ----------------------------------------------------------------------------------------------------

sdc_readfilesector

		lda #$35
		sta $01

		inc sdc_sectorcount+0
		bne :+
		inc sdc_sectorcount+1

														; assume the file is already open.		
:		lda $d030										; unmap the colour RAM from $dc00 because that will prevent us from mapping in the sector buffer
		pha
		and #%11111110
		sta $d030

		lda #$1a										; read the next sector (hyppo_readfile)
		sta $d640
		clv

		cpx #$00										; WHY DO I HAVE TO DO THIS??? ERROR HANDLING SHOULD TAKE CARE OF THIS!!!
		bne :+
		cpy #$00
		bne :+
		clc
		jmp sdc_sectoroperation_done
:		
		bcs :+
		jmp sdc_readsector_error

:		lda #$81										; map the sector buffer to $de00
		sta $d680

		ldx #$00										; copy sector to sectorbuffer
:		lda $de00,x
		sta sdc_sectorbuffer+$0000,x
		lda $df00,x
		sta sdc_sectorbuffer+$0100,x
		inx
		bne :-

		lda #$82										; unmap the sector buffer from $de00
		sta $d680

sdc_sectoroperation_done

		pla												; map the colour RAM at $dc00 if it was previously mapped
		sta $d030

		lda #$34
		sta $01

		rts

; ----------------------------------------------------------------------------------------------------

sdc_readsector_error

		cmp #$ff										; if the error code in A is $ff we have reached the end of the file otherwise there’s been an error
		bne sdc_readsector_fatalerror

		pla												; map the colour RAM at $dc00 if it was previously mapped
		sta $d030

		lda #$34
		sta $01

		rts

sdc_readsector_fatalerror

:		inc $d020
		jmp :-

; ----------------------------------------------------------------------------------------------------

sdc_writefilesector

		lda #$35
		sta $01

		inc sdc_sectorcount+0
		bne :+
		inc sdc_sectorcount+1

														; assume the file is already open.		
:		lda $d030										; unmap the colour RAM from $dc00 because that will prevent us from mapping in the sector buffer
		pha
		and #%11111110
		sta $d030

		lda #$81										; map the sector buffer to $de00
		sta $d680

		ldx #$00										; copy sectorbuffer to sector
:		lda sdc_sectorbuffer+$0000,x
		sta $de00,x
		lda sdc_sectorbuffer+$0100,x
		sta $df00,x
		inx
		bne :-

		lda #$82										; unmap the sector buffer from $de00
		sta $d680

		lda #$1c										; write the next sector (hyppo_writefile)
		sta $d640
		clv

		bcs :+
		jmp sdc_readsector_error
:

		pla												; map the colour RAM at $dc00 if it was previously mapped
		sta $d030

		lda #$34
		sta $01

		rts

; ----------------------------------------------------------------------------------------------------

		; READSECTOR CODE BORROWED FROM HYPPO CODE!!!

sdc_readsector											; Assumes fixed sector number (or byte address in case of SD cards) is loaded into $D681 - $D684
        
        lda $d680
        and #$01
        bne rsbusyfail

        jmp rs4											; skipping the redoread-delay below

redoread
		; redo-read delay
		; ldx #<msg_sdredoread							; when retrying, introduce a delay.  This seems to be needed often
		; ldy #>msg_sdredoread							; when reading the first sector after SD card reset.
		; jsr printmessage								; print out a debug message to indicate RE-reading (ie previous read failed)

		ldx #$f0
		ldy #$00
		ldz #$00
r1		inz
		bne r1
		iny
		bne r1
		inx
		bne r1

rs4
		lda #$02										; ask for sector to be read
		sta $d680
		jsr sdtimeoutreset								; wait for sector to be read

rs3		jsr sdreadytest
		bcs rsread										; yes, sdcard is ready
		bne rs3											; not ready, so check if ready now?
		beq rereadsector								; Z was set, ie timeout

rsread
		ldx #$00
:		lda $de00,x
		sta $c000,x
		inx
		bne :-

		ldx #$00
:		lda $df00,x
		sta $c100,x
		inx
		bne :-

		;inc $d020										; this gets hit
		;jmp *-3

		sec
		rts

rereadsector
		jsr sdc_resetsequence							; reset sd card and try again
		jmp rs4

rsbusyfail												; fail
		; lda #dos_errorcode_read_timeout
		; sta dos_error_code

		lda #$e0
		sta $d020
		jmp *-3

		clc
		rts

; ----------------------------------------------------------------------------------------------------

sd_wait_for_ready
		jsr sdtimeoutreset

sdwfrloop
		jsr sdreadytest
		bcc sdwfrloop
		rts

sdc_resetsequence

		;lda #$c1										; First try resetting card 1 (external)
        ;sta $d680

		lda #$00										; write $00 to $d680 to start reset
		sta $d680
		lda #$01
		sta $d680

re2		jsr sd_wait_for_ready							; Wait for SD card to become ready

		bcs re2done										; success, so return
		bne re2											; not timed out, so keep trying
		rts												; timeout, so return

re2done
		jsr sd_map_sectorbuffer

redone
		;lda #$b0
		;sta $d020										; this gets hit
		;jmp *-3

		sec
		rts

sdwaitawhile
		jsr sdtimeoutreset

sw1		inc sdcounter+0
		bne sw1
		inc sdcounter+1
		bne sw1
		inc sdcounter+2
		bne sw1
		rts

sdtimeoutreset
		lda #$00										; count to timeout value when trying to read from SD card
		sta sdcounter+0									; (if it is too short, the SD card won't reset)
		sta sdcounter+1
		lda #$f3
		sta sdcounter+2
		rts

sdreadytest
		lda $d680										; check if SD card is ready, or if timeout has occurred
		and #$03										; C is set if ready.
		beq sdisready									; Z is set if timeout has occurred.
		inc sdcounter+0
		bne sr1
		inc sdcounter+1
		bne sr1
		inc sdcounter+2
		bne sr1

		lda #$00										; timeout - set Z

sr1		clc
		rts

sdisready:


		;lda #$e0
		;sta $d020
		;jmp *-3


		sec
		rts

; ----------------------------------------------------------------------------------------------------

sd_map_sectorbuffer

		lda #$01										; Clear colour RAM at $DC00 flag, as this prevents mapping of sector buffer at $de00
		trb $d030

		lda #$81										; Actually map the sector buffer
		sta $d680

		sec
		rts

; ----------------------------------------------------------------------------------------------------

sdc_opendir

		lda #$00
		sta $d640
		nop
		ldz #$00

		lda #$12										; hyppo_opendir - open the current working directory
		sta $d640
		clv
		bcc sdc_opendir_error

		tax												; transfer the directory file descriptor into X
		ldy #>sdc_transferbuffer						; set Y to the MSB of the transfer area

sdcod1	lda #$14										; hyppo_readdir - read the directory entry
		sta $d640
		clv
		bcc sdcod2

		phx
		phy
sdc_processdirentryptr		
		jsr $babe										; call function that handles the retrieved filename
		ply
		plx
		bra sdcod1

sdcod2	cmp #$85										; if the error code in A is $85 we have reached the end of the directory otherwise there’s been an error
		bne sdc_opendir_error
		lda #$16										; close the directory file descriptor in X
		sta $d640
		clv
		bcc sdc_opendir_error
		rts

sdc_opendir_error
		lda #$38
		sta $d640
		clv

:		lda #$06
		sta $d020
		lda #$07
		sta $d020
		jmp :-

; ----------------------------------------------------------------------------------------------------

sdc_chdir

		ldy #>sdc_transferbuffer						; set the hyppo filename from transferbuffer
		lda #$2e
		sta $d640
		clv
		bcc :+
		lda #$34										; find the FAT dir entry
		sta $d640
		clv
		bcc :+
		lda #$0c										; chdir into the directory
		sta $d640
		clv
		rts

:		;inc $d020
		;jmp :-
		rts

; ----------------------------------------------------------------------------------------------------

sdc_cwd

		rts

; ----------------------------------------------------------------------------------------------------

sdc_d81attach0

		lda #$00
		sta sdc_transferbuffer,y

		ldy #>sdc_transferbuffer						; set the hyppo filename from transferbuffer
		lda #$2e
		sta $d640
		clv
		bcc sdc_d81attach0_error

		lda #$40										; Attach the disk image
		sta $d640
		clv
		bcc sdc_d81attach0_error
		rts

sdc_d81attach0_error
:		lda #$02
		sta $d020
		lda #$03
		sta $d020
		jmp :-

; ----------------------------------------------------------------------------------------------------
