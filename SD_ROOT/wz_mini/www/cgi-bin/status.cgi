#!/bin/sh
# This serves a rudimentary webpage to test different items
. /opt/wz_mini/www/cgi-bin/shared.cgi


base='/opt/record/';
TZ=$(cat /configs/TZ)



echo "HTTP/1.1 200"
echo -e "Content-type: text/html\n\n"
echo ""


test_recording()
{


fpath=$(TZ="$TZ" date +"%Y%m%d")
curmin=$(($(TZ="$TZ" date +"%M") - 1))
curhour=$(TZ="$TZ" date +"%H")
if [ "$curmin" -eq 0 ]; then
	if [ "$curhour" -gt 0 ]; then
        	curhour=$(($curhour - 1))
		curhour=$(printf %02d $curhour)
	else
	  fpath=$(($fpath - 1))
	  curhour=23
	fi
        curmin=59
fi

curmin=$(printf %02d $curmin)

if [ ! -d "$base$fpath" ]; then
	echo -e "NG \n\n"
	echo "Date directory does not exist ($base$fname)" 
	exit
fi




if [ ! -d "$base$fpath/$curhour" ]; then
        echo -e "NG \n\n"
	echo "Hour directory does not exist ($base$fname/$curhour)"
	exit
fi


if [ ! -f "$base$fpath/$curhour/$curmin.mp4" ]; then
        echo -e "NG \n\n"
	echo "Last minute not recorded ($base$fname/$curhour/$curmin.mp4)"
	exit
fi


echo "OK"
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

  if [[ "$GET_test" = "recording" ]];  then
    test_recording
  fi
fi
