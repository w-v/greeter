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

CPUTEMPCMD="sensors|grep Core|awk '{ sum += "'$3'" } END { if (NR > 0) print sum / NR }'";
CPUTEMPCOLORS=( $Lblue $Lyellow $Yellow $Lred )
CPUTEMPS=(50 70 90)
# expects output like : "load1 load5 load15"
CPULOADCMD="cat /proc/loadavg | awk '{print \$1*100\" \"\$2*100\" \"\$3*100\" \"}'"
CPULOADS=(50 70 90)
CPULOADCOLORS=( $Green $Lyellow $Yellow $Lred )
#echo $(eval $CPUTEMPCMD)
#echo $(eval "$CPULOADCMD")

# put commands here for system info
SYSINFO="\
  lastlogs 
  failedlogs 
  hdd
  cpu"

