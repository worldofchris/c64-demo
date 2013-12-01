
.var picture_1 = LoadBinary("picture_1.koa", BF_KOALA)
.var picture_2 = LoadBinary("picture_2.koa", BF_KOALA)
.var picture_3 = LoadBinary("picture_3.koa", BF_KOALA)

:BasicUpstart2(start)

start:
        // Bank out Basic so we can stick our graphics under there
        lda $0001
        and #%11111110
        sta $0001

        // Set up video

        // VIC defaults to Bank #0 - Can only access 16k at a time

        lda $DD00
        and #%11111100
        ora #%00000010 // <- your desired VIC bank value, see above
        sta $DD00

        //    /-----Screen RAM $0C00
        //    |   /-Select base address $2000 
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
            lda colorRam_1+i*$100,x
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
msg_text:   .text "base79 are youtube's biggest partner outside north america.  we make value from video with python, node.js, backbone, d3, lean and agile. "
h_offset:   .byte 7
msg_offset: .byte 0
msg_length: .byte 138

//----------------------------------------------------------
display_message:
        ldx msg_offset
        cpx msg_length
        bne n1
        // at end of message - go back to the beginning
        ldx #0
        stx msg_offset

        // change the state + cycle the image
        jsr load_color

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
            // Reset the VIC Bank
            lda $DD00
            and #%11111100
            //          /--Bank 00
            //          |
            ora #%00000011 
            sta $DD00
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop
            nop            
            nop            
            nop
            nop            
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
carry_on:   
            // Set up the next interrupt
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
            lda #$F0
            sta $d012
            lda #<irq1
            sta $0314
            lda #>irq1
            sta $0315
            // Depending on which state we are in set VIC Bank accordingly
            lda state
            cmp #$01
            beq state_1
            cmp #$02
            beq state_2
            lda $DD00
            and #%11111100
            //          /--Bank 02
            //          |
            ora #%00000001 
            jmp set_bank
state_1:
            lda $DD00
            and #%11111100
            //          /--Bank 00
            //          |
            ora #%00000011 
            jmp set_bank
state_2:
            lda $DD00
            and #%11111100
            //          /--Bank 01
            //          |
            ora #%00000010 

set_bank:   sta $DD00

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

            jsr load_color

            // Restore Y, X and A
irq2_done:  pla
            tay
            pla
            tax
            pla
            rti

//----------------------------------------------------------
load_color: // cycle state
            inc state
            lda state
            cmp #4
            bne done
            lda #1
            sta state
done:
            // Change color map
            cmp #$01
            beq color_1
            cmp #$02
            beq color_2
            ldx #0
!loop:
            .for (var i=0; i<4; i++) {
                lda colorRam_3+i*$100,x
                sta $d800+i*$100,x
            }
            inx
            bne !loop-
            jmp recolor

color_1:    ldx #0
!loop:
            .for (var i=0; i<4; i++) {
                lda colorRam_1+i*$100,x
                sta $d800+i*$100,x
            }
            inx
            bne !loop-
            jmp recolor
color_2:    ldx #0
!loop:
            .for (var i=0; i<4; i++) {
                lda colorRam_2+i*$100,x
                sta $d800+i*$100,x
            }
            inx
            bne !loop-
recolor:
            ldx #$D8
    !fill:  lda #$00
            sta $dae8,x
            inx
            bne !fill-
            rts

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
           lda #$01
no_wrap:   rts

no_space:  lda #$00
           rts


.import source "delay.asm"

.pc = $0c00 "ScreenRam_1"             .fill picture_1.getScreenRamSize(), picture_1.getScreenRam(i)
.pc = $1c00 "ColorRam_1:" colorRam_1:   .fill picture_1.getColorRamSize(), picture_1.getColorRam(i)
.pc = $2000 "Bitmap_1"              .fill picture_1.getBitmapSize(), picture_1.getBitmap(i)

.pc = $4c00 "ScreenRam_2"             .fill picture_2.getScreenRamSize(), picture_2.getScreenRam(i)
.pc = $6000 "Bitmap_2"              .fill picture_1.getBitmapSize(), picture_2.getBitmap(i)
.pc = $7F40 "ColorRam_2:" colorRam_2:   .fill picture_2.getColorRamSize(), picture_2.getColorRam(i)


.pc = $8c00 "ScreenRam_3"             .fill picture_3.getScreenRamSize(), picture_3.getScreenRam(i)
.pc = $A000 "Bitmap_3"              .fill picture_1.getBitmapSize(), picture_3.getBitmap(i)
.pc = $BF40 "ColorRam_3:" colorRam_3:   .fill picture_3.getColorRamSize(), picture_3.getColorRam(i)
