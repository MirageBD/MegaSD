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

		;jsr uifatview_drawspace

		lda uifatview_tmp+1
		jsr uifatview_drawbytelo
		lda uifatview_tmp+1
		jsr uifatview_drawbytehi
		lda uifatview_tmp+0
		jsr uifatview_drawbytelo
		lda uifatview_tmp+0
		jsr uifatview_drawbytehi

		jsr uifatview_drawspace
		;jsr uifatview_drawspace
		;jsr uifatview_drawspace

		ldy #$00
ufv_ll1	jsr uifatview_drawcolouredbyte
		jsr uifatview_drawspace
		iny
		cpy #8
		bne ufv_ll1

		;jsr uifatview_drawspace

ufv_ll2	jsr uifatview_drawcolouredbyte
		jsr uifatview_drawspace
		iny
		cpy #16
		bne ufv_ll2

		;jsr uifatview_drawspace
		;jsr uifatview_drawspace

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
:		;and #$3f
		;clc
		tax
		lda uifvhex2ascii,x
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

uifvhex2ascii
		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
		.byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
		.byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f

		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f

		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f

		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
		.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
