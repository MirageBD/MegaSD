; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ main windows

root
		UIELEMENT_ADD ui_root1,					root,				windows,				0,  0, 80, 50,  0,		$ffff,							uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ main windows

windows

		UIELEMENT_ADD ui_windows0,				window,				window0area,			 0,  0, 80, 50,  0,		$ffff,							uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ child windows

window0area
		UIELEMENT_ADD fa1nineslice,				nineslice,			filearea1elements,		 1,  0, 38, 16,  0,		$ffff,							uidefaultflags

		UIELEMENT_ADD labelsectordirent,		label,				$ffff,					40, 2,  9,  1,  0,		labelsectordirent_data,			uidefaultflags
		UIELEMENT_ADD labelsectordirenthi,		hexlabel,			$ffff,					57, 2,  9,  1,  0,		labelsectordirenthi_data,		uidefaultflags
		UIELEMENT_ADD labelsectordirentlo,		hexlabel,			$ffff,					62, 2,  9,  1,  0,		labelsectordirentlo_data,		uidefaultflags
		UIELEMENT_ADD labelsectordirentoffset,	hexlabel,			$ffff,					67, 2,  9,  1,  0,		labelsectordirentoffset_data,	uidefaultflags
		UIELEMENT_ADD showdirentbutton,			ctextbutton,		$ffff,					72, 1,  8,  3,  0,		showdirentbutton_data,			uidefaultflags

		UIELEMENT_ADD labelsectorfatent,		label,				$ffff,					40, 4,  9,  1,  0,		labelsectorfatent_data,			uidefaultflags
		UIELEMENT_ADD labelsectorfatenthi,		hexlabel,			$ffff,					57, 4,  9,  1,  0,		labelsectorfatenthi_data,		uidefaultflags
		UIELEMENT_ADD labelsectorfatentlo,		hexlabel,			$ffff,					62, 4,  9,  1,  0,		labelsectorfatentlo_data,		uidefaultflags
		UIELEMENT_ADD labelsectorfatentoffset,	hexlabel,			$ffff,					67, 4,  9,  1,  0,		labelsectorfatentoffset_data,	uidefaultflags
		UIELEMENT_ADD showfatentbutton,			ctextbutton,		$ffff,					72, 3,  8,  3,  0,		showfatentbutton_data,			uidefaultflags

		UIELEMENT_ADD labelsectorfile,			label,				$ffff,					40, 6,  9,  1,  0,		labelsectorfile_data,			uidefaultflags
		UIELEMENT_ADD labelsectorfilehi,		hexlabel,			$ffff,					57, 6,  9,  1,  0,		labelsectorfilehi_data,			uidefaultflags
		UIELEMENT_ADD labelsectorfilelo,		hexlabel,			$ffff,					62, 6,  9,  1,  0,		labelsectorfilelo_data,			uidefaultflags
		UIELEMENT_ADD showfilebutton,			ctextbutton,		$ffff,					72, 5,  8,  3,  0,		showfilebutton_data,			uidefaultflags

		UIELEMENT_ADD labelsectorlo,			label,				$ffff,					40, 14,  9,  1,  0,		labelsectorlo_data,				uidefaultflags
		UIELEMENT_ADD nbsectorhiuser,			cnumericbutton,		$ffff,					50, 13,  9,  3,  0,		nbsectorhiuser_data,			uidefaultflags
		UIELEMENT_ADD nbsectorlouser,			cnumericbutton,		$ffff,					59, 13,  9,  3,  0,		nbsectorlouser_data,			uidefaultflags

		UIELEMENT_ADD fv1nineslice,				nineslice,			fatarea1elements,		 1, 16, 78, 34,  0,		$ffff,							uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ scrollbar elements

filearea1elements
		UIELEMENT_ADD fa1filebox,				filebox,			$ffff,					 3,  2, -7, -4,  0,		fa1filebox_data,			uidefaultflags
		UIELEMENT_ADD fa1scrollbartrack,		scrolltrack,		$ffff,					-3,  2,  2, -4,  0,		fa1scrollbar_data,			uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ scrollbar elements

