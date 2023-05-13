; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ main windows

root
		UIELEMENT_ADD ui_root1,					root,				windows,				0,  0, 80, 50,  0,		$ffff,						uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ main windows

windows

		UIELEMENT_ADD ui_windows0,				window,				window0area,			 0,  0, 80,  3,  0,		$ffff,						uidefaultflags
		UIELEMENT_END

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ child windows

window0area
		UIELEMENT_ADD fa1nineslice,				nineslice,			filearea1elements,		 1,  0, 38, 16,  0,		$ffff,						uidefaultflags
		UIELEMENT_ADD fv1nineslice,				nineslice,			fatarea1elements,		 1, 16, 78, 34,  0,		$ffff,						uidefaultflags
		UIELEMENT_ADD nbsector,					cnumericbutton,		$ffff,					50,  0, 13,  3,  0,		nbsector_data,				uidefaultflags
		UIELEMENT_ADD readsectorbutton,			ctextbutton,		$ffff,					64,  0, 15,  3,  0,		readsectorbutton_data,		uidefaultflags
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

readsectorbutton_data			.word readsector_functions,				uitxt_readsector

nbsector_data					.word readsector_functions,				$0000, $c800, 2, 0, 0, 65535, 0		; value, address, number of bytes, hexadecimal or not, min value, max value, signed offset

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
		lda #$00
		;lda $c800+2
		sta sd_address_byte2							; is $d683
		lda #$00
		;lda $c800+3
		sta sd_address_byte3							; is $d684

		lda #$41										; set SDHC flag
		sta $d680

		jsr sdc_readsector
		bcs :+

		inc $d020
		jmp *-3

:		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		