# C64 Demo

![Logo](http://public.base79.com/bitbucket/base79-c64.png)

# About

In order to show off our l33t skillz and love of all things tech we are making a little demo to run on a vintage Commodore 64 at [Silicon Milk Roundabout](http://siliconmilkroundabout.com/).

It's written in 6502 Assembler using the [Kick Assembler](http://www.theweb.dk/KickAssembler/Main.php).

Images are converted from .pngs by first converting them to .ppm files using [Image Magick](http://www.imagemagick.org/script/index.php) and then converting them to the [Koala File format](http://en.wikipedia.org/wiki/KoalaPad#File_format) using [C64Gfx](http://koti.kapsi.fi/a1bert/Dev/C64Gfx/).

The .d64 image that gets loaded onto the C64 is made using the C1541 tool that comes with the [Vice Emulator](http://vice-emu.sourceforge.net/).

# Usage

To install the tool dependencies required to build the demo run `install_tools.sh`.  This will install the tools required in a directory called `tools`.

You'll then be prompted to install a version of the [Vice Emulator](http://vice-emu.sourceforge.net/) for your machine.

Once the dependencies are installed run `make`.  This will create a .d64 image for use in Vice or on real hardware.
