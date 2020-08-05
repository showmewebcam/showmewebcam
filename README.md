Show-me webcam: An open source, trustable, and high quality webcam
--

This firmware transforms your Raspberry Pi 0 W to a high quality webcam for all your Zooming needs.

- [Comparison with laptop built-in webcam and a dedicated camera](http://www.tnhh.net/posts/show-me-webcam.html)

- [Demo video](https://youtu.be/8qo2LUFLHgE)

- [Sample camera picture](http://www.tnhh.net/assets/posts-images/showmewebcam/picam.jpg)

What you need
--
- Raspberry Pi 0 W (I have not tested with the Pi 0 non-Wireless)
- Pi 0 W Camera Ribbon (comes with the Pi 0 camera case or you can buy somewhere else, the stock one that comes with the camera may not fit).
- Raspberry Pi Camera or Raspberry Pi High-Quality Camera
- Micro SD card

What works and what doesn't
--
- I have tested this with Ubuntu 20.04 and Windows 10, both worked.
- I have not tested this build with the Raspberry Pi High-Quality camera.
- As of v1.0, the camera does *not* work with macOS.

Directions
--
- Assemble the camera to the Pi. 
- Download the binary release (down below).
- Download and use Etcher to write the image to the SD card. 
- Use the USB data port (the one in the middle of the Pi, not the one on the edge) to connect to a computer.
- Enjoy!

Binary releases
--
Occasionally I release binary snapshots at the release tab: https://github.com/showmewebcam/showmewebcam/releases

Debugging
--
For debugging, a 115200 baud serial interface is provided as a ttyACM device:
- Please use screen or minicom to connect to it.
- Use username: `root`, password `root`.

Also, there is a *untested* serial interface on the serial 40-pin header: https://pinout.xyz/pinout/uart

If you want to modify the image content the quick-and-dirty way (not recommended):
- Start with the `chroot-to-pi` script: https://gist.github.com/htruong/7df502fb60268eeee5bca21ef3e436eb
- Edit `/bin/bash` to `/bin/sh` on the `chroot /mnt/raspbian /bin/bash` line.

Building
--
Make a directory in your home: `develop`.

- In `develop`, untar the `buildroot-2020.2.3` tar package and rename `buildroot-2020.02.3` to `buildroot`. 
- Get out back to `develop`.
- In `develop`, `git clone` this repo `https://github.com/showmewebcam/showmewebcam` to it.
- Run `./build-showmewebcam.sh`.
- The resulting image will be at the `buildroot/output/image` folder.

Credits
--

- David Hunt: http://www.davidhunt.ie/raspberry-pi-zero-with-pi-camera-as-usb-webcam/
- Buildroot
- ARM fever: https://armphibian.wordpress.com/2019/10/01/how-to-build-raspberry-pi-zero-w-buildroot-image/
- The reposity icon is attributed to the GNOME project
