#!/bin/bash
# akseidel 02/06/2021
# A script automating the steps to run showmewencam's "camera-ctl".
# The script will pause for continue or exit if run with an argument.

# edit this next line to be the correct text pattern for your computer.
portnamepat="tty.usbmodem" #typical for showmewebcam on Appl OS X
#portnamepat="ttyACM" #probably typical for showmewebcam on Linux
#portnamepat="tty."
# The client is an application you want this script to also run. 
runtheclient="true"
clientname="Photo Booth"

# initial cleanup
initclean(){
    reset
    clear
    # terminates all the ort screen sessions.
    screen -ls | grep Attached | cut -d. -f1 | awk '{print $1}' | xargs kill
    screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
}

# run the client application
runclient(){
    if [ "$runtheclient" = "true" ]; then
        # -g causes application to open in background 
        # https://scriptingosx.com/2017/02/the-macos-open-command/
        open -g -a "$clientname"
    fi
}

# start the screen session
doscreensession(){
    echo ""
    echo "Now establishing serial connection using 'screen' ..."
    # For some reason screen stuffing the user, password and camera-ctl to
    # a detached target screen does not work without the target screen having
    # been attached at some point. Here the nest screen into a spawner screen
    # trick is used to get around that.   
    screen -dmS spawner
    screen -S spawner -X screen screen -dR thispicam "$piusbwebcamport" 115200
    sleep 0.3
    screen -S thispicam -X detach
    sleep 0.3
    screen -S thispicam -X stuff $'root\n'
    sleep 0.3
    screen -S thispicam -X stuff $'root\n'
    sleep 0.3
    screen -S thispicam -X stuff $'camera-ctl\n'
    screen -r thispicam
}

# show intro text
showintro(){
    echo "======================================================================"   
    echo "                             picamctl                                 "
    echo "======================================================================"       
    echo "  This script looks for a serial port device that could be the        "  
    echo "  Showmewebcam USB webcam device. It will connect to the device, log  "
    echo "  in as root and then run the camera settings control utility.        " 
    echo "----------------------------------------------------------------------"
    echo "  Looking for a device like: /dev/$portnamepat                        "
}

# collect the port names
getportnames(){
    serialportlist=$(find /dev/"$portnamepat"* 2> /dev/null)
    countofserialportslist=$(find /dev/"$portnamepat"*  2> /dev/null | wc -l)
}

# report port qty
rptportqty(){
    echo "  $((countofserialportslist+0)) such ports found."
}

# report ports
rptportlist(){
    echo " " "$serialportlist" 2> /dev/null
}

# set port to use and show it
dosetport(){
    # changes item space separator to a newline and returns tail item
    piusbwebcamport=$(echo "$serialportlist" | tr ' ' '\n' | tail -1)
    echo "  Assuming this last one => " "$piusbwebcamport"
    echo "======================================================================"
}

# option for pause and exit if any argument present, for diagnostic use
option2exit(){
    if [ -n "$1" ]
    then
        while read -r -s -p "Press any key when ready to continue. (ESC key quits)" -n1 key 
        do
            # check for escape key
            if [[ $key == $'\e' ]]; then
                echo ""
                echo "Ok, Bye"
                exit 0
            else
                break
            fi
        done
    fi
}

# checkboot status
checkbootstatus(){
while [ "$countofserialportslist" -eq 0 ]; do
        echo ""
        echo "  None found! Got that USB thing plugged in or waited the 10 seconds"
        echo "  needed for booting up? Periodic boot checking is now happening."
        echo "======================================================================"
        echo ""
        chk=1
        chklim=12
        while [ $chk -le $chklim ]
            do
                echo -ne "  Checking for a ready showmewebcam. Attempt $chk out of $chklim  ... \r"
                getportnames
                if [ ! "$countofserialportslist" -eq 0 ]; then
                    break 2
                fi
                chk=$(( chk + 1 ))
                sleep 2
            done
        echo -e "  Run this again when the camera is ready.                             "
        echo ""
        exit 
    done
}

# program section

initclean
showintro
getportnames
rptportqty   
checkbootstatus
rptportlist
dosetport
option2exit "$1"
runclient
doscreensession

# end        
