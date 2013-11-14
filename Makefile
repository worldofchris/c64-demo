# Base79 C64 Demo - Initially for Silicon Milk Roundabout Stand

# KICK_HOME needs to include path to The Kick Assembler available from:
# http://www.theweb.dk/KickAssembler/Main.php

KICKASS_JAR=$(KICK_HOME)/KickAss.jar
PPM_TO_KOALA=$(C64GFX_HOME)/src/ppmtokoala
C1541=$(VICE_HOME)/tools/c1541

demo.d64:	demo.prg
	$(C1541) -format diskname,id d64 demo.d64 -attach demo.d64 -write demo.prg demo

demo.prg:	demo.asm picture.prg
	java -jar $(KICKASS_JAR) demo.asm

picture.prg:	picture.ppm Makefile
	$(PPM_TO_KOALA) -v < picture.ppm > picture.prg

picture.ppm:	picture.png
	convert picture.png -remap palette.gif -resize 160x200\! picture.ppm

clean:
	rm *.prg
	rm *.d64
	rm *.sym
	rm *.ppm