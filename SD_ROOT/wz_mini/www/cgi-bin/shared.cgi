#!/bin/sh
# This provides shared values for webpages
base_dir=/opt/wz_mini/
base_hack_ini=/opt/wz_mini/wz_mini.conf
hack_ini=$base_hack_ini
www_dir=/opt/wz_mini/www/cgi-bin/
camver=V3

if [ -f /opt/wz_mini/tmp/.T31 ]; then
camtype=T31
elif [ -f /opt/wz_mini/tmp/.T20 ]; then
camtype=T20
fi

cammodel=$(/opt/wz_mini/etc/init.d/s04model start | grep detected | cut -f1 -d ' ' )

camver="$camtype($cammodel)"

camfirmware=$(tail -n1 /configs/app.ver | cut -f2 -d=  )
hackver=$(cat /opt/wz_mini/usr/bin/app.ver)


function version_info
{          
 echo "<div id='$1'>"
 echo "<div class='ver_DIV' vertype='Model'>$camver</div>"
 echo "<div class='ver_DIV' vertype='Firmware'>$camfirmware</div>"
 echo "<div class='ver_DIV' vertype='wz_mini'>$hackver</div>"
 echo "<div class='ver_DIV' vertype='Hostname'> $HOSTNAME</div>"
 echo "</div>"
}


