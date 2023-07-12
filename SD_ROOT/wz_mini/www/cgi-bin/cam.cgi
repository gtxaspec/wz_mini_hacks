#!/opt/wz_mini/bin/bash
# This serves a rudimentary webpage based on wz_mini.conf
. /opt/wz_mini/www/cgi-bin/shared.cgi
test_area_access cam  

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
 echo "if you reboot then the camera will revert to defaults "
 exit
    fi
else
 echo "$cam_config file does  not exist"
 echo "Maybe they moved the file? or your camera type stores it somewhere else ?"
 exit 
fi

}


function revert_config
{   
  mv "$cam_config" "$cam_config.old"
  mv "$cam_config.$1" "$cam_config"
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
  if [[ "$GET_action" = "show_revert" ]]; then
    cam_config="$cam_config.$GET_version"
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

  output="$cam_config.new"
  cp $cam_config $output

  #since ash does not handle arrays we create variables using eval
  IFS='&'
  for PAIR in $POST_DATA
  do
      FK=$(echo $PAIR | cut -f1 -d= )
      VA=$(echo $PAIR | cut -f2 -d= )

      FK=$(urldecode "$FK")
      VA=$(urldecode "$VA")

      if [ "${FK:0:3}" == "row" ]; then
	K=$(echo "$FK" | cut -f2 -d[ | cut -f1 -d])
#       echo "<div>match: $K=$VA</div>"
	sed -i s/$K.*/$K=$VA/ $output
      fi
  done

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

function select_block
{
	fname="$www_dir"'cam-values.txt'
	testval=$(grep "$1" "$fname" | cut -f2 -d# | cut -f2 -d"(" | cut -f1 -d")" | tr " " "Q")

	if [[ -n "$testval" ]]; then
           echo '<select class="ii_select" name="'SELECT_$2'" row="'$2'"><option value="">...</option>'
	   IFS=" "
           for OPTI in ${testval//,/ }
	   do
		pv=$(echo $OPTI | tr "Q" " " | xargs )
	   	val=$(echo $pv | cut -f1 -d= | tr "Q" " " | xargs )
	   	echo '<option value="'$val'">'$pv'</option>'
	   done   
	
	   echo '</select>'
	fi
}
 
  
function ini_to_html_free
{
        classes=""
        printf '<div class="ii"><div class="ii_key_DIV">%s</div><div class="ii_value_DIV">' $1
	select_block $1 $3	
	printf '<input disabled=TRUE class="ii_value'$classes'" type="text" name="%s" value="%s" default_value="%s"  row="%s"  /></div>' "row_$3[$1]" $2 $2 $3
        documentation_to_html $1
        printf '</div>'
}
       




echo -ne "<html><head><title>$title</title>"
handle_css config.css

echo '<script type="text/javascript" src="/cam.js" ></script>'
echo '<script type="text/javascript" src="/feed.js" ></script>'
echo -ne "</head>"


echo -ne '<body ip="'$ipaddr'" mac="'$macaddr'"  >'
echo -ne "<h1>$title</h1>";

echo -ne "<div>cam.cgi only lists values in your current configuration file. <div style='font-weight:bold;color:red' >To Prevent Bricking This Form is Disabled!</div> </div>"

if [ "$updated" = true ];
then
   echo '<div class="message_DIV">configuration file updated. <a href="?action=reboot">Reboot<a/> to use changes. Or <a href="#revert">Revert</a> to a prior configuration</div>';

fi

html_cam_feed


if [ $base_cam_config != $cam_config ]; then
    
  echo '<div><a href="?action=revert&version='$GET_version'">Revert</a> to this version</a></div>'
fi

        

echo -ne '<form action="#" onsubmit="return false;" name="update_config" method="POST" enctype="application/x-www-form-urlencoded"  >'


CONFIG_BLOCK=0
row=0
while IFS= read -r ARGUMENT; do
    row=$((row+1))
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
      ini_to_html_free $KEY $VAL $row
    fi
done < $cam_config
           if [ "$CONFIG_BLOCK" -gt 0 ]; then
              echo '</div>'
           fi



#echo -ne '<input type="submit" name="update" id="update" value="Update" disabled="disabled" />'
echo -ne '</form>'
#echo -ne '<button onclick="enable_submit();" >Enable Submit</button>';

revert_menu $base_hack_ini $cam_config


version_info "display_BAR"

echo -ne '</body></html>'
