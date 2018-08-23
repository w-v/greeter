#!/bin/bash
Res="\e[0m"

Default="\e[39m"
Black="\e[30m"
Red="\e[31m"
Green="\e[32m"
Yellow="\e[33m"
Blue="\e[34m"
Magenta="\e[35m"
Cyan="\e[36m"
Lgray="\e[37m"
Dgray="\e[90m"
Lred="\e[91m"
Lgreen="\e[92m"
Lyellow="\e[93m"
Lblue="\e[94m"
Lmagenta="\e[95m"
Lcyan="\e[96m"
White="\e[97m"
BDefault="\e[49m"
BBlack="\e[40m"
BRed="\e[41m"
BGreen="\e[42m"
BYellow="\e[43m"
BBlue="\e[44m"
BMagenta="\e[45m"
BCyan="\e[46m"
BLgray="\e[47m"
BDgray="\e[100m"
BLred="\e[101m"
BLgreen="\e[102m"
BLyellow="\e[103m"
BLblue="\e[104m"
BLmagenta="\e[105m"
BLcyan="\e[106m"
BWhite="\e[107m"
Bold="\e[1m"
Dim="\e[2m"
Underlined="\e[4m"
Blink="\e[5m"
Inverted="\e[7m"
Hidden="\e[8m"

colors="\e[31m
\e[32m
\e[33m
\e[34m
\e[35m
\e[36m
\e[37m
\e[90m
\e[91m
\e[92m
\e[93m
\e[94m
\e[95m
\e[96m
\e[97m"

P=$(pwd)
IMG_PTH=$P'/img/'
COW_PATH=$P'/cows/'
COW_FILE="${COW_PATH}"'greeter.cow'
MSG_FILE=$P'/msg'
FONT_DIR=$P'/fonts/large'
COLUMNS=$(tput cols)
LINES=$(tput lines)

# telling cowsay where to look for cows
export COWPATH=${COW_PATH}

header='$the_cow'" = <<EOC; \n"
footer='EOC'
thought='$thoughts'

nb_thoughts=4

blanks=('' ' ' '  ' '   ' '    ' '     ' '      ' '       ' '        ' '         ' '          ' '           ' '            ' '             ' '             ' '              ')


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
    nb_failed="$Red$nb_failed"
  else
    nb_failed="$Green$nb_failed"
  fi
  echo "$Bold$nb_failed$Res"
}

function escapediff {

  echo $(echo -n $1|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"|wc -c)

}

function hdd {
  echo $(sudo /usr/sbin/hddtemp /dev/sd?|tr -d :)
}

function cpu {
  echo a
}

function hw {
  echo '\n'
  paste <(cpu) <(hdd) --delimiters ''
}
gcolor=$(echo -e "$colors"|shuf -n1)
gfont=$( ls $FONT_DIR| shuf -n1)


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

echo $header > "$COW_FILE"
echo "
 $thought
  $thought
   $thought
    $thought" >> "$COW_FILE"

b=$(failedlogs)
failed="There were $b failed login attempts since last login"

if [ -z $1 ];then
  greet=$(shuf -n1 $MSG_FILE)
  greet="$(figlet -d $FONT_DIR -f $gfont -w $(($COLUMNS-9)) "$greet" | sed "s=^=$gcolor=g"|sed 's=$=\\e[0m=g')"

  infos="\
  #$(uname -snrvm|fold -w $(($COLUMNS-9)) )
  $(echo $lastlog|fold -w $(($COLUMNS-9)))
  $(echo $failed|fold -w $(($COLUMNS-9)))
  $(hdd|fold -w $(($COLUMNS-9)))
  "

  msg="$greet
  $infos
  "

  
fi

msg_f="$(echo -e "$msg"|cowsay -n -f blank)"
msg_h=$(( $(echo "$msg_f"|wc -l) + $nb_thoughts +2))
msg_w=$(( $(echo "$msg_f"|head -1|wc -c)))



img_list=$(ls -1 $IMG_PTH)
img_cnt=$(echo "${img_list}"|wc -l)
img_arr=($(echo "$img_list" | tr '\n' ' '))
chosen_img=${IMG_PTH}${img_arr[$(($RANDOM%$img_cnt))]}

ascii_h=$(( $LINES-$msg_h ))
ascii=$(jp2a --height=$ascii_h $chosen_img)
echo "$ascii"|sed '/^\s*$/d' >> "$COW_FILE"


echo $footer >> "$COW_FILE"

final=$(echo -e "$msg"|cowsay -n -f greeter)


#echo -n "$final"|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"

l=1;
ifs="$IFS"
IFS=$'\n'
for a in $(echo "$final"|head -${msg_h})
do
  match=$(echo "$a"|\grep -P '\e\[')
  if [[  -n  $match ]];then
    #echo "$a"
    line_w=$(escapediff "$a")
    #echo $line_w $msg_w
    missing=$(( $msg_w-$line_w  ))
    final=$(echo -n "$final"|sed -e "${l}s/\([|/\\]\)$/${blanks[$missing]}\1/")
  fi
  l=$(($l+1))
done
IFS=" "

echo -e "$final"

#echo -n "$(echo -n "$msg_f"|cowsay -f greeter -n)"

#echo $nb_failed
#echo $ascii_h $msg_h $LINES
#echo $chosen_img $(echo $ascii|wc -l)


