; ----------------------------------------------------------------------------------------------------

uifatview_layout
		jsr uielement_layout

		lda #$01
		sta uirect_xdeflate
		lda #$01
		sta uirect_ydeflate

		jsr uirect_deflate

    	rts

uifatview_hide
		;jsr uielement_hide
		rts

uifatview_focus
		jsr uielement_focus
	    rts

uifatview_enter
		jsr uielement_enter
	    rts

uifatview_leave
		jsr uielement_leave
		rts

; ----------------------------------------------------------------------------------------------------


uifatview_draw

		jsr uidraw_set_draw_position

		jsr sdc_readmbr
		;bcs gotmbr

		inc $d020
		jmp *-3

gotmbr

		lda #$10
		sta $d020
		jmp *-3

		ldz #$00
		sta [uidraw_scrptr],z
		inz
		inz

	   	rts


; ----------------------------------------------------------------------------------------------------

uifatview_press
		;jsr uielement_press
    	rts

uifatview_longpress
		rts

uifatview_doubleclick
		jsr uielement_doubleclick
		rts

uifatview_release
		jsr uielement_release
    	rts

uifatview_move
		jsr uielement_move
		rts

uifatview_keypress
		jsr uielement_keypress
		rts

uifatview_keyrelease
		jsr uielement_keyrelease
		rts
		
; ----------------------------------------------------------------------------------------------------
