#!/bin/sh
. /opt/wz_mini/www/cgi-bin/shared.cgi
test_area_access jpeg

#test for jpeg
if [[ $REQUEST_METHOD = 'GET' ]]; then

  #since ash does not handle arrays we create variables using eval
  IFS='&'
  for PAIR in $QUERY_STRING
  do
      K=$(echo $PAIR | cut -f1 -d=)
      VA=$(echo $PAIR | cut -f2 -d=)
      #VB=${VA//%3A/:}
      #echo "<div>$K=$VA</div>"
      eval GET_$K=$VA
  done
fi

if [ -z "$GET_channel" ];
then
  echo -ne "X-Channel-Override: 0\r\n"
  GET_channel=0
fi

echo -ne "X-Channel: $GET_channel\r\n"
echo -ne "Content-Type: image/jpeg\r\n\r\n"

cmd jpeg "$GET_channel" -n
