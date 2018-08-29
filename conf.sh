#!/bin/bash

source ./colors.sh

P=$(pwd)
IMG_PTH=$P'/img/'
COW_PATH=$P'/cows/'
COW_FILE="${COW_PATH}"'greeter.cow'
MSG_FILE=$P'/msg'
FONT_DIR=$P'/fonts/large'

COLUMNS=$(tput cols)
LINES=$(tput lines)

# expects output like : "drive_id temp"
HDDTEMPCMD="sudo /usr/sbin/hddtemp /dev/sd?|tr -d :|sed 's/\/dev\///'|cut -d' ' -f1,3"
HDDTEMPS=( 35 50 60 )
HDDTEMPCOLORS=( $Lblue $Lyellow $Yellow $Lred )
HDDUSAGE=(70 80 90)
HDDUSAGECOLORS=( $Green $Lyellow $Yellow $Lred )

# put commands here for system info
SYSINFO="\
  lastlogs 
  failedlogs 
  hdd"

