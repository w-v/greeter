#!/bin/bash

function failedlogs {

  # get last log timestamp
  lastlog=$(lastlog -u $(whoami)|tail -1)
  
  # remove ip address if not tty
  if [[ -n $(echo $lastlog|grep tty) ]]; then
    lastlog=$(echo $lastlog|awk -F' ' '{print $5,$4,$8,$6}')
  else
    lastlog=$(echo $lastlog|awk -F' ' '{print $6,$5,$9,$7}')
  fi

  # format it for lastb
  lastlog=$(date -d"$lastlog" +%Y%m%d%H%M%S)

  # get the number of failed logins
  # remove the trailing lines

  nb_failed=$(( $(sudo lastb -s $lastlog|wc -l) -2))

  if [[ $nb_failed -gt 0 ]];then
    nb_failed="${esc}$Red$nb_failed"
  else
    nb_failed="${esc}$Green$nb_failed"
  fi
  nb_failed="${esc}$Bold$nb_failed${esc}$Res"
  echo "There were $(echo -e ${nb_failed}) failed login attempts since last login"
}


function lastlogs {
  lastlog=$(last|grep $(whoami)|head -2|tail -1)
  # remove ip address if not tty
  if [[ -n $(echo $lastlog|grep tty) ]]; then
    port=$(echo $lastlog|awk '{print $2}')
    #tm=$(echo $lastlog|tr -s ' '|cut -d' ' -f1-3)
    tm=$(echo $lastlog|awk -F' ' '{print $3,$5,$6,$7,$8,$9,$10}')
    echo "Last successful login was on $port on $tm"
  else
    port=$(echo $lastlog|awk '{print $2}')
    addr=$(echo $lastlog|awk '{print $3}')
    tm=$(echo $lastlog|awk -F' ' '{print $4,$5,$6,$7,$8,$9,$10,$11}')
    echo "Last successful login was from $addr on $port on $tm"
  fi
}

function color {

  num=$(echo "$1"|grep -o "[0-9]*")

  #colors=($Green $Yellow $Red)
  if [ $num -gt $2 ];then
    if [ $num -gt $3 ];then
      if [ $num -gt $4 ];then
        col=3
      else
        col=2
      fi
    else
      col=1
    fi
  else
    col=0
  fi

  echo $col

}


function hdd {
  echo "${esc}${Underlined}HDD              ${esc}${Res}"
  temp=$(eval "$HDDTEMPCMD")"C"
  df=$(df -Ph)
  IFS=$'\n'
  for d in "$temp"; do
    IFS=" "
    t=( $temp )
    usage=($(echo "$df"|grep ${t[0]}|awk '{print $5" "$2" "$6}'))
    #usage=$(echo ${usage[@]}|sed '2,${s/^/\t/}')
    usage=$(echo "$df"|grep ${t[0]}|awk '{print $5" "$2" "$6}')
    IFS=$'\n'
    i=1
    for u in $usage;do
      p=$(echo $u|cut -d' ' -f 1)
      col=${HDDUSAGECOLORS[$(color $p ${HDDUSAGE[@]})]}
      usage=$(echo "$usage"|sed "${i}s/$p/${esc}${Bold}${esc}${col}${p}${esc}$Res/g")
      i=$(($i+1))
    done
    usage=$(echo "$usage"|sed '2,${s/^/\t/}')
    col=${HDDTEMPCOLORS[$(color ${t[1]} ${HDDTEMPS[@]})]}
    t[1]=${esc}${Bold}${esc}${col}${t[1]}${esc}$Res
    echo "${t[@]} $usage"
    IFS=$'\n'
  done
  IFS=" "
}

function cpu {
  temp=$(eval $CPUTEMPCMD)
  tempcol=${CPUTEMPCOLORS[$(color $temp ${CPUTEMPS})]}
  temp=${esc}${Bold}${esc}${tempcol}${temp}"C"${esc}$Res

  load=$(eval $CPULOADCMD)
  IFS=' '
  for l in $load;do
    loadcol=${CPULOADCOLORS[$(color $l ${CPULOADS})]}
    loadf="$loadf"${esc}${Bold}${esc}${loadcol}${l}"%"${esc}$Res" "
  done

  echo "$temp $loadf"
}

function hw {
  echo '\n'
  paste <(cpu) <(hdd) --delimiters ''
}

source conf.sh
source colors.sh


for a in $SYSINFO; do

  $a|fold -w $(($COLUMNS-9))

done


exit;
infos="\
$(echo $lastlogv|fold -w $(($COLUMNS-9)))
$(failedlogs|fold -w $(($COLUMNS-9)))
$(hdd|fold -w $(($COLUMNS-9)))"
