#!/bin/bash

cd ../buildroot
BR2_EXTERNAL=../showmewebcam/ make raspberry0cam_defconfig
make all
