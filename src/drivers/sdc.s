; ----------------------------------------------------------------------------------------------------

.define sdc_transferbuffer $0900

sdcounter	.byte 0, 0, 0, 0

; ----------------------------------------------------------------------------------------------------

sdc_resetsequence
		lda #$00				; write $00 to $d680 to start reset
		sta $d680
		lda #$01
		sta $d680

re2		jsr sd_wait_for_ready	; Wait for SD card to become ready
		bcs re2done				; success, so return
		bne re2					; not timed out, so keep trying
		rts						; timeout, so return

re2done
		;jsr sd_map_sectorbuffer

redone
		sec
		rts

		lda #$40

sd_wait_for_ready
		jsr sdtimeoutreset
sdwfrloop
		jsr sdreadytest
		bcc sdwfrloop
		rts

sdtimeoutreset:
		lda #$00				; count to timeout value when trying to read from SD card
		sta sdcounter+0			; (if it is too short, the SD card won't reset)
		sta sdcounter+1
		lda #$f3
		sta sdcounter+2
		rts

sdreadytest    
		lda $d680				; check if SD card is ready, or if timeout has occurred
		and #$03				; C is set if ready.
		beq sdisready			; Z is set if timeout has occurred.
		inc sdcounter+0
		bne sr1
		inc sdcounter+1
		bne sr1
		inc sdcounter+2
		bne sr1

		lda #$00				; timeout - set Z

sr1		clc
		rts

sdisready:
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

sdc_openfile

		ldy #>sdc_transferbuffer						; set the hyppo filename from transferbuffer
		lda #$2e
		sta $d640
		clv
		bcc :+

		ldx #<$00020000
		ldy #>$00020000
		ldz #($00020000 & $ff0000) >> 16

		lda #$36										; $36 for chip RAM at $00ZZYYXX
		sta $d640										; Mega65.HTRAP00
		clv												; Wasted instruction slot required following hyper trap instruction
		bcc :+

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
