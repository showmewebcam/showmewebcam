# ScriptsForShowMeWebCam

## picamctl.sh

The USB Raspberry Pi Zero showmewebcam is a plug-in-and-it-works webcam system whereas running the showmewebcam camera settings utility program, "camera-ctl", requires arcane technical skills to perform a multistep process. The **picamctl.sh** script performs all the required steps for you.

**picamctl.sh** automates the following:
* Determines the USB connected Raspberry Pi Zero showmewebcam's most likely serial device port name.
* Establishes a 115200 baud serial connection to the Raspberry Pi Zero showmewebcam in a screen session.
* Logs into the Raspberry Pi Zero showmewebcam as root.
* Starts the showmewebcam system's "camera-ctl" utility.

**picamctl.sh** also does the following:

- Starts Apple's PhotoBooth application. Alter or remove that feature from the script as needed.
- Removes all existing Attached and Detached screen instances. Unused screen instances are typically left over by the method used to run "camera-ctl". Alter or remove this feature as needed if you have other screen instances you need to remain.

**How To Use**

**picamctl.sh** is made for use on an Apple OS X computer. It probably works on a Linux machine with an edit to remove or change the PhotoBooth feature and with also an edit to change the device name discovery pattern. Similar alterations probably would be required for it to work on a Windows machine. Look online to explain how to perform any unfamiliar step mentioned below.

* Download **picamctl.sh** to your computer.

**Starting Up**
* Open a Terminal window.
* In the Terminal window change the current directory to be the one where you copied **picamctl.sh**.
* Plug the Raspberry Pi Zero showmewebcam webcam system USB cable into the computer.
* In the Terminal window type in "**./picamctl.sh**" or "**bash ./picamctl.sh**".
* If showmewebcam has yet to finish booting, **picamctl.sh** will make a number of attempts to check for a late startup. 
* The Terminal window should now be logged into the Raspberry Pi Zero showmewebcam system and showing the camera control interface.

**Shut Down**
* Unplug the Raspberry Pi Zero showmewebcam webcam system USB cable from the computer. Unplugging the device powers off the Pi Zero. This is an important step that you might eventually learn the hard way because just terminating the Terminal session without shutting down the Pi Zero leaves the Pi Zero either still running the camera control utility or running in some other unexpected state. Running **picamctl.sh** under those circumstances results in a confused looking screen session.
* Close out the Terminal window.

**Details and Comments**
* picamctl.sh currently runs under bash. It uses a keystroke test routine that does not work in zsh.
* When **picamctl.sh** is started with any argument, for example "**./picamctl.sh  p**", the script pauses for confirmation instead of starting to make the serial connection. This mode can be used for troubleshooting the serial device name it has selected to use for the connection.

**Showmewebcam is found at:**
<https://github.com/showmewebcam/showmewebcam>
