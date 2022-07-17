#we!/bin/sh
# This serves a rudimentary webpage based on wz_mini.conf
base_dir=/opt/wz_mini/
hack_ini=/opt/wz_mini/wz_mini.conf
www_dir=/opt/wz_mini/www/cgi-bin/
camver=V3
camfirmware=$(tail -n1 /configs/app.ver | cut -f2 -d=  )
hackver=$(cat /opt/wz_mini/usr/bin/app.ver)
hostname=$(uname -n)
title="Wyze $camver on $camfirmware running wz_mini $hackver as $hostname"

echo "HTTP/1.1 200"
echo -e "Content-type: text/html\n\n"
echo ""


shft() {
    cd $base_dir
    # https://stackoverflow.com/questions/3690936/change-file-name-suffixes-using-sed/3691279#3691279
    # Change this '8' to one less than your desired maximum rollover file.
    # Must be in reverse order for renames to work (n..1, not 1..n).
    for suff in {8..1} ; do
        if [[ -f "$1.${suff}" ]] ; then
            ((nxt = suff + 1))
            mv -f "$1.${suff}" "$1.${nxt}"
        fi
    done
    mv -f "$1" "$1.1"
}

#test for post
if [[ $REQUEST_METHOD = 'POST' ]]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
        read -n $CONTENT_LENGTH POST_DATA <&0
        while read line
            do eval "echo ${line}"
        done
    fi

  #since ash does not handle arrays we create variables using eval
  IFS='&'
  for PAIR in $POST_DATA
  do
      K=$(echo $PAIR | cut -f1 -d=)
      VA=$(echo $PAIR | cut -f2 -d=)
      VB=\"${VA//%3A/:}\"
      #echo "<div>$K=$VB</div>"
      eval POST_$K=\"$VB\"
  done


  #switch back to going through the config file
  IFS=$'\n'
  output="$hack_ini.new"

  #name our output file
  for ARGUMENT in $(cat $hack_ini) 
  do
    #cycle through each line of the current config

    #copy through all comments
    if [[ ${ARGUMENT:0:1} == "#" ]] ; then
       #echo $ARGUMENT $'\n' 
       echo -ne  $ARGUMENT"\n"  >> $output
    else
    #for non-comments check to see if we have an entry in the POST data by deciphering the key from the ini file and using eval for our fake array
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
	test=$(eval echo \$POST_$KEY)
	#echo "key was $KEY test was ...   $test <br /> "
     if [[ "$test" ]]; then
        #if in the fake array then we use the new value
	#echo "<div style=\"color:#c00\">matched </div>"
	echo -ne $KEY=\"$test\""\n"  >> $output
      else
        #if not in the fake array we use the current value
	#echo "<div>key not found</div>"
	echo -ne $ARGUMENT"\n" >> $output
      fi

    fi
  done

  shft $hack_ini
  mv $output $hack_ini
  echo "rebooting! wait a bit -- and go the same url"
  reboot
  exit
fi



function documentation_to_html
{
        if [[ -f "$www_dir$1.md" ]];  then
                printf '<div class="ii_explain"><pre>'
                cat $web_dir$1.md
                printf '</pre></div>'
        fi
}
  
  
function ini_to_html_free
{
        printf '<div class="ii"><div class="ii_key_DIV">%s</div><div class="ii_value_DIV"><input class="ii_value" type="text" name="%s" value="%s" /></div>' $1 $1  $2
        documentation_to_html $1
        printf '</div>'
}
       
function ini_to_html_tf
{
        printf '<div class="ii"><div class="ii_key_DIV">%s</div>' $1
        printf '<div class="ii_value_DIV">'
        if [[ "$2" == "true" ]]; then
        printf '<input class="ii_radio" type="radio" name="%s" value="true" checked="checked" /> True &nbsp;' $1
        printf '<input class="ii_radio" type="radio" name="%s" value="false" /> False &nbsp;' $1
        else
        printf '<input class="ii_radio" type="radio" name="%s" value="true" /> True &nbsp;' $1
        printf '<input class="ii_radio" type="radio" name="%s" value="false" checked="checked" /> False &nbsp;' $1
        
        fi
        printf '</div>'
        documentation_to_html $1
        printf '</div>'
}

#function to handle camera feed
function html_cam_feed
{
	printf '<img src="/cgi-bin/jpeg.cgi" class="feed" >'
}

echo -ne "<html><head><title>$title</title>"
echo -ne "<style type=\"text/css\">"
cat wz_mini_web.css
echo -ne '</style>';
echo -ne "</head>"


echo -ne '<body>'
echo -ne "<h1>$title</h1>";

html_cam_feed

echo -ne '<form name="wz_mini_hack_FORM" method="POST" enctype="application/x-www-form-urlencoded"  >'

IFS=$'\n'
for ARGUMENT in $(cat $hack_ini)
do
    if [[ ${ARGUMENT:0:1} == "#" ]] ; then
 	echo -ne '<div class="ii_info">'$ARGUMENT'</div>'
    else
      KEY=$(echo $ARGUMENT | cut -f1 -d=)
      VAL=$(echo $ARGUMENT | cut -f2 -d=)   
      VALUE=${VAL//\"/}
      case "$VALUE" in
	"true") ini_to_html_tf $KEY $VALUE ;;
	"false") ini_to_html_tf $KEY $VALUE ;;
	*) ini_to_html_free $KEY $VALUE
      esac
    fi
done

echo -ne '<input type="submit" name="update" value="Update" />'
echo -ne '</form>'


echo -ne '</body></html>'
