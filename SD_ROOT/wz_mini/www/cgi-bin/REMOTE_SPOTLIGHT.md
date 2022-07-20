When USB Direct connectivity is enabled, the camera will be unable to communicate with accessories. To enable remote spotlight accessory support, enable the following variable and set the IP Address of the host as follows:

REMOTE_SPOTLIGHT="true"
REMOTE_SPOTLIGHT_HOST="0.0.0.0"
Then, run the following command on the host where the spotlight is attached to:

socat TCP4-LISTEN:9000,reuseaddr,fork /dev/ttyUSB0,raw,echo=0
Change /dev/ttyUSB0 to whatever path your spotlight enumerated to if necessary. The camera will now be able to control the spotlight.
