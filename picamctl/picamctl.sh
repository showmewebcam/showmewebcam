#!/bin/sh
# akseidel 02/06/21 04/18/21
# https://github.com/akseidel/ScriptsForShowMeWebCam
# A script automating the steps to run showmewebcam's "camera-ctl".
#
# To use from the residing folder:
# First mark as executable with "chmod +x picamctl.sh".
# In OSX run by entering "./picamctl.sh".
# In Linux run by entering "sudo ./picamctl.sh" followed by root
# password.
#
# Script arguments:
# -h help
# -m manual logging in to Pi Zero
# -d diagnostic halt
# -nc do not run the client
# -c run client and use next argument for the client name
# For example: ./picamctl.sh -c "Quicktime Player"

# print name header if needed
doheader(){
        printf "======================================================================\n"   
        printf "                             picamctl                                 \n"
}

# linux run as root warning and maybe stop
# takes argument as to whether or not to proceed
notroot(){
    if ! [ "$(id -u)" = 0 ] && [ "$(uname -s)" = "Linux" ]; then   
            if [ "$1" = "stop" ]; then
                printf "\n=== Halting now. This script must be run as root. ie using sudo ======\n\n"              
                exit 0
            else
                printf "======================================================================\n"   
                printf "\n     !!! On Linux this script must be run as root. ie using sudo    \n\n"  
            fi
        fi
}

# init per the operating system
# portnamepat is the serial device port name pattern
# The client is an application you want this script to also run.
# Edit this section accordingly for your computer.
initperos(){
    doheader
    chk4screen
    case "$(uname -s)" in
    Darwin)
        portnamepat="tty.usbmodem" 
        #portnamepat="tty."
        runtheclient="true"
        clientname="Photo Booth"
        ;;
    Linux)
        portnamepat="ttyACM"
        #portnamepat="tty*"
        runtheclient="true"
        clientname="/usr/bin/webcamoid"
        notroot ok
        ;;
    # Yet to do Windows implementation
    #CYGWIN*|MINGW32*|MSYS*|MINGW*)
    #    ;;
    *)
        #prinf "Other OS\n"
        portnamepat="ttyACM"
        #portnamepat="tty*"
        runtheclient="false"
        #clientname="???"
        ;;
    esac  
}

# check for screen on this system
chk4screen(){
if ! command -v "screen" > /dev/null 2>&1 ; then
    printf "======================================================================\n" 
    printf " ! There is a minor problem. The 'screen' utility command is required\n"
    printf " for establishing communication to the Raspberry Pi. This utility\n"
    printf " command needs to be installed.\n"
    printf "\n It can be installed using the command:\n"
    printf "\n     sudo apt install screen -y\n"
    printf "\n The administrative password may be necessary for the installation.\n"
    printf "======================================================================\n" 
    exit 0
fi
}

# initial cleanup
initclean(){
    reset
    clear
    # terminates all the ort screen sessions due to this.
    screen -ls | grep "spawner\|thispicam" | cut -d. -f1 | awk '{print $1}' | xargs kill 2> /dev/null
}

# are diagnostics wanted
arediagwanted(){
  if [ "$diagmode" = "true" ]; then
    showdiagnostics
    exit 0
  fi
}

# React to arguments passed
# -h show help
# -m manual logging in to Pi Zero
# -d diagnostic halt
# -nc do not run the client
# -c run client and use next argument for the client name
doreacttoargs(){
    i=1;
    j=$#;
    autolog="true"
    while [ $i -le $j ] 
      do
        if [ "$1" = '-h' ]; then
            showhelp
            exit 0
        fi
        if [ "$1" = '-m' ]; then
            autolog="false"
        fi
        if [ "$1" = '-d' ]; then
            diagmode="true"
        fi
        if [ "$1" = '-nc' ]; then
            runtheclient="false"
        fi
        if [ "$1" = '-c' ]; then
            runtheclient="true"
            # next argument assumed to be the client name
            # this needs so error trapping
            i=$((i + 1));
            shift 1;
            clientname="$1"       
        fi
        i=$((i + 1));
        shift 1;
      done
}

# showdiagnostics
showdiagnostics(){
    printf "\nDiagnostic stop and report\n"
    printf "OS: %s\n" "$(uname -s)"
    printf "runtheclient: %s\n" "$runtheclient"
    printf "clientname: %s\n" "$clientname"
    printf "portnamepat: %s\n" "$portnamepat"
    printf "searching: /dev/%s*\n" "$portnamepat"
    printf "serialportlist: %s\n" "$serialportlist"
    printf "countofserialportlist: %s\n" "$((countofserialportslist+0))"
    piusbwebcamport=$(printf "%s" "$serialportlist" | tr ' ' '\n' | tail -1)
    printf "piusnwebcamport: %s\n" "$piusbwebcamport"
    printf "autolog: %s\n" "$autolog"
    printf "Done\n"
}

# showhelp
showhelp(){
    printf "\n Usage: picamctl.sh [OPTIONAL ARGUMENTS]\n"
    printf " Purpose: Automate running camera-ctl on showmewencam system while also\n"
    printf " running a client application to show the video.\n"
    printf " -h  Shows this help.\n"
    printf " -m  Makes serial connection but does not log in.\n"
    printf " -d  Show settings and diagnostics on this script. Then halts.\n"
    printf " -nc Do not run the client application.\n"
    printf " -c \"client application name\" Name a specific client application to run.\n"
    printf " The client application name might need to be a full pathname.\n"
    printf "\n Example=> ./picamctl.sh -d -m -c \"/usr/bin/qv4l2\" -nc\n"
    printf " Sets the client application name, but will not run it. Login will be\n"
    printf " manual. The script will halt after showing all its settings.\n\n"
    printf " Linux users not operating as root user need to run this using sudo.\n"
    printf " Example=> sudo ./picamctl.sh\n\n"
}

