#!/bin/bash

source colors.sh
source conf.sh

# telling cowsay where to look for cows
export COWPATH=${COW_PATH}

header='$the_cow'" = <<EOC; \n"
footer='EOC'
thought='$thoughts'

nb_thoughts=4

blanks=('' ' ' '  ' '   ' '    ' '     ' '      ' '       ' '        ' '         ' '          ' '           ' '            ' '             ' '              ' '               ' '                ' '                 ' '                  ' '                   ' '                    ' '                     ' '                      ' '                       ' '                        ' '                         ' '                          ' '                           ' '                            ' '                             ' '                              ' '                               ' '                                ' '                                 ' '                                  ' '                                   ' '                                    ' '                                     ' '                                      ' '                                       ' '                                        ')

function makeblanks {

IFS=' '
  for a in $(seq -s' ' 0 40);do
    echo -n "'"
    for b in $(seq -s' ' 1 $a);do
      echo -n ' '
    done
    echo -n "'"
    echo -n ' '
  done
}


function escapediff {
  echo $(echo -e "$1" | tr -d '\n'|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"|wc -c)

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



echo $header > "$COW_FILE"
#echo "
# $thought
#  $thought
#   $thought
#    $thought" >> "$COW_FILE"


if [ -z $2 ];then
  greet=$(shuf -n1 $MSG_FILE)
else
  greet="$2"
fi
greet="\n$(figlet -d $FONT_DIR -f $gfont -w $(($COLUMNS-9)) "$greet"|sed '/^\s*$/d' | sed "s=^=${esc}$gcolor=g"|sed 's=$=\\e[0m=g')\n"

#$(uname -snrvm|fold -w $(($COLUMNS-9)) )

infos="$(./sysinfo.sh)"

msg="$greet
$infos
"

  

msg_f="$(echo -e "$msg"|cowsay -n -f blank)"
#msg_h=$(( $(echo "$msg_f"|wc -l) + $nb_thoughts +2))
msg_h=$(( $(echo "$msg_f"|wc -l) +2))
msg_w=$(( $(echo "$msg_f"|head -1|wc -c)))



# Choose a pic
img_list=$(ls -1 $IMG_PTH)
img_cnt=$(echo "${img_list}"|wc -l)
img_arr=($(echo "$img_list" | tr '\n' ' '))
if [[ -n $1 ]];then
  chosen_img=$1
else
  chosen_img=${IMG_PTH}${img_arr[$(($RANDOM%$img_cnt))]}
fi

# display it correctly 
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

# Bubble escape chars fix
l=1;
ifs="$IFS"
IFS=$'\n'
for a in $(echo "$final"|head -${msg_h})
do
  match=$(echo "$a"|\grep -P '\e\[')
  if [[  -n  $match ]];then
    line_w=$(escapediff "$a")
    #echo "$a"
    #echo -n "$a"|wc -c
    #echo -n "$a"|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"|wc -c
    #echo -n "$a"|sed -r 's/'$(echo -e "\033")'\[[0-9]{1,2}(;([0-9]{1,2})?)?[mK]//g'
    #echo -n "$a"|sed "s/\x1B\[/e[/g"
    #echo $line_w $msg_w
    #echo
    missing=$(( $msg_w-$line_w  ))
    #echo $missing
    #echo -n "$a"|sed -e "s/\([|/\\]\)$/${blanks[$missing]}\1/"
    final=$(echo -n "$final"|sed -e "${l}s/\([|/\\]\)$/${blanks[$missing]}\1/")
    #echo a${blanks[$missing]}a
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


