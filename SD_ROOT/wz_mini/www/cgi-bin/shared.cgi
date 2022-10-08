#!/bin/sh
# This provides shared values for webpages
base_dir=/opt/wz_mini/
base_hack_ini=/opt/wz_mini/wz_mini.conf
hack_ini=$base_hack_ini
www_dir=/opt/wz_mini/www/cgi-bin/

if [ -f /opt/wz_mini/tmp/.T31 ]; then
  camtype=T31
  camfirmware=$(tail -n1 /configs/app.ver | cut -f2 -d=  )
  base_cam_config="/configs/.user_config"
elif [ -f /opt/wz_mini/tmp/.T20 ]; then
  camtype=T20
  camfirmware=$(tail -n1 /system/bin/app.ver | cut -f2 -d= )
  base_cam_config="/configs/.parameters"
fi
cam_config=$base_cam_config

cammodel=$(/opt/wz_mini/etc/init.d/s04model start | grep detected | cut -f1 -d ' ' )

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
 echo "<div class='ver_DIV' vertype='Model'>$camver</div>"
 echo "<div class='ver_DIV' vertype='Firmware'>$camfirmware</div>"
 echo "<div class='ver_DIV' vertype='wz_mini'>$hackver</div>"
 echo "<div class='ver_DIV' vertype='Hostname'> $HOSTNAME</div>"
 echo '<div class="github_link" ><a target="_new" href="https://github.com/gtxaspec/wz_mini_hacks">Project</a></div>';
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

