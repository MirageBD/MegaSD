; ----------------------------------------------------------------------------------------------------

.define sdc_transferbuffer $0900

.define sd_address_byte0	$d681
.define sd_address_byte1	$d682
.define sd_address_byte2	$d683
.define sd_address_byte3	$d684

.define sd_sector_buffer	$c000

sdcounter	.byte 0, 0, 0, 0

; ----------------------------------------------------------------------------------------------------

sdc_readmbr
        jsr sdc_resetsequence
		bcs l7
      	
:		lda #$02
		sta $d020
		lda #$07
		sta $d021
		jmp :-
        
		rts

l7		lda #$00										; MBR is sector 0
		sta sd_address_byte0							; is $d681
		sta sd_address_byte1							; is $d682
		sta sd_address_byte2							; is $d683
		sta sd_address_byte3							; is $d684

		lda #$41										; set SDHC flag
		sta $d680

		jmp sdc_readsector

; ----------------------------------------------------------------------------------------------------

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

hypervisor_z						.byte 0
dos_scratch_byte_1					.byte 0
dos_scratch_byte_2					.byte 0

zptempv32							.dword 0

dos_current_cluster					.word 0, 0

.define sd_sectorbuffer				$de00


trap_dos_mkfile:

	;; XXX Filename must already be set.
	;; XXX Must be a file in the current directory only.
	;; XXX Can only create normal files, not directories
	;;     (change attribute after).
	;; XXX Only supports 8.3 names for now.
	;; XXX Filenames without extension might still cause problems.
	;; XXX Allocates 512KB at a time, i.e., a full FAT sector's
	;;     worth of clusters.
	;; XXX Allocates a contiguous block, so that D81s etc can
	;;     be created, and guaranteed contiguous on the storage,
	;;     so that they can be mounted.
	;; XXX Size of file specified in $ZZYYXX, i.e., limit of 16MB.
	;; XXX Doesn't handle full file systems (or ones without enough space
	;;     free properly. Should check candidate cluster number is not too
	;;     high, and abort if it is.

	;; We need 1 FAT sector per 512KB of data.
	;; I.e., shift ZZ right by three bits to get number
	;; of empty FAT sectors we need to indicate sufficient space.
	lda hypervisor_z
	lsr
	lsr
	lsr
	clc
	adc #$01 
	sta dos_scratch_byte_1

	;; Now go looking for empty FAT sectors
	;; Start at cluster 128, and add 128 each time to step through
	;; them.
	;; This skips the first sector of FAT, which always has some used
	;; bits, and ensures we can allocate on a whole sector basis.
	lda #128
	sta <(zptempv32+0)
	lda #$00
	sta <(zptempv32+1)
	sta <(zptempv32+2)
	sta <(zptempv32+3)

	;; Initially 0 empty pages found
	lda #0
	sta dos_scratch_byte_2

	jsr sd_map_sectorbuffer

find_empty_fat_page_loop:
	
	ldx #3
:	lda <zptempv32,x
	sta dos_current_cluster,x
	dex
	bpl :-

	jsr read_fat_sector_for_cluster
	
	;; Is the page empty
	ldx #0
:	lda sd_sectorbuffer,x
	bne :+
	lda sd_sectorbuffer+$100,x
	bne :+

	inx
	bne :-
:

	rts

; ----------------------------------------------

read_fat_sector_for_cluster:
	jsr dos_cluster_to_fat_sector

	;; Now read the sector
		ldx #3
:		lda dos_current_cluster,x
		sta $d681,x
		dex
		bpl :-
	jmp sdc_readsector ; sd_readsector

; ----------------------------------------------

dos_disk_table:
syspart_structure:

syspart_start_sector:
		.byte 0,0,0,0
syspart_size_in_sectors:
		.byte 0,0,0,0
syspart_reserved:
		.byte 0,0,0,0,0,0,0,0

dos_disk_table_offset:
        .byte $00

.define fs_start_sector				$00
.define fs_fat32_system_sectors		$0D

dos_cluster_to_fat_sector:
		;; Take dos_current_cluster, as a cluster number,
		;; and compute the absolute sector number on the SD card
		;; where that cluster must live.
		;; INPUT: dos_current_cluster = cluster number
		;; OUTPUT: dos_current_cluster = absolute sector, which
		;;         contains the FAT sector that has the FAT entry
		;;         corresponding to the requested cluster number.

		;; shift right 7 times = divide by 128
		;;
		ldy #$07
dfanc2:	clc
		ror dos_current_cluster+3
		ror dos_current_cluster+2
		ror dos_current_cluster+1
		ror dos_current_cluster+0
		dey
		bne dfanc2

		;; add start of partition offset
		;;
		ldy dos_disk_table_offset
		ldx #$00
		clc
		php
dfanc3:	plp
		lda dos_current_cluster,x
		adc dos_disk_table + fs_start_sector,y
		sta dos_current_cluster,x
		php
		iny
		inx
		cpx #$04
		bne dfanc3
		plp

		;; add start of fat offset
		;;
		ldy dos_disk_table_offset
		ldx #$00
		clc
		php
dfanc4:	plp
		lda dos_current_cluster,x
		adc dos_disk_table + fs_fat32_system_sectors,y
		sta dos_current_cluster,x
		php
		iny
		inx
		cpx #$02
		bne dfanc4

		plp

		rts


