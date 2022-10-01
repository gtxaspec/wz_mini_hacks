#!/bin/sh
# This provides shared values for webpages
base_dir=/opt/wz_mini/
base_hack_ini=/opt/wz_mini/wz_mini.conf
hack_ini=$base_hack_ini
www_dir=/opt/wz_mini/www/cgi-bin/

if [ -f /opt/wz_mini/tmp/.T31 ]; then
  camtype=T31
  camfirmware=$(tail -n1 /configs/app.ver | cut -f2 -d=  )
  cam_config="/configs/.user_config"
elif [ -f /opt/wz_mini/tmp/.T20 ]; then
  camtype=T20
  camfirmware=$(tail -n1 /system/bin/app.ver | cut -f2 -d= )
  cam_config="/configs//parameters"
fi

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
 echo '<div class="github_link" ><a style="color:white" href="https://github.com/gtxaspec/wz_mini_hacks">Project</a></div>';
 echo "</div>"
}


