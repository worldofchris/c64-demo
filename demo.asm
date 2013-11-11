
.var picture = LoadBinary("picture.prg", BF_KOALA)

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
data:       .text "base79 are youtube's biggest partner outside north america and teh most awesome. "
h_offset:   .byte 7
msg_offset: .byte 0
msg_max:    .byte 81

//----------------------------------------------------------
display_message:
        ldx msg_offset
        cpx msg_max
        bne n1
        // at end of message - go back to the beginning
        ldx #0
        stx msg_offset

n1:     ldy #0
write:  lda data,x
        sta $3fC0,y
        inx
        cpx msg_max
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
            // :SetBorderColor(2)
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
            // :SetBorderColor(0)
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
            // Restore Y, X and A
            pla
            tay
            pla
            tax
            pla
            rti
    

//----------------------------------------------------------
// From http://codebase64.org/doku.php?id=base:delay
// Delay to smooth out raster interrupts
//
delay:            // delay 84-accu cycles, 0<=accu<=65
  lsr             // 2 cycles akku=akku/2 carry=1 if accu was odd, 0 otherwise
  bcc waste1cycle // 2/3 cycles, depending on lowest bit, same operation for both
waste1cycle:
  sta smod+1      // 4 cycles selfmodifies the argument of branch
  clc             // 2 cycles 
// now we have burned 10/11 cycles.. and jumping into a nopfield 
smod:
  bcc *+10        // 3 cycles
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
  rts             // 6 cycles


.macro SetBorderColor(color) {
    lda #color
    sta $d020
}

.pc = $0c00 "ScreenRam"             .fill picture.getScreenRamSize(), picture.getScreenRam(i)
.pc = $1c00 "ColorRam:" colorRam:   .fill picture.getColorRamSize(), picture.getColorRam(i)
.pc = $2000 "Bitmap"                .fill picture.getBitmapSize(), picture.getBitmap(i)