# msg no client found
msgclientN(){
   printf "  Unable to find application named %s!\n" "$1"
}

# msg client started
msgclientY(){
   printf "  Starting %s ...\n" "$1"
}

# run the client application
runclient(){
    # do run client?
    if [ "$runtheclient" = "true" ]; then
        # is clientname not blank?
        if [ "$clientname" != "" ]; then
                case "$(uname -s)" in
                Darwin)
                    # -g causes application to open in background 
                    # -a application
                    if ! open -g -a "$clientname" 2> /dev/null; then
                        msgclientN "$clientname"
                    else
                        msgclientY "$clientname"
                    fi
                    ;;
                Linux)
                    # does client exist?
                    if ! command -v "$clientname" >/dev/null 2>&1 ; then
                        msgclientN "$clientname"
                    else
                        # Start a detached screen session running the client app
                        # refered as webcamapp
                        screen -dmS webcamapp "$clientname"
                        msgclientY "$clientname"
                    fi
                    ;;
                # Yet to do Windows implementation
                #CYGWIN*|MINGW32*|MSYS*|MINGW*)
                #    ;;
                *)
                    ;;
                esac
                # A slight pause is required after starting the client to avoid having the newly starting
                # client negociating with the piwebcam during the subsequent serial connection for
                # starting the camerta-ctl utility. Sometimes this interfers with the process. Othertimes 
                # it results warning statements issued by showmewebcam that are briefly visible before
                # the camera-ctl inferface shpws up.
                sleep 1.5
        else
            printf "  The client name is blank.\n"
        fi
    fi
}

# start the screen session
doscreensession(){
    printf "  Now establishing serial connection using 'screen' ...\n"
    # For some reason screen stuffing the user, password and camera-ctl to
    # a detached target screen does not work without the target screen having
    # been attached at some point. Here the nest screen into a spawner screen
    # trick is used to get around that.
    # The sleep lines were found to be required and the minimum sleep time durations
    # were found to vary per OS and computer.
    if [ "$autolog" = "true" ]; then
        screen -dmS spawner
        screen -S spawner -X screen screen -dR thispicam "$piusbwebcamport" 115200
        sleep 0.8
        screen -S thispicam -X detach
        sleep 0.4
        # Even though we have the autologin version of showmewebcam there remains
        # an underlying issue with showmewebcam that trashes the startup prompt by
        # adding trash at the last line where camera-ctl would be entered. Leaving
        # these now benign login lines happens to clear those extra characters.
        screen -S thispicam -X stuff "$(printf "%b" 'root\r')"
        sleep 0.2
        screen -S thispicam -X stuff "$(printf "%b" 'root\r')"
        sleep 0.2
        screen -S thispicam -X stuff "$(printf '%b' "camera-ctl\r")"
        sleep 0.2
        screen -r thispicam
    else
        screen -S thispicam "$piusbwebcamport" 115200
    fi
}

# show intro text
showintro(){
    printf "======================================================================\n"       
    printf "  This script looks for a serial port device that could be the        \n"  
    printf "  Showmewebcam USB webcam device. It will connect to the device, log  \n"
    printf "  in as root and then run the camera settings control utility.        \n" 
    printf "======================================================================\n"
    printf "  Looking for a device like: /dev/%s*\n" "$portnamepat"
}

# collect the port names
getportnames(){
    serialportlist=$(find "/dev/$portnamepat"* 2> /dev/null)
    countofserialportslist=$( find "/dev/$portnamepat"*  2> /dev/null | wc -l) 2> /dev/null
}

# report port qty
rptportqty(){
    printf "  %s such ports found.\n" "$((countofserialportslist+0))"
}

# report ports
rptportlist(){
    printf "  %s\n" "$serialportlist" 2> /dev/null
}

# set port to use and show it
dosetport(){
    # changes item space separator to a newline and returns tail item
    #piusbwebcamport=$(echo "$serialportlist" | tr ' ' '\n' | tail -1)
    piusbwebcamport=$(printf "%s" "$serialportlist" | tr ' ' '\n' | tail -1)
    printf "  Assuming this last one => %s\n" "$piusbwebcamport"
    printf "======================================================================\n"
}

# checkboot status repeatedly gets the matching serial port names looking
# for at least one matching name. 
checkbootstatus(){
while [ "$countofserialportslist" -eq 0 ]; do
        printf "\n  None found! Got that USB thing plugged in or waited the 10 seconds\n"
        printf "  needed for booting up? Periodic boot checking is now happening.\n"
        printf "======================================================================\n\n"
        chk=1
        chklim=12
        while [ $chk -le $chklim ]
            do
                printf "  Checking again for a ready showmewebcam. Attempt %s out of %s ... \r" "$chk" "$chklim"
                getportnames
                if [ ! "$countofserialportslist" -eq 0 ]; then
                    printf "\n  Bingo! Looks like showmewebcam is now ready.\n"
                    break 2
                fi
                chk=$(( chk + 1 ))
                sleep 2
            done
        printf "  Run this again when the camera is ready.                             \n\n"
        exit 
    done
}

# program section

initclean
initperos
doreacttoargs "$@"
showintro
getportnames
rptportqty
arediagwanted 
checkbootstatus 
rptportlist
dosetport
runclient
notroot stop
doscreensession

# end