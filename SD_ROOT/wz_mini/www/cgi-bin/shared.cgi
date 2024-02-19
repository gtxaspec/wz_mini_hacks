#!/bin/sh
# This provides shared values for webpages


base_dir="/opt/wz_mini"
tmp_dir="$base_dir/tmp"
base_hack_ini="$base_dir/wz_mini.conf"
hack_ini="$base_hack_ini"
www_dir="$base_dir/www/cgi-bin/"
www_env="$tmp_dir/www_env.sh"

function find_TZ_from_latest {
  Fday=$(ls "$recpath" -t | head -n1)
  Fhour=$(ls "$recpath/$Fday" -t | head -n1)
  Fmin=$(ls "$recpath/$Fday/$Fhour" -t | head -n1 | cut -d '.' -f 1)
  Dmin=$(( $(date +%M) - 1 ))

  if [ "$Fmin" -ne "$Dmin" ]; then
    echo "minute is offset ... $Fmin vs $Dmin "
  fi
  if [ "$Fday" -lt $(date +%d) ]; then
    Fshift=$((10#$Fhour - 10#$(date +%H)))
  else
    Fshift=$((10#$(date +%H) - 10#$Fhour))
  fi
  padFshift=$(printf "%03d" "$Fshift")
  echo "UTC$padFshift:00"
}

function decipher_TZ
{
  dTZ=$(find_TZ_from_latest)
#  if [ "$sysTZ" == "$dTZ" ]; then
#     echo "matched across system method and file method"
#  else
#     echo "from system: 'x'$sysTZ'x' and from files: 'x'$dTZ'x'"
#  fi
  echoset "TZ" "$dTZ"
}

function echoset
{  
  eval "$1='$2'"
  echo "$1"="\"$2\"" >>  "$www_env"
}

function compose_www_env
{
	if [ -f "$tmp_dir/.T31" ]; then
  		echoset "camtype" "T31"
  		echoset "base_cam_config" "/configs/.user_config"
                echoset "camfirmware" $(tail -n1 /configs/app.ver | cut -f2 -d=  )
	elif [ -f "$tmp_dir/.T20" ]; then
  		echoset "camtype" "T20"
		echoset "base_cam_config" "/configs/.parameters"
                echoset "camfirmware" $(tail -n1 /system/bin/app.ver | cut -f2 -d= )
	fi
 
        echoset "cammodel" $(/opt/wz_mini/etc/init.d/s04model start | grep detected | cut -f1 -d ' ' )
	echoset camver "$camtype($cammodel)"
	echoset hackver "$(cat /opt/wz_mini/usr/bin/app.ver)"
	echoset gpiopath "/sys/devices/virtual/gpio"
	echoset recpath '/opt/record/';
	echoset sysTZ $(cat /etc/TZ)
	decipher_TZ "$sysTZ"
}

function read_www_env
{
. "$www_env" 
}

if [ ! -f "$www_env" ]; then
  compose_www_env
else
  read_www_env
fi



cam_config="$base_cam_config"


camver="$camtype($cammodel)"

hackver=$(cat /opt/wz_mini/usr/bin/app.ver)

ipaddr=$(ifconfig wlan0  | grep inet | cut -d ':' -f2 | cut -d ' ' -f0)
macaddr=$(ifconfig wlan0  | grep HWaddr | cut -d 'HW' -f2 | cut -d ' ' -f2)


function handle_css
{
echo -ne "<style type=\"text/css\">"
cat $1
echo -ne '</style>';
}


function version_info
{          
 echo "<div id='$1'>"
 echo '<div class="github_link" ><a target="_new" href="https://github.com/gtxaspec/wz_mini_hacks">GitHub: wz_mini_hack</a></div>';
 echo "<div class='ver_DIV' vertype='Model'>$camver</div>"
 echo "<div class='ver_DIV' vertype='Firmware'>$camfirmware</div>"
 echo "<div class='ver_DIV' vertype='wz_mini'>$hackver</div>"
 echo "<div class='ver_DIV' vertype='Hostname'> $HOSTNAME</div>"
 echo "</div>"
}


#function to handle camera feed
function html_cam_feed
{
        printf '<img id="current_feed" src="/cgi-bin/jpeg.cgi?channel=1" class="feed" />'
}
            
#code for rebooting the camera       
reboot_camera()  {  
    die_no_config
    reboot_wait=90
    echo "rebooting camera (refreshing screen in $reboot_wait seconds)"
    echo '<script type="text/javascript">setTimeout(function(){ 
	document.location.href = window.location.href.split('?')[0] + "?" + load=" + new Date().getTime();         
    },'$reboot_wait' * 1000)</script>'
    handle_css config.css
    version_info "display_BAR"
    reboot
    exit
}
            
#creates backup files
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

#displays backup files using $1 to identify the file and $2 to identify if one is currently open
function revert_menu
{
   echo '<h2 id="revert" >Revert Menu</a>'
   echo '<div class="old_configs">'
   echo 'Prior Versions : '
   xuff=0
   while [ "$xuff" -lt 9 ] ;
   do
        xuff=$((xuff + 1))
        if [[ -f "$1.$xuff" ]] ; then
            filedate=$(date -r "$1.$xuff" )
            class=""
            if [ "$1.$xuff" = "$2" ];
            then
               class="current_revert"
            fi
            echo '<div class="revert_DIV '$class'"><div><a href="?action=show_revert&version='"$xuff"'">'"$xuff </a></div><div> $filedate</div></div>"
        fi
    done
    echo '</div>'
}


urldecode(){
 a=${1//+/ }
 b=${a//%/\\x}
 echo -e "$b"
}


stringContain() { [ -z "${2##*$1*}" ] && [ -z "$1" -o -n "$2" ]; }


test_area_access()
{
echo -ne "search: $1\r\n"
values=$(cat "$base_hack_ini" | grep "WEB_SERVER_OPTIONS" | cut -f2 -d=  ) 


if [ -z "$values" ]
then
	values="cam config car jpeg"
fi


if [[ "$values" =~ "$1" ]]
then
        :
else

        echo "HTTP/1.1 200"
        echo -e "Content-type: text/html\n\n"
        echo ""
	echo "<html><head><title>Access Denied</title>"
	handle_css config.css
	echo "</head><body>"
        echo "<h1>access denied to $1</h1>"
        echo "<div>access allowed for : $values</div>"
        echo "you need to enable access using wz_mini.conf WEB_SERVER_OPTIONS "
	version_info display_BAR
	echo "</body></html>"
        exit
fi


}
