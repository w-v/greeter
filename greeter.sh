#!/bin/bash
Res="[0m"

Default="[39m"
Black="[30m"
Red="[31m"
Green="[32m"
Yellow="[33m"
Blue="[34m"
Magenta="[35m"
Cyan="[36m"
Lgray="[37m"
Dgray="[90m"
Lred="[91m"
Lgreen="[92m"
Lyellow="[93m"
Lblue="[94m"
Lmagenta="[95m"
Lcyan="[96m"
White="[97m"
BDefault="[49m"
BBlack="[40m"
BRed="[41m"
BGreen="[42m"
BYellow="[43m"
BBlue="[44m"
BMagenta="[45m"
BCyan="[46m"
BLgray="[47m"
BDgray="[100m"
BLred="[101m"
BLgreen="[102m"
BLyellow="[103m"
BLblue="[104m"
BLmagenta="[105m"
BLcyan="[106m"
BWhite="[107m"
Bold="[1m"
Dim="[2m"
Underlined="[4m"
Blink="[5m"
Inverted="[7m"
Hidden="[8m"

colors="[31m
[32m
[33m
[34m
[35m
[36m
[37m
[90m
[91m
[92m
[93m
[94m
[95m
[96m
[97m"

esc=$(printf '\033')

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
    nb_failed="${esc}$Red$nb_failed"
  else
    nb_failed="${esc}$Green$nb_failed"
  fi
  echo "${esc}$Bold$nb_failed${esc}$Res"
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

function addthoughts {

  for i in $(seq $1 -1 1);do
    char=$(echo "$ascii"|head -$i|tail -1| cut -c $i)
    if [[ "$char" = " " ]];then
      ascii=$(echo "$ascii"|sed -e "${i}s/ /\$thoughts/${i}")
    fi
  done

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
#echo "
# $thought
#  $thought
#   $thought
#    $thought" >> "$COW_FILE"

b=$(failedlogs)
failed="There were $b failed login attempts since last login"

greet=$(shuf -n1 $MSG_FILE)
greet="\n$(figlet -d $FONT_DIR -f $gfont -w $(($COLUMNS-9)) "$greet"|sed '/^\s*$/d' | sed "s=^=${esc}$gcolor=g"|sed 's=$=\\e[0m=g')\n"

infos="\
  #$(uname -snrvm|fold -w $(($COLUMNS-9)) )
$(echo $lastlog|fold -w $(($COLUMNS-9)))
$(echo $failed|fold -w $(($COLUMNS-9)))
$(hdd|fold -w $(($COLUMNS-9)))
"

msg="$greet
$infos
"

  

msg_f="$(echo -e "$msg"|cowsay -n -f blank)"
#msg_h=$(( $(echo "$msg_f"|wc -l) + $nb_thoughts +2))
msg_h=$(( $(echo "$msg_f"|wc -l) +2))
msg_w=$(( $(echo "$msg_f"|head -1|wc -c)))



img_list=$(ls -1 $IMG_PTH)
img_cnt=$(echo "${img_list}"|wc -l)
img_arr=($(echo "$img_list" | tr '\n' ' '))
if [[ -n $1 ]];then
  chosen_img=$1
else
  chosen_img=${IMG_PTH}${img_arr[$(($RANDOM%$img_cnt))]}
fi

ascii_h=$(( $LINES-$msg_h ))
ascii=$(jp2a --height=$ascii_h $chosen_img)
ascii_w=$(echo "$ascii"|head -1|wc -c)
if [ $ascii_w -gt $COLUMNS ];then
  ascii=$(jp2a --width=$COLUMNS $chosen_img)
  ascii_lh=$(echo "$ascii"|wc -l)
  if [ $ascii_lh -lt $ascii_h ];then
    #echo "$ascii_lh $ascii_h"
    n=$(( ($ascii_h-$ascii_lh)/2+1 ))
    lines="$(for i in $(seq $n); do echo  '\n';done)"
    #echo "$lines"|wc -l
    #echo "$ascii"|wc -l
    #echo "$ascii"|wc -l
  fi
  ascii_w=$(echo "$ascii"|head -1|wc -c)
fi

ascii="$(for a in $(seq $ascii_w); do echo -n ' ';done)\n${ascii}"
ascii=$(echo -e "${ascii}")
addthoughts $nb_thoughts
echo "$ascii" >> "$COW_FILE"


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

over="$Green"
echo -e "$final$lines"
#|sed "s=\([|/\\]$\)=${esc}${Bold}${esc}$gcolor\1"${esc}$Res"=g"|sed "s=^\([|/\\]\)=${esc}$Bold${esc}${gcolor}\1${esc}$Res=g"|sed "s=\(^ -*$\)=${esc}$Bold${esc}${gcolor}\1${esc}$Res=g"|sed "s=\(^ _*$\)=${esc}$Bold${esc}${gcolor}\1${esc}$Res=g"

#echo -n "$(echo -n "$msg_f"|cowsay -f greeter -n)"

#echo $nb_failed
#echo $ascii_h $msg_h $LINES
#echo $chosen_img $(echo $ascii|wc -l)


