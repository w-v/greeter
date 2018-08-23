#!/bin/bash

P=$(pwd)
IMG_PTH=$P'/img/'
COW_PATH=$P'/cows/'
COW_FILE="${COW_PATH}"'greeter.cow'
MSG_FILE=$P'/msg'

# telling cowsay where to look for cows
export COWPATH=${COW_PATH}

header='$the_cow'" = <<EOC; \n"
footer='EOC'
thought='$thoughts'

nb_thoughts=4

echo $header > "$COW_FILE"
echo "
 $thought
  $thought
   $thought
    $thought" >> "$COW_FILE"

if [ -z $1 ];then
  greet=$(shuf -n1 $MSG_FILE)
  lastlog
  msg="$(figlet -w $(($COLUMNS-9)) "$greet")
  $(uname -snrvm|fold -w $(($COLUMNS-9)) )
  $(echo $lastlog|fold -w $(($COLUMNS-9)))
  "

  
fi

#msg_f=$(figlet -t "$msg")
msg_f="$msg"
msg_h=$(( $(echo "$msg_f"|cowsay -n -f blank|wc -l) + $nb_thoughts +2))

img_list=$(ls -1 $IMG_PTH)
img_cnt=$(echo "${img_list}"|wc -l)
img_arr=($(echo "$img_list" | tr '\n' ' '))
chosen_img=${IMG_PTH}${img_arr[$(($RANDOM%$img_cnt))]}

ascii_h=$(( $LINES-$msg_h ))
ascii=$(jp2a --height=$ascii_h $chosen_img)
echo "$ascii"|sed '/^\s*$/d' >> "$COW_FILE"


echo $footer >> "$COW_FILE"

echo "$msg_f"|cowsay -f greeter -n

#echo $ascii_h $msg_h $LINES
#echo $chosen_img $(echo $ascii|wc -l)

lastlog() {

  lastlog=$(last|grep $(whoami)|head -2|tail -1)
  # remove ip address if not tty
  if [[ -n $(echo $lastlog|grep tty) ]]; then
    port=$(echo $lastlog|awk '{print $2}')
    #tm=$(echo $lastlog|tr -s ' '|cut -d' ' -f1-3)
    tm=$(echo $lastlog|awk -F' ' '{print $3,$5,$6,$7,$8,$9,$10}')
    lastlog="Last successful login was on $port on $tm"
  else
    port=$(echo $lastlog|awk '{print $2}')
    addr=$(echo $lastlog|awk '{print $3}')
    tm=$(echo $lastlog|awk -F' ' '{print $4,$5,$6,$7,$8,$9,$10,$11}')
    lastlog="Last successful login was from $addr on $port on $tm"
  fi

}

failedlogs() {

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
  echo $(( $(lastb -s $lastlog|wc -l) -2))

}
