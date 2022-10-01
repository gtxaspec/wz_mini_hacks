#!/bin/sh
# This serves a rudimentary webpage based on wz_mini.conf
. /opt/wz_mini/www/cgi-bin/shared.cgi

title="$camver on $camfirmware running wz_mini $hackver as $HOSTNAME"
updated=false




echo "HTTP/1.1 200"
echo -e "Content-type: text/html\n\n"
echo ""


die_no_config() 
{
if [ -f ${cam_config} ]
then
    if [ -s ${cam_config} ]
    then
        echo "$cam_config exists and not empty"
    else
 echo "$cam_config exists but empty"
 echo "if you reboot then the camera will revert to defaults or possibly fail "
 exit
    fi
else
 echo "$cam_config file does  not exist"
 echo "Maybe they moved the file? or your camera type stores it somewhere else ?"
 exit 
fi

}


reboot_camera()  {
    die_no_config
    reboot_wait=90
    echo "rebooting camera (refreshing screen in $reboot_wait seconds)"
    echo '<script type="text/javascript">setTimeout(function(){ document.location.href = "/cgi-bin/cam.cgi"; },'$reboot_wait' * 1000)</script>'
    handle_css config.css
    version_info "display_BAR"
    reboot 
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
  output="$cam_config.new"

  #name our output file
  while IFS= read -r \ARGUMENT; do
    #cycle through each line of the current config
    #copy through all comments
    if [ -z "$ARGUMENT" ]; then
       echo -ne "\n" >> $output
    elif [[ ${ARGUMENT:0:1} == "#" ]] ; then
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
  done < $cam_config

  shft $cam_config
  mv $output $cam_config
  updated=true

fi




function documentation_to_html
{
	fname="$www_dir"'cam-'"$1.md" 
        if [[ -f "$fname" ]];  then
                printf '<div class="ii_explain"><pre>'
                cat "$fname"
                printf '</pre></div>'
        fi
}
  
  
function ini_to_html_free
{
        classes=""
        if [ "$1" =  "USB_DIRECT_MAC_ADDR" ]; then
           classes=" mac_addr"
        fi 
	if grep -q -wi "$1" cam-numerics.txt; then
	   classes=" numeric"
	fi
        printf '<div class="ii"><div class="ii_key_DIV">%s</div><div class="ii_value_DIV"><input class="ii_value'$classes'" type="text" name="%s" value="%s" /></div>' $1 $1  $2
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
handle_css config.css

echo '<script type="text/javascript" src="/config.js" ></script>'
echo -ne "</head>"


echo -ne '<body ip="'$ipaddr'" mac="'$macaddr'"  >'
echo -ne "<h1>$title</h1>";


if [ "$updated" = true ];
then
   echo '<div class="message_DIV">configuration file updated. <a href="?action=reboot">Reboot<a/> to use changes. Or <a href="#revert">Revert</a> to a prior configuration</div>';

fi

html_cam_feed


echo -ne '<form name="update_config" method="POST" enctype="application/x-www-form-urlencoded"  >'


CONFIG_BLOCK=0

while IFS= read -r ARGUMENT; do
    if [ -z "$ARGUMENT" ] ; then
	echo -ne "" 
    elif [[ ${ARGUMENT:0:1} == "[" ]] ; then
           if [ "$CONFIG_BLOCK" -gt 0 ]; then
	      echo '</div>'
           fi
           CONFIG_BLOCK=$((CONFIG_BLOCK + 1))
	   BTITLE=${ARGUMENT//#/ }
           BN=$ARGUMENT
           echo '<div class="ii_block" block_number="'$CONFIG_BLOCK'" block_name="'$BN'" >'
           echo -ne '<div class="ii_block_name" >'$BTITLE'</div>'
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
done < $cam_config
           if [ "$CONFIG_BLOCK" -gt 0 ]; then
              echo '</div>'
           fi



echo -ne '<input type="submit" name="update" id="update" value="Update" disabled="disabled" />'
echo -ne '</form>'
echo -ne '<button onclick="enable_submit();" >Enable Submit</button>';


version_info "display_BAR"

echo -ne '</body></html>'
