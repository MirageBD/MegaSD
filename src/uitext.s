.segment "TEXT"

uitxt_sector			.byte "sector", 0

uitxt_sectordirent		.byte "directory entry", 0
uitxt_sectordirenthi	.byte "0000", 0
uitxt_sectordirentlo	.byte "0000", 0
uitxt_sectordirentof	.byte "0000", 0

uitxt_sectorfatent		.byte "fat32 entry", 0
uitxt_sectorfatenthi	.byte "0000", 0
uitxt_sectorfatentlo	.byte "0000", 0
uitxt_sectorfatentof	.byte "0000", 0

uitxt_sectorfile		.byte "file content", 0
uitxt_sectorfilehi		.byte "0000", 0
uitxt_sectorfilelo		.byte "0000", 0
uitxt_sectorfileof		.byte "0000", 0

uitxt_save				.byte "save", 0

uitxt_show				.byte "show", 0

uitxt_finetune			.byte "finetune", 0
uitxt_volume			.byte "volume", 0
uitxt_length			.byte "length", 0
uitxt_repeat			.byte "repeat", 0
uitxt_repeatlen			.byte "repeatlen", 0

uitxt_songs				.byte "songs", 0
uitxt_instruments		.byte "instruments", 0
uitxt_samples			.byte "samples", 0
uitxt_edit				.byte "edit", 0
uitxt_sample			.byte "sample", 0

uitxt_bpm				.byte "bpm", 0

uitxt_status			.byte "status", $3a, " all right", 0

uitxt_checkbox			.byte "checkbox", 0
uitxt_radiobutton		.byte "radiobtn", 0

uitxt_paddlex			.byte "$d419", 0
uitxt_paddley			.byte "$d41a", 0

uitxt_sectorwrite		.byte "SAMPLE TEXT TO WRITE TO FILE", 0

la1boxtxt
.repeat 32, I
						.word .ident(.sprintf("la1boxtxt%s", .string(I)))
.endrepeat
						.word $ffff

.repeat 32,I
	.ident(.sprintf("la1boxtxt%s", .string(I)))
		.byte "                       ", 0
.endrepeat


tvboxtxt
.repeat 64, I
						.word .ident(.sprintf("tvboxtxt%s", .string(I)))
.endrepeat
						.word $ffff

.repeat 64,I
	.ident(.sprintf("tvboxtxt%s", .string(I)))

		.byte $ff, $0f, "... ", $ff, $0f, ".. ", $ff, $0f, "...", "  "
		.byte $ff, $0f, "... ", $ff, $0f, ".. ", $ff, $0f, "...", "  "
		.byte $ff, $0f, "... ", $ff, $0f, ".. ", $ff, $0f, "...", "  "
		.byte $ff, $0f, "... ", $ff, $0f, ".. ", $ff, $0f, "..."

		.byte 0
.endrepeat

uitxt_samplebox			.byte 0, "a                     "
uitxt_filenamebox		.byte 0, "babe                          "

fa1directorytxt			.byte 0, "                              "

.align 256

fa1boxtxt				.word fa1boxtxt00
						.word $ffff

						.repeat 512
						.byte 0
						.endrepeat

.align 256				; leave enough room for fa1boxtxt to grow. 256 directory entries allowed

fa1boxtxt00				.byte %00010000, $31, $03, "",            0