fatarea1elements
		UIELEMENT_ADD fv1filebox,				fatview,			$ffff,					 1,  1, -1, -1,  0,		fv1_data,					uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ scrollbar elements

fa1scrollbar_data				.word fa1scrollbar_functions, 										0, 0, 20, fa1filebox			; start position, selection index, number of entries, ptr to list
fa1filebox_data					.word fa1scrollbar_functions,			filebox1_functions,			fa1scrollbar_data, fa1boxtxt, fa1directorytxt

fv1_data						.word $ffff,							$ffff,						0

labelsectorlo_data				.word $ffff,														uitxt_sector
nbsectorlouser_data				.word readsector_functions,											$0000, $c800, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset
nbsectorhiuser_data				.word readsector_functions,											$0000, $c802, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset

labelsectordirent_data			.word $ffff,														uitxt_sectordirent
labelsectordirenthi_data		.word $ffff,														ufofdirentsector+2, 2
labelsectordirentlo_data		.word $ffff,														ufofdirentsector+0, 2
labelsectordirentoffset_data	.word $ffff,														ufofdirentoffset+0,2

labelsectorfatent_data			.word $ffff,														uitxt_sectorfatent
labelsectorfatenthi_data		.word $ffff,														ufoffatentsector+2, 2
labelsectorfatentlo_data		.word $ffff,														ufoffatentsector+0, 2
labelsectorfatentoffset_data	.word $ffff,														ufoffatentoffset+0, 2

labelsectorfile_data			.word $ffff,														uitxt_sectorfile
labelsectorfilehi_data			.word $ffff,														ufoffilesector+2, 2
labelsectorfilelo_data			.word $ffff,														ufoffilesector+0, 2

showdirentbutton_data			.word showdirentbutton_functions,									uitxt_show, 0, 0, 0, 0				; ptr to text, position of cursor, start pos, selection start, selection end
showfatentbutton_data			.word showfatentbutton_functions,									uitxt_show, 0, 0, 0, 0				; ptr to text, position of cursor, start pos, selection start, selection end
showfilebutton_data				.word showfilebutton_functions,										uitxt_show, 0, 0, 0, 0				; ptr to text, position of cursor, start pos, selection start, selection end

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ listeners

fa1scrollbar_functions			.word fa1scrollbartrack,				uiscrolltrack_draw
								.word fa1filebox,						uifilebox_draw
								.word $ffff

filebox1_functions				.word fa1filebox,						userfunc_openfile
								.word $ffff

readsector_functions			.word fv1filebox,						userfunc_readsector
								.word fv1filebox,						uifatview_draw
								.word $ffff

showdirentbutton_functions		.word showdirentbutton,					userfunc_showdirent
								.word $ffff

showfatentbutton_functions		.word showfatentbutton,					userfunc_showfatent
								.word $ffff

showfilebutton_functions		.word showfilebutton,					userfunc_showfile
								.word $ffff

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

userfunc_openfile

		jsr uifilebox_getstringptr									; get filename/dir string

		ldx #$00
		ldy #$03													; skip attributes, file type and length-until-extension
:		lda (zpptrtmp),y
		beq :+
		and #$7f
		sta sdc_transferbuffer,x
		iny
		inx
		bra :-

:		sta sdc_transferbuffer,x

		ldy #$00													; get attribute and check if it's a directory
		lda (zpptrtmp),y
		and #%00010000
		cmp #%00010000
		bne :+

		jsr sdc_chdir
		jsr uifilebox_opendir
		jsr uifilebox_draw
		rts

:		
		; not a directory. collect data about file.

		jsr uifilebox_getstringptr									; get filename/dir string

		ldx #$00
		ldy #$03													; skip attributes, file type and length-until-extension
:		lda (zpptrtmp),y
		beq :+
		and #$7f
		sta sdc_transferbuffer,x
		iny
		inx
		bra :-

