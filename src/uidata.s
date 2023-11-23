; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ main windows

root
		UIELEMENT_ADD ui_root1,					root,				windows,				0,  0, 80, 50,  0,		$ffff,						uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ main windows

windows

		UIELEMENT_ADD ui_windows0,				window,				window0area,			 0,  0, 80, 50,  0,		$ffff,						uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ child windows

window0area
		UIELEMENT_ADD fa1nineslice,				nineslice,			filearea1elements,		 1,  0, 38, 16,  0,		$ffff,						uidefaultflags

		UIELEMENT_ADD labelsectorfat,			label,				$ffff,					40, 2,  9,  1,  0,		labelsectorfat_data,		uidefaultflags
		UIELEMENT_ADD nbsectorlofat,			cnumericbutton,		$ffff,					50, 1,  9,  3,  0,		nbsectorlofat_data,			uidefaultflags
		UIELEMENT_ADD nbsectorhifat,			cnumericbutton,		$ffff,					59, 1,  9,  3,  0,		nbsectorhifat_data,			uidefaultflags
		UIELEMENT_ADD showbutton1,				ctextbutton,		$ffff,					72, 1,  8,  3,  0,		showbutton_data,			uidefaultflags

		UIELEMENT_ADD labelsectordirent,		label,				$ffff,					40, 4,  9,  1,  0,		labelsectordirent_data,		uidefaultflags
		UIELEMENT_ADD nbsectorlodirent,			cnumericbutton,		$ffff,					50, 3,  9,  3,  0,		nbsectorlodirent_data,		uidefaultflags
		UIELEMENT_ADD nbsectorhidirent,			cnumericbutton,		$ffff,					59, 3,  9,  3,  0,		nbsectorhidirent_data,		uidefaultflags
		UIELEMENT_ADD showbutton2,				ctextbutton,		$ffff,					72, 3,  8,  3,  0,		showbutton_data,			uidefaultflags

		UIELEMENT_ADD labelsectorlo,			label,				$ffff,					61, 11,  9,  1,  0,		labelsectorlo_data,			uidefaultflags
		UIELEMENT_ADD nbsectorlouser,			cnumericbutton,		$ffff,					70, 10,  9,  3,  0,		nbsectorlouser_data,		uidefaultflags
		UIELEMENT_ADD labelsectorhi,			label,				$ffff,					61, 14,  9,  1,  0,		labelsectorhi_data,			uidefaultflags
		UIELEMENT_ADD nbsectorhiuser,			cnumericbutton,		$ffff,					70, 13,  9,  3,  0,		nbsectorhiuser_data,		uidefaultflags

		UIELEMENT_ADD fv1nineslice,				nineslice,			fatarea1elements,		 1, 16, 78, 34,  0,		$ffff,						uidefaultflags
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

labelsectorlo_data				.word $ffff,														uitxt_sectorlo
labelsectorhi_data				.word $ffff,														uitxt_sectorhi
nbsectorlouser_data				.word readsector_functions,											$0000, $c800, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset
nbsectorhiuser_data				.word readsector_functions,											$0000, $c802, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset

labelsectorfat_data				.word $ffff,														uitxt_sectorfat
labelsectordirent_data			.word $ffff,														uitxt_sectordirent

nbsectorlofat_data				.word readsector_functions,											$0000, $c804, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset
nbsectorhifat_data				.word readsector_functions,											$0000, $c806, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset

nbsectorlodirent_data			.word readsector_functions,											$0000, $c808, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset
nbsectorhidirent_data			.word readsector_functions,											$0000, $c80a, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset

showbutton_data					.word $ffff,														uitxt_show, 0, 0, 0, 0				; ptr to text, position of cursor, start pos, selection start, selection end
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ listeners

fa1scrollbar_functions			.word fa1scrollbartrack,				uiscrolltrack_draw
								.word fa1filebox,						uifilebox_draw
								.word $ffff

filebox1_functions				.word fa1filebox,						userfunc_openfile
								.word $ffff

readsector_functions			.word fv1filebox,						userfunc_readsector
								.word fv1filebox,						uifatview_draw
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

		lda sd_address_byte0							; is $d681
		sta $c800+0
		sta nbsectorlouser_data+2
		lda sd_address_byte1							; is $d682
		sta $c800+1
		sta nbsectorlouser_data+3
		lda sd_address_byte2							; is $d683
		sta $c800+2
		sta nbsectorhiuser_data+2
		lda sd_address_byte3							; is $d684
		sta $c800+3
		sta nbsectorhiuser_data+3

		UICORE_CALLELEMENTFUNCTION nbsectorlouser, uicnumericbutton_draw
		UICORE_CALLELEMENTFUNCTION nbsectorhiuser, uicnumericbutton_draw

		jsr userfunc_readsector
		UICORE_CALLELEMENTFUNCTION fv1filebox, uifatview_draw
		; not a directory, get info for file.

		rts

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
		