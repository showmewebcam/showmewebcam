# Show-me webcam: An open source, trustable and high quality webcam

[![Build/Release](https://github.com/showmewebcam/showmewebcam/workflows/Build/Release/badge.svg)](https://github.com/showmewebcam/showmewebcam/actions)
[![License](https://img.shields.io/github/license/showmewebcam/showmewebcam?label=License)](https://github.com/showmewebcam/showmewebcam/blob/master/LICENSE)
[![Last Release](https://img.shields.io/github/release/showmewebcam/showmewebcam.svg?label=Last%20Release)](https://github.com/showmewebcam/showmewebcam/releases/)
[![Total Downloads](https://img.shields.io/github/downloads/showmewebcam/showmewebcam/total.svg?label=Total%20Downloads)](https://github.com/showmewebcam/showmewebcam/releases/)
[![Discord Chat](https://img.shields.io/discord/774949618832113674.svg?label=Discord%20Chat)](https://discord.gg/dTc4jtf3YX)

This firmware transforms your Raspberry Pi into a high quality webcam. It works reliably, boots quickly, and gets out of your way.

### [Wiki & Documentation](https://github.com/showmewebcam/showmewebcam/wiki) | [Discord Chat](https://discord.gg/dTc4jtf3YX) | [Introduction video](https://youtu.be/nH2G16YoBT4) | [Hackaday Project](https://hackaday.io/project/174479-raspberry-pi-0-hq-usb-webcam)

Show-me webcam is proudly powered by [peterbay's uvc-gadget](https://github.com/peterbay/uvc-gadget).

## What you need

- Raspberry Pi Zero with or without Wifi
- Raspberry Pi Zero Camera Adapter/Ribbon (The one that comes with the camera may not fit)
- Raspberry Pi Camera or Raspberry Pi High-Quality Camera
- [A compatible lens](https://github.com/showmewebcam/showmewebcam/wiki/Lenses) if you use the HQ Camera sensor
- Micro SD card (at least 64MB)
- A [case or mounting plate](https://github.com/showmewebcam/showmewebcam/wiki/Cases) (optional)

## What works and what doesn't

- The camera is known to work on Linux, Windows 10 and Mac OS
- The camera is known to work with Zoom, Teams, Jitsi, Firefox and Chrome
- Here's a compatibility matrix as far as we could test. Let us know if you had the chance to test other variants:

| Raspberry Pi \ Camera version  | v1 5MP  | v2 8MP  | High Quality 12MP |
| ------------------------------ | ------- | ------- | ----------------- |
| Pi Zero v1.3 (without Wifi)    | &check; | &check; | &check;           |
| Pi Zero W (with Wifi)          | &check; | &check; | &check;           |
| Pi 4+                          |         | &check; | &check;           |

## Instructions

- Watch the [introduction video](https://youtu.be/nH2G16YoBT4)
- [Assemble the camera with the Raspberry Pi](https://www.youtube.com/watch?v=8fcbP7lEdzY&t=365s)
- Download the latest release (see below)
- Use Etcher or `dd` to write the image to the Micro SD card
- Use the USB data port (the one in the middle of the Raspberry Pi, not the one on the edge) to connect to a computer
- Smile & Enjoy!

## Stable releases

We release new versions of this firmware regularly at the release tab:
https://github.com/showmewebcam/showmewebcam/releases

## LED indicator

After booting, the built-in LED will blink three times quickly to show you it's ready.

When the camera is in use the LED will be lit. In addition,
[GPIO 21](https://pinout.xyz/pinout/pin40_gpio21#) pin is set to `HIGH`, so an
external LED or another payload can be triggered with this pin to indicate that
the camera is in use.


## Debugging

For debugging, a 115200 baud serial interface is provided as a `ttyACM` device:
- Use screen, minicom, picocom or the included `smwc-expect` script to connect to it
- Use username: `root`, password `root`

Also, there is a serial interface on the 40-pin header: https://pinout.xyz/pinout/uart

Linux example:
```
$ ls -l /dev/ttyACM*
crw-rw---- 1 root dialout 166, 0 sep 25 14:03 /dev/ttyACM0
$ sudo screen /dev/ttyACM0 115200
```

Mac OS example:
```
$ ls -l /dev/tty.*
crw-rw-rw-  1 root  wheel    9,  18 Dec  7 13:14 /dev/tty.usbmodem13103
$ screen /dev/tty.usbmodem13103 115200
```

If the terminal is blank try pressing enter to see the login prompt. To exit
the session, use `Ctrl-A \` (screen) or `Ctrl-A X` (minicom & picocom).

**Warning**: This serial debug interface is automatically enabled and is controlled
by the file called `enable-serial-debug` in the `/boot` folder. This is a potential
security issue. For now, you should strongly consider disabling this feature by
removing the file after you have finished customizing the webcam.


### My camera doesn't show up on my host computer! What to do?

From version 1.80, on Linux, you can see what happens by watching `dmesg`
before you plug in the webcam:

```
$ sudo dmesg -w
```

If you only see the `ttyACM` device show up, but not the webcam, it's likely you
have not plugged in the camera cable correctly, or the camera cable has gone bad.

If you see nothing, maybe your USB cable is bad, or you have plugged in the cable
to the wrong port.


## Customizing camera settings

### Automatic

Log in to the debug interface and execute:

```bash
/usr/bin/camera-ctl
```

This tool will allow you to show and tweak all available camera parameters.
Additionally it will save your settings to `/boot/camera.txt` if you choose to
do so. This will handle remounting `/boot` automatically.

### Manual

#### Overriding camera settings temporarily

Log in to the debug interface. Then list all tweakable parameters:

```bash
/usr/bin/v4l2-ctl -L | less
```

Then you can apply parameters on the fly, e.g.

```
/usr/bin/v4l2-ctl -c auto_exposure_bias=15
/usr/bin/v4l2-ctl -c contrast=3
```

#### Overriding camera settings permanently

Mount the SD card on your computer, edit a file called `camera.txt` in
`/boot` and put all parameters you want overridden, e.g:

```
# Tweak the auto exposure bias
auto_exposure_bias=15
# Tweak the contrast
contrast=3
```

You can edit `camera.txt` on-target by remounting `/boot` read-write:

```bash
mount -o remount,rw /boot
```

### Overriding the controls available to the host computer

Since version 1.80 we try to expose as many controls as possible via the UVC
standard, which are then translated back to the controls that are available
on your specific camera module. Some host operating systems may be confused
by controls that are advertised via USB, but don't turn out to work, due to
not being available for your specific camera module.

You can therefore customize the controls advertised to the computer via the
USB device descriptor. *Warning*: This is an advanced user feature only.
You should probably consult the [UVC controls bitmap documentation] on GitHub.

You can add the parameters to `cmdline.txt` on the boot volume as follows:

```
usb_f_uvc.camera_terminal_controls=0,0,0 usb_f_uvc.processing_unit_controls=0,0
```

The previous example sets all controls to disabled, and should thus be safe.
The parameters directly correspond to the `bmControls` bitfields in the descriptor.
Please, again, read the documentation linked above.

## Development & building

Clone or download this repository. Then inside it:

- Download the latest Buildroot stable from https://buildroot.org/download.html
- Extract it and rename it to `buildroot`
- Run build command:
  - `./build-showmewebcam.sh raspberrypi0w` to build Raspberry Pi Zero W (with Wifi) image.
  - `./build-showmewebcam.sh raspberrypi0` to build Raspberry Pi Zero (without Wifi) image.
  - `./build-showmewebcam.sh raspberrypi4` to build Raspberry Pi 4 image.
  - **IMPORTANT**: If you didn't rename your Buildroot directory to `buildroot` or if you put it somewhere else you need to set the Buildroot path manually, e.g. `BUILDROOT_DIR=../buildroot ./build-showmewebcam.sh raspberrypi0`
- The resulting image `sdcard.img` will be in the `output/$BOARDNAME/images` folder
- If you add a `camera.txt` file to the root of this repository, the contents will be automatically added to `/boot/camera.txt`

## Credits

- David Hunt: http://www.davidhunt.ie/raspberry-pi-zero-with-pi-camera-as-usb-webcam/
- Petr Vavřín: [uvc-gadget](https://github.com/peterbay/uvc-gadget)
- Buildroot
- ARM fever: https://armphibian.wordpress.com/2019/10/01/how-to-build-raspberry-pi-zero-w-buildroot-image/
- The repository icon is attributed to the GNOME project


[UVC controls bitmap documentation]: https://github.com/showmewebcam/showmewebcam/wiki/UVC-Controls
