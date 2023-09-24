#!/bin/sh
# This serves a rudimentary webpage to test different items
. /opt/wz_mini/www/cgi-bin/shared.cgi


base='/opt/record/';
TZ=$(cat /configs/TZ)





test_recording()
{

msg=""
fpath=$(TZ="$TZ" date +"%Y%m%d")
nowmin=$(TZ="$TZ" date +"%M")
curmin=$((10#$nowmin - 1))
curhour=$(TZ="$TZ" date +"%H")
cursec=$(TZ="$TZ" date +"%S")


if [[ "$cursec" -lt  "03" ]]; then
	wt=$((3 - $cursec))
	msg="delayed $wt seconds to allow copy to SD"
        sleep $wt
fi

if [[ "$curmin" -eq "0" ]]; then
	if [[ "$curhour" -gt "0" ]]; then
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
	echo -e "NG $lb"
	echo "Date directory does not exist ($base$fname)" 
	exit
fi




if [ ! -d "$base$fpath/$curhour" ]; then
        echo -e "NG $lb"
	echo "Hour directory does not exist ($base$fname/$curhour)"
	exit
fi



if [ ! -f "$base$fpath/$curhour/$curmin.mp4" ]; then
        echo -e "NG $lb"
	echo "Last minute not recorded ($base$fname/$curhour/$curmin.mp4)"
	exit
fi


echo "OK$lb"
echo found "$base$fpath/$curhour/$curmin.mp4"
echo $msg
}


if [ -z $REQUEST_METHOD ]; then
	echo "run on command line -- not in web "

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
	test)	GET_test=${VALUE} ;;
    esac    
   lb=""
done

elif  [[ $REQUEST_METHOD = 'GET' ]]; then

  
  echo "HTTP/1.1 200"
  echo -e "Content-type: text/html\n\n"
  echo ""
  lb="<br >"

  #since ash does not handle arrays we create variables using eval
  IFS='&'
  for PAIR in $QUERY_STRING
  do
      K=$(echo $PAIR | cut -f1 -d=)
      VA=$(echo $PAIR | cut -f2 -d=)
      eval GET_$K=$VA
  done

fi


  if [[ "$GET_test" = "recording" ]];  then
    test_recording
  fi

