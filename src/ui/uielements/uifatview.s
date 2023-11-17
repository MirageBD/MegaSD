; ----------------------------------------------------------------------------------------------------

uifatview_tmp	.dword 0

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

		lda #<$c000
		sta zpptr2+0
		lda #>$c000
		sta zpptr2+1

		lda #$00
		sta uifatview_tmp+0
		sta uifatview_tmp+1

ufv_lineloop

		ldz #$00

		jsr uifatview_drawspace

		lda uifatview_tmp+1
		jsr uifatview_drawbytelo
		lda uifatview_tmp+1
		jsr uifatview_drawbytehi
		lda uifatview_tmp+0
		jsr uifatview_drawbytelo
		lda uifatview_tmp+0
		jsr uifatview_drawbytehi

		jsr uifatview_drawspace
		jsr uifatview_drawspace
		jsr uifatview_drawspace

		ldy #$00
ufv_ll1	jsr uifatview_drawcolouredbyte
		jsr uifatview_drawspace
		iny
		cpy #8
		bne ufv_ll1

		jsr uifatview_drawspace

ufv_ll2	jsr uifatview_drawcolouredbyte
		jsr uifatview_drawspace
		iny
		cpy #16
		bne ufv_ll2

		jsr uifatview_drawspace
		jsr uifatview_drawspace

		ldy #$00
ufv_ll3	jsr uifatview_drawchar
		iny
		cpy #16
		bne ufv_ll3

		jsr uidraw_increase_row

		clc
		lda zpptr2+0
		adc #16
		sta zpptr2+0
		lda zpptr2+1
		adc #0
		sta zpptr2+1

		clc
		lda uifatview_tmp+0
		adc #16
		sta uifatview_tmp+0
		lda uifatview_tmp+1
		adc #0
		sta uifatview_tmp+1

		lda zpptr2+1
		cmp #>($c000 + $0200)
		beq :+
		jmp ufv_lineloop

:   	rts

; ----------------------------------------------------------------------------------------------------

uifatview_drawspace
		lda #$a0
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz
		rts

; ----------------------------------------------------------------------------------------------------

uifatview_drawchar
		lda (zpptr2),y
		bne :+
		lda #$04
		sta [uidraw_colptr],z
		lda #$2e
		bra :++
:		lda #$0f
		sta [uidraw_colptr],z
		lda (zpptr2),y
:		and #$3f
		clc
		adc #$80
		sta [uidraw_scrptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz

		rts

; ----------------------------------------------------------------------------------------------------

uifatview_drawcolouredbyte

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

uifatview_drawbytelo

		lsr
		lsr
		lsr
		lsr
		tax
		lda hextodec_inverted,x
		sta [uidraw_scrptr],z
		lda #$39
		sta [uidraw_colptr],z
		inz
		lda #$04
		sta [uidraw_scrptr],z
		inz
		rts

uifatview_drawbytehi

		and #$0f
		tax
		lda hextodec_inverted,x
		sta [uidraw_scrptr],z
		lda #$39
		sta [uidraw_colptr],z
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
