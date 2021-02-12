#!/bin/sh

# Volume coming out of adau7002 is too low so we pass it through ALSA softvol.
# We need to use softvol before amixer can see it, so record to /dev/null for
# one second.
arecord -Ddmic_sv -fS32_LE -c2 -r48000 -s1 > /dev/null

# Set boost volume
amixer set Boost 85%

# Connect output of softvol to uac2.usb0 USB audio gadget to send to host
alsaloop -Cdmic_sv -fS32_LE -c2 -r48000 -S5 -Pplughw:1,0 -v -d
