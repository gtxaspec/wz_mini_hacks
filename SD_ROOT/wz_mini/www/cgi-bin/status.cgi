#!/bin/sh
# This serves a rudimentary webpage to test different features of the camera
. /opt/wz_mini/www/cgi-bin/shared.cgi


echo "tz: $TZ"

test_gpio()
{
 num=$1
 #gpiodir=$(cat $gpiopath/gpio$num/direction)

 #echo "gpiodir was $gpiodir for $num"

 #newdir="in"
 #echo $newdir > $gpiopath/gpio$num/direction
 ##echo "set to in on $num"


 myval=$(cat "$gpiopath/gpio$num/value")
 #echo "read value $myval for $num"
 if [[ "$myval" -eq "0" ]]; then
        echo "OFF"
 else
        echo "ON"
 fi

 #if [[ "$gpiodir" != "in" ]]; then
 #  echo $gpiodir > $gpiopath/gpio$num/direction
 #fi


}


test_irled()
{
 test_gpio 47
 echo "IRLED Test"
}

test_night()
{
 runmode=$(cat /proc/jz/isp/isp-m0 | grep "Runing Mode" | cut -d ":" -f 2 | sed -e 's/^[[:space:]]*//' )
 if [[ "$runmode" = "Night" ]]; then
	echo "OK$lb"
 else
	echo "NG$lb"
 fi

 echo "Test Night (Running Mode: $runmode)"
}

test_recording()
{

msg=""
utchour=$(TZ="UTC" date +"%H")
fpath=$(TZ="$TZ" date +"%Y%m%d")
nowmin=$(TZ="$TZ" date +"%M")
curmin=$((10#$nowmin - 1))
curhour=$(TZ="$TZ" date +"%H")
cursec=$(TZ="$TZ" date +"%S")


if [[ "$utchour" == "$curhour" ]]; then
     echo "TZ is returning UTC (Possible parsing error?) $utcnow $tznow"
fi

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

if [ ! -d "$recpath$fpath" ]; then
	echo -e "NG $lb"
	echo "Date directory does not exist ($recpath$fpath)" 
	exit
fi


if [ ! -d "$recpath$fpath/$curhour" ]; then
        echo -e "NG $lb"
	echo "Hour directory does not exist ($recpath$fpath/$curhour)"
	exit
fi



if [ ! -f "$recpath$fpath/$curhour/$curmin.mp4" ]; then
        echo -e "NG $lb"
	echo "Last minute not recorded ($recpath$fpath/$curhour/$curmin.mp4)"
	exit
fi


echo "OK$lb"
echo found "$recpath$fpath/$curhour/$curmin.mp4"
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
  elif [[ "$GET_test" = "irled" ]]; then
    test_irled
  elif [[ "$GET_test" = "night" ]]; then
    test_night
  fi
