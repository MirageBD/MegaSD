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

fa1scrollbar_data			.word fa1scrollbar_functions, 										0, 0, 20, fa1filebox			; start position, selection index, number of entries, ptr to list
fa1filebox_data				.word fa1scrollbar_functions,			filebox1_functions,			fa1scrollbar_data, fa1boxtxt, fa1directorytxt

fv1_data					.word $ffff,							$ffff,						0

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ listeners

fa1scrollbar_functions			.word fa1scrollbartrack,				uiscrolltrack_draw
								.word fa1filebox,						uifilebox_draw
								.word $ffff

filebox1_functions				.word fa1filebox,						userfunc_openfile
								.word $ffff

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

userfunc_openfile
		rts

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		