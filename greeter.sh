#!/bin/bash


P=$(pwd)
IMG_PTH=$P'/img/'
COW_PATH=$P'/cows/'
COW_FILE="${COW_PATH}"'greeter.cow'
MSG_FILE=$P'/msg'
COLUMNS=$(tput cols)
LINES=$(tput lines)

# telling cowsay where to look for cows
export COWPATH=${COW_PATH}

header='$the_cow'" = <<EOC; \n"
footer='EOC'
thought='$thoughts'

nb_thoughts=4

blanks=('' ' ' '  ' '   ' '    ' '     ' '      ' '       ' '        ' '         ' '          ' '           ')

lastlog=$(last|grep $(whoami)|head -2|tail -1)
# remove ip address if not tty
if [[ -n $(echo $lastlog|grep tty) ]]; then
  port=$(echo $lastlog|awk '{print $2}')
  #tm=$(echo $lastlog|tr -s ' '|cut -d' ' -f1-3)
  tm=$(echo $lastlog|awk -F' ' '{print $3,$5,$6,$7,$8,$9,$10}')
  lastlog="\e[94m\e[5mLast successful login was on $port on $tm\e[25m\e[39m"
else
  port=$(echo $lastlog|awk '{print $2}')
  addr=$(echo $lastlog|awk '{print $3}')
  tm=$(echo $lastlog|awk -F' ' '{print $4,$5,$6,$7,$8,$9,$10,$11}')
  lastlog="\e[94m\e[5mLast successful login was from $addr on $port on $tm\e[25m\e[39m"
fi

echo $header > "$COW_FILE"
echo "
 $thought
  $thought
   $thought
    $thought" >> "$COW_FILE"


failed="There were $(failedlogs) failed login attempts since last login"



if [ -z $1 ];then
  greet=$(shuf -n1 $MSG_FILE)
  greet="$(figlet -w $(($COLUMNS-9)) "$greet")"
  infos="$(uname -snrvm|fold -w $(($COLUMNS-9)) )
  $(echo $lastlog|fold -w $(($COLUMNS-9)))
  $(echo $failed|fold -w $(($COLUMNS-9)))"

  msg="$greet
  $infos
  "

  
fi

#msg_f=$(figlet -t "$msg")
msg_f="$(echo -e "$msg"|cowsay -n -f blank)"
msg_h=$(( $(echo $msg_f|wc -l) + $nb_thoughts +2))
msg_w=$(( $(echo "$msg_f"|head -2|tail -1|wc -c) -1))



img_list=$(ls -1 $IMG_PTH)
img_cnt=$(echo "${img_list}"|wc -l)
img_arr=($(echo "$img_list" | tr '\n' ' '))
chosen_img=${IMG_PTH}${img_arr[$(($RANDOM%$img_cnt))]}

ascii_h=$(( $LINES-$msg_h ))
ascii=$(jp2a --height=$ascii_h $chosen_img)
echo "$ascii"|sed '/^\s*$/d' >> "$COW_FILE"


echo $footer >> "$COW_FILE"

final=$(echo -e "$msg"|cowsay -n -f greeter)



l=1;
ifs="$IFS"
IFS=$'\n'
for a in $(echo "$final"|head -${msg_h})
do
  match=$(echo "$a"|\grep -P '\e\[')
  if [[  -n  $match ]];then
    line_w=$(escapediff "$a")
    missing=$(( $msg_w-$line_w  ))
    final=$(echo -n "$final"|sed -e "${l}s/|$/${blanks[$missing]}|/")
  fi
  l=$(($l+1))
done
IFS=" "

echo -e "$final"

#echo -n "$(echo -n "$msg_f"|cowsay -f greeter -n)"

#echo $nb_failed
#echo $ascii_h $msg_h $LINES
#echo $chosen_img $(echo $ascii|wc -l)


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

  nb_failed=$(( $(sudo lastb -s $lastlog|wc -l) -2))

  if [[ $nb_failed -gt 0 ]];then
    nb_failed="\e[31m$nb_failed\e[0m"
  else
    nb_failed="\e[32m$nb_failed\e[0m"
  fi
  echo "\e[1m$nb_failed"
}

function escapediff {

  echo $(echo -n $1|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"|wc -c)

}


