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
		bcs gotmbr

		inc $d020
		jmp *-3

gotmbr

		lda #<$c000
		sta zpptr2+0
		lda #>$c000
		sta zpptr2+1

ufv_lineloop
		ldy #$00
		ldz #$00

ufv_ll1	jsr uifatview_drawbyte

		lda #$a0
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz

		iny
		cpy #8
		bne ufv_ll1

		lda #$a0
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz

		lda #$a0
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz


ufv_ll2	jsr uifatview_drawbyte

		lda #$a0
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz

		iny
		cpy #16
		bne ufv_ll2
		
		jsr uidraw_increase_row

		clc
		lda zpptr2+0
		adc #16
		sta zpptr2+0
		lda zpptr2+1
		adc #0
		sta zpptr2+1

		lda zpptr2+1
		cmp #$c2
		beq :+
		jmp ufv_lineloop

:   	rts

; ----------------------------------------------------------------------------------------------------

uifatview_drawbyte

		lda (zpptr2),y
		bne :+

		lda #$08
		sta [uidraw_colptr],z
		inz
		inz
		sta [uidraw_colptr],z
		inz
		inz
		bra :++
:		lda #$0f
		sta [uidraw_colptr],z
		inz
		inz
		sta [uidraw_colptr],z
		inz
		inz
		bra :+

:
		dez
		dez
		dez
		dez

		lda (zpptr2),y
		lsr
		lsr
		lsr
		lsr
		tax
		lda hextodec_inverted,x
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz

		lda (zpptr2),y
		and #$0f
		tax
		lda hextodec_inverted,x
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
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
