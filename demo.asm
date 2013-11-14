
.var picture_1 = LoadBinary("picture.prg", BF_KOALA)

:BasicUpstart2(start)

start:
        // Set up video

        // VIC defaults to Bank #0 - Can only access 16k at a time

        //    /-----Screen RAM $0C00
        //    |   /-Select base address $0000 
        //    |   |
        lda #%00111000
        sta $d018

        //       /--Multicolour mode on
        //       |/-Columns = 40 
        //       ||/Horizontal Scroll = 0
        //       |||
        lda #%11011000
        sta $d016

        //      /----Bitmap mode on
        //      |/---Screen on
        //      ||/--Screen Height = 25 rows
        //      |||/-Veritcal Scroll
        //      |||| 
        lda #%00111011 
        sta $d011

        // Screen Colour
        lda #1
        sta $d020
        sta $d021
        ldx #0
!loop:
        .for (var i=0; i<4; i++) {
            lda colorRam+i*$100,x
            sta $d800+i*$100,x
        }
        inx
        bne !loop-
        // Clear the bottom of the screen
        ldx #$D8
fill:   lda #$20
        sta $3ee8,x
        lda #$00
        sta $dae8,x
        inx
        bne fill
        ldx #$0
        // Write some message text
        jsr display_message
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
this:   jmp this
msg_text:   .text "base79 are youtube's biggest partner outside north america and teh most awesome. "
h_offset:   .byte 7
msg_offset: .byte 0
msg_length: .byte 81

//----------------------------------------------------------
display_message:
        ldx msg_offset
        cpx msg_length
        bne n1
        // at end of message - go back to the beginning
        ldx #0
        stx msg_offset

n1:     ldy #0
write:  lda msg_text,x
        sta $3fC0,y
        inx
        cpx msg_length
        bne n2
        // We hit the end of the message - start at the beginning 
        ldx #0
n2:     iny
        cpy #$28
        bne write
        // Move on to the next character in the message
        inc msg_offset
        rts

//----------------------------------------------------------
irq1:   
            asl $d019
            jsr delay
            jsr delay
            nop
            nop
            // Set Text Mode
            //      /----Bitmap mode OFF
            //      |/---Screen on
            //      ||/--Screen Height = 25 rows
            //      |||/-Veritcal Scroll
            //      |||| 
            lda #%00011011 
            sta $d011
            //    /-------Screen RAM $1000
            //    |   /---Select Character ROM
            //    |   |  X
            lda #%11110100
            sta $d018
            //
            // Scroll the screen
            dec h_offset
            lda h_offset
            sta $d016
            bne carry_on
            // Move the message
            lda #$07
            sta h_offset
            jsr display_message
carry_on:   // Set up the next interrupt
            lda #$10
            sta $d012
            lda #<irq2
            sta $0314
            lda #>irq2
            sta $0315
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
            // Set up the next interrupt
            lda #$EF
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
            //       /--Multicolour mode on
            //       |/-Columns = 40 
            //       ||/Horizontal Scroll = 0
            //       |||
            lda #%11011000
            sta $d016
            // Handle Key presses
            jsr getkey
            beq irq2_done
            // Change image based on where we are in the cycle

            sta $d020
            // Restore Y, X and A
irq2_done:  pla
            tay
            pla
            tax
            pla
            rti
//----------------------------------------------------------
keydown:    .byte 0
state:      .byte 1

getkey: 
           lda $dc01 
           cmp keydown 
           bne newkey 
           lda #$00      // no change 
           rts 
newkey: 
           sta keydown 
           cmp #$ef      // new key is spacebar 
           bne no_space
           inc state     // cycle through states
           lda state
           cmp #$04
           bne no_wrap
           lda #$01
           sta state
no_wrap:   rts

no_space:  lda #$00
           rts


.import source "delay.asm"

.macro SetBorderColor(color) {
    lda #color
    sta $d020
}

.pc = $0c00 "ScreenRam"             .fill picture_1.getScreenRamSize(), picture_1.getScreenRam(i)
.pc = $1c00 "ColorRam:" colorRam:   .fill picture_1.getColorRamSize(), picture_1.getColorRam(i)
.pc = $2000 "Bitmap_1"              .fill picture_1.getBitmapSize(), picture_1.getBitmap(i)

// .pc = $2000 "Bitmap_2"              .fill picture_1.getBitmapSize(), picture_1.getBitmap(i)