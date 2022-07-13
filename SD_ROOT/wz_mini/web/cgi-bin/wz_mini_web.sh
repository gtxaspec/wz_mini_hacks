#!/bin/sh
# This serves a rudimentary webpage based on wz_mini.conf
hack_ini=/opt/wz_mini/wz_mini.conf
camver=V3
camfirmware=$(tail -n1 /configs/app.ver | cut -f2 -d=  )
hackver="unknown"
hostname=$(uname -n)
title="Wyze $camver on $camfirmware running wz_mini $hackver as $hostname"


echo "HTTP/1.1 200"
echo ""
#echo "Content Length: 100000"

function ini_to_html_free
{
        printf '<div class="ii"><div class="ii_key_DIV">%s</div><div class="ii_value_DIV"><input class="ii_value" type="text" name="%s" value="%s" /></div></div>' $1 $1  $2
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
        printf '</div></div>'
}


echo -ne "<html><head><title>$title</title>"
echo -ne "<style type=\"text/css\">"
cat wz_mini_web.css
echo -ne '</style>';
echo -ne "</head>"
echo -ne '<body>'
echo -ne "<h1>$title</h1>";
echo -ne '<form name=\"wz_mini_hack_FORM\">'

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
