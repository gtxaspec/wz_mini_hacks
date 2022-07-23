#!/bin/sh
# This serves a rudimentary webpage based on wz_mini.conf
base_dir=/opt/wz_mini/
hack_ini=/opt/wz_mini/wz_mini.conf
www_dir=/opt/wz_mini/www/cgi-bin/
camver=V3
camfirmware=$(tail -n1 /configs/app.ver | cut -f2 -d=  )
hackver=$(cat /opt/wz_mini/usr/bin/app.ver)
title="Wyze $camver on $camfirmware running wz_mini $hackver as $HOSTNAME"
updated=false

echo "HTTP/1.1 200"
echo -e "Content-type: text/html\n\n"
echo ""


reboot_camera()  {
    echo "rebooting camera (refreshing screen in 90 seconds)"
    echo '<script type="text/javascript">setTimeout(function(){ document.location.reload (); },90 * 1000)</script>'
    exit
}

shft() {
    # SE loop did not work -- thanks ash!
   suff=8 
   while [ "$suff" -gt 0 ] ;
    do
        if [[ -f "$1.$suff" ]] ; then
            nxt=$((suff + 1))
            mv -f "$1.$suff" "$1.$nxt"
        fi
   suff=$((suff-1))
   done 
   mv -f "$1" "$1.1"
}


function revert_config
{
  mv "$hack_ini" "$hack_ini.old"
  mv "$hack_ini.$1" "$hack_ini"

}


function revert_menu
{
   echo '<a href="revert" >Revert Menu</a>'
   echo '<div class="old_configs">'
   echo 'Prior Versions : ' 
  xuff=0
   while [ "$xuff" -lt 9 ] ; 
   do 
	xuff=$((xuff + 1))  
        if [[ -f "$1.$xuff" ]] ; then
	    echo '&nbsp;<a href="?action=revert&version='"$xuff"'">'"$xuff</a>"
        fi
    done
    echo '</div>'
}



if [[ $REQUEST_METHOD = 'GET' ]]; then

  #since ash does not handle arrays we create variables using eval
  IFS='&'
  for PAIR in $QUERY_STRING
  do
      K=$(echo $PAIR | cut -f1 -d=)
      VA=$(echo $PAIR | cut -f2 -d=)
      eval GET_$K=$VA
  done

  if [[ "$GET_action" = "reboot" ]];  then
    reboot_camera
  fi
  if [[ "$GET_action" = "revert"  ]]; then
    revert_config "$GET_version"
  fi

fi


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
  updated=true

fi




function documentation_to_html
{
        if [[ -f "$www_dir$1.md" ]];  then
                printf '<div class="ii_explain"><pre>'
                cat "$web_dir$1.md"
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
	printf '<img id="current_feed" src="/cgi-bin/jpeg.cgi?channel=1" class="feed" />'
}




echo -ne "<html><head><title>$title</title>"
echo -ne "<style type=\"text/css\">"
cat wz_mini_web.css
echo -ne '</style>';
echo '<script type="text/javascript" src="/config.js" ></script>'
echo -ne "</head>"




echo -ne '<body>'
echo -ne "<h1>$title</h1>";


if [ "$updated" = true ];
then
   echo '<div class="message_DIV">configuration file updated. <a href="?action=reboot">Reboot<a/> to use changes. Or <a href="#revert">Revert</a> to a prior configuration</div>';

fi

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


revert_menu $hack_ini



html_cam_feed_js


echo -ne '</body></html>'
