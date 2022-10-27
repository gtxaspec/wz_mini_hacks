#!/bin/sh
# diagnostics

. /opt/wz_mini/www/cgi-bin/shared.cgi
title="Diagnostics $camver on $camfirmware running wz_mini $hackver as $HOSTNAME"


function handle_css
{
echo -ne "<style type=\"text/css\">"
cat config.css
echo -ne '</style>';
}


dmesg_test()
{
x=$(dmesg | grep "$1")
if [ -n "$x" ]; then
        echo "<div class="error_message"><div class="error_title">$2 error found</div>$x</div>"
else    
        echo "<div>no $2 error</div>"
fi

}

logread_test()
{
x=$(logread | grep "$1")

if [ -n "$x" ]; then
        echo "<div class="error_message"><div class="error_title">$2 error found</div>$x</div>"
else
        echo "<div>no $2 error</div>"
fi

}

echo "HTTP/1.1 200"
echo -e "Content-type: text/html\n\n"
echo ""

echo "<html><head><title>$title</title>"
handle_css
echo "</head>"

echo "<body>"

echo "<h1>$title</h1>"


echo "<h2>SD Card Test</h2>"

dmesg_test "invalid access to FAT" "SD card"
dmesg_test "Filesystem has been set read-only" "SD read only"
dmesg_test "fat_get_cluster: invalid cluster chain" "file system"
logread_test "run: tf_prepare failed!" "SD card (tf_prepare)"
logread_test "(health_test) fail" "SD card health fail"

echo "<h2>Firmware Version Test</h2>"

echo "Firmware Version: $camfirmware <br />" 

if [ "$camfirmware" = "4.36.10.2163" ]; then
	echo "<div>this version is broken. Please downgrade to a working version</div>"
fi
if [ "$camfirmware" = "4.61.0.3"]; then
	echo "<div>wz_mini_hacks does not support the official RTSP firmware.</div>"
fi 


echo "<pre>"
dmesg
echo "</pre>"


version_info "display_BAR"
echo "</body>"

echo "</html>"