:		sta sdc_transferbuffer,x
		jsr sdc_findfile
		jsr sdc_fstat

		; store directory entry sector

		lda sd_address_byte0
		sta ufofdirentsector+0
		lda sd_address_byte1
		sta ufofdirentsector+1
		lda sd_address_byte2
		sta ufofdirentsector+2
		lda sd_address_byte3
		sta ufofdirentsector+3

		lda sdc_transferbuffer+$0020
		sta ufofdirentoffset+0
		lda sdc_transferbuffer+$0021
		sta ufofdirentoffset+1

		UICORE_CALLELEMENTFUNCTION labelsectordirenthi, uihexlabel_draw
		UICORE_CALLELEMENTFUNCTION labelsectordirentlo, uihexlabel_draw
		UICORE_CALLELEMENTFUNCTION labelsectordirentoffset, uihexlabel_draw

		;; store cluster

		lda sdc_transferbuffer+$001a
		sta ufofcluster+0
		sta ufoffatentsector+0
		sta ufoffilesector+0
		lda sdc_transferbuffer+$001b
		sta ufofcluster+1
		sta ufoffatentsector+1
		sta ufoffilesector+1
		lda sdc_transferbuffer+$0014
		sta ufofcluster+2
		sta ufoffatentsector+2
		sta ufoffilesector+2
		lda sdc_transferbuffer+$0015
		sta ufofcluster+3
		sta ufoffatentsector+3
		sta ufoffilesector+3

		;; CALCULATE SECTOR AND ADD HARDCODED CLUSTER_BEGIN_LBA ($0800+$0238+(2*0FF8))

		sec															; subtract 2 (clusters 0 and 1 don't actually exist on FAT32).
		lda ufoffilesector+0
		sbc #$02
		sta ufoffilesector+0
		lda ufoffilesector+1
		sbc #$00
		sta ufoffilesector+1
		lda ufoffilesector+2
		sbc #$00
		sta ufoffilesector+2
		lda ufoffilesector+3
		sbc #$00
		sta ufoffilesector+3

		ldx #$00													; multiply by 8 (sectors per cluster)
:		asl ufoffilesector+0
		rol ufoffilesector+1
		rol ufoffilesector+2
		rol ufoffilesector+3
		inx
		cpx #$03
		bne :-

		clc															; add cluster_begin_lba (fs_fat32_cluster0_sector + fs_start_sector = $0238+$0800 = $0a38)
		lda ufoffilesector+0										; $0a38 + 2*0ff8 = $2a28
		adc #$28
		sta ufoffilesector+0
		lda ufoffilesector+1
		adc #$2a
		sta ufoffilesector+1
		lda ufoffilesector+2
		adc #$00
		sta ufoffilesector+2
		lda ufoffilesector+3
		adc #$00
		sta ufoffilesector+3

		UICORE_CALLELEMENTFUNCTION labelsectorfilehi, uihexlabel_draw
		UICORE_CALLELEMENTFUNCTION labelsectorfilelo, uihexlabel_draw

		;; CALCULATE CLUSTER TO FATSECTOR

		lda ufoffatentsector+0										; store offset and multiply by 4
		and #%00111111
		sta ufoffatentoffset+0
		lda #$00
		sta ufoffatentoffset+1
		asl ufoffatentoffset+0
		rol ufoffatentoffset+1
		asl ufoffatentoffset+0
		rol ufoffatentoffset+1

		ldx #$00													; divide by 128
:		lsr ufoffatentsector+3
		ror ufoffatentsector+2
		ror ufoffatentsector+1
		ror ufoffatentsector+0
		inx
		cpx #$07
		bne :-

		clc															; add (fs_fat32_system_sectors + fs_start_sector = $0238+$0800 = $0a38)
		lda ufoffatentsector+0
		adc #$38
		sta ufoffatentsector+0
		lda ufoffatentsector+1
		adc #$0a
		sta ufoffatentsector+1
		lda ufoffatentsector+2
		adc #$00
		sta ufoffatentsector+2
		lda ufoffatentsector+3
		adc #$00
		sta ufoffatentsector+3

		UICORE_CALLELEMENTFUNCTION labelsectorfatenthi, uihexlabel_draw
		UICORE_CALLELEMENTFUNCTION labelsectorfatentlo, uihexlabel_draw
		UICORE_CALLELEMENTFUNCTION labelsectorfatentoffset, uihexlabel_draw

		jsr userfunc_showdirent

		rts

ufofcluster
		.dword 0
ufofdirentsector
		.dword 0
ufofdirentoffset
		.word 0
ufoffatentsector
		.dword 0
ufoffatentoffset
		.word 0
ufoffilesector
		.dword 0

userfunc_readsector

		jsr sdc_resetsequence
		bcs l8
      	
:		lda #$02
		sta $d020
		lda #$07
		sta $d021
		jmp :-
        
		rts

l8		lda $c800+0
		sta sd_address_byte0							; is $d681
		lda $c800+1
		sta sd_address_byte1							; is $d682
		lda $c800+2
		sta sd_address_byte2							; is $d683
		lda $c800+3
		sta sd_address_byte3							; is $d684

		lda #$41										; set SDHC flag
		sta $d680

		jsr sdc_readsector
		bcs :+

		inc $d020
		jmp *-3

:		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

userfunc_showdirent

		lda ufofdirentsector+0
		sta $c800+0
		sta nbsectorlouser_data+2
		lda ufofdirentsector+1
		sta $c800+1
		sta nbsectorlouser_data+3
		lda ufofdirentsector+2
		sta $c800+2
		sta nbsectorhiuser_data+2
		lda ufofdirentsector+3
		sta $c800+3
		sta nbsectorhiuser_data+3

		lda ufofdirentoffset+0
		sta uifatview_markstart+0
		lda ufofdirentoffset+1
		sta uifatview_markstart+1

		clc
		lda uifatview_markstart+0
		adc #32
		sta uifatview_markend+0
		lda uifatview_markstart+1
		adc #0
		sta uifatview_markend+1

		jsr updatefatview

		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

userfunc_showfatent

		lda ufoffatentsector+0
		sta $c800+0
		sta nbsectorlouser_data+2
		lda ufoffatentsector+1
		sta $c800+1
		sta nbsectorlouser_data+3
		lda ufoffatentsector+2
		sta $c800+2
		sta nbsectorhiuser_data+2
		lda ufoffatentsector+3
		sta $c800+3
		sta nbsectorhiuser_data+3

		lda ufoffatentoffset+0
		sta uifatview_markstart+0
		lda ufoffatentoffset+1
		sta uifatview_markstart+1

		clc
		lda uifatview_markstart+0
		adc #04
		sta uifatview_markend+0
		lda uifatview_markstart+1
		adc #0
		sta uifatview_markend+1

		jsr updatefatview

		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

userfunc_showfile

		lda ufoffilesector+0
		sta $c800+0
		sta nbsectorlouser_data+2
		lda ufoffilesector+1
		sta $c800+1
		sta nbsectorlouser_data+3
		lda ufoffilesector+2
		sta $c800+2
		sta nbsectorhiuser_data+2
		lda ufoffilesector+3
		sta $c800+3
		sta nbsectorhiuser_data+3

		lda #$00
		sta uifatview_markstart+0
		sta uifatview_markend+0
		lda #$02
		sta uifatview_markstart+1
		sta uifatview_markend+1

		jsr updatefatview

		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

updatefatview

		UICORE_CALLELEMENTFUNCTION nbsectorlouser, uicnumericbutton_draw
		UICORE_CALLELEMENTFUNCTION nbsectorhiuser, uicnumericbutton_draw

		jsr userfunc_readsector
		UICORE_CALLELEMENTFUNCTION fv1filebox, uifatview_draw

		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		