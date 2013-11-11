
.var picture = LoadBinary("picture.prg", BF_KOALA)

:BasicUpstart2(start)

start:
		// VIC defaults to Bank #0 - Can only access 16k at a time

		//    /-----Screen RAM $0C00
		//    |   /-Select base address $0000 
		//    |   |
		lda #%00111000
		sta $d018

        //       /--Multicolour mode on
        //       |/-Columns = 40 
		//       ||/Scroll = 0
		//       |||
		lda #%11011000
		sta $d016

        //      /----Bitmap mode on
        //      |/---Screen on
		//      ||/--Screen Height = 25 rows
		//		|||/-Veritcal Scroll
		//      |||| 
		lda #%00111011 
		sta $d011

		// Screen Colour
		lda #1
		sta $d020
		lda #0
		sta $d021
		ldx #0
!loop:
		.for (var i=0; i<4; i++) {
			lda colorRam+i*$100,x
			sta $d800+i*$100,x
		}
		inx
		bne !loop-
		// Stick some text on the screen
		ldx #$38
fill:	lda #$20
		sta $3ee8,x
		lda #$03
		sta $dae8,x
		inx
		bne fill
  		ldx #$0
write:	lda data,x
		sta $3f20,x
		inx
		cpx #$3a
		bne write
		// Set up interrupt
		sei
		lda #<irq1
		sta $0314
		lda #>irq1
		sta $0315
		asl $d019
		lda #$7b
		sta $dc0d
		lda #$81
		sta $d01a
		// Set where interrupt should occur
		lda #$D0
		sta $d012
		cli
this:	jmp this
//----------------------------------------------------------
irq1:  	
			asl $d019
			:SetBorderColor(2)
			// Set up the next interrupt
			lda #$FF
			sta $d012
			lda #<irq2
			sta $0314
			lda #>irq2
			sta $0315
			// Set Text Mode
	        //      /----Bitmap mode OFF
	        //      |/---Screen on
			//      ||/--Screen Height = 25 rows
			//		|||/-Veritcal Scroll
			//      |||| 
			lda #%00011011 
			sta $d011
			//    /-------Screen RAM $1000
			//    |   /---Select Character ROM
			//    |   |  X
			lda #%11110100
			sta $d018
			// Restore Y, X and A
			pla
			tay
			pla
			tax
			pla
			rti

//----------------------------------------------------------
irq2:  	
			asl $d019
			:SetBorderColor(0)
			// Set up the next interrupt
			lda #$D0
			sta $d012
			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			// Set High Res Mode
			lda #$3b
			sta $d011
			//    /-----Screen RAM $0C00
			//    |   /-Select base address $0000 
			//    |   |
			lda #%00111000
			sta $d018
			// Restore Y, X and A
			pla
			tay
			pla
			tax
			pla
			rti

data:		.text "base79 are youtube's biggest partner outside north america"
	

//----------------------------------------------------------
.macro SetBorderColor(color) {
	lda #color
	sta $d020
}

.pc = $0c00	"ScreenRam" 			.fill picture.getScreenRamSize(), picture.getScreenRam(i)
.pc = $1c00	"ColorRam:" colorRam: 	.fill picture.getColorRamSize(), picture.getColorRam(i)
.pc = $2000	"Bitmap"				.fill picture.getBitmapSize(), picture.getBitmap(i)



