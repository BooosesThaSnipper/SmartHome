#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:     PresenceCheck2Marker.sh
# Author:       BooosesThaSnipper
# Version:      0.3.4
# Date:         2017-04-20
# Project:      SmartHome
# =========================================================================== #
# Description:
# A Script to check if Smartphones logged into the lokal WLAN to detect
# presence at Home and depeinding from it, set LightManager Marker
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #
# START - Declaration of Variables

# Enter your LightManager Air IP
LMA_IP='xxx.xxx.xxx.xxx'

# Enter the IP of the Smartphones you want to check without any leading zero
## for one Smartphone 
# SMARTPHONE_IP='xxx.xxx.xxx.xxx'
## for two or more use space seperated list
SMARTPHONE_IP='xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx'

# Enter The Numer of Scene which will activate the Marker
SCENE_ON='xx'
# Enter The Numer of Scene which will activate the Marker
SCENE_OFF='xx'

# Enter the Number of the Marker you want to modify (1 - 32)
MARKER='xx'

# END - Declaration of Variables 
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #

# Check if netcat is installed
STATUS_NMAP=$( dpkg -s nmap &> /dev/null; echo $? )
if [ $STATUS_NMAP -ne 0 ]; then
	echo "nmap is not installed"
	echo "Command for installing nmap: \"sudo apt-get install nmap\" "
	exit 1
fi

# Check if curl is installed
STATUS_CURL=$( dpkg -s curl &> /dev/null; echo $? )
if [ $STATUS_CURL -ne 0 ]; then
	echo "curl is not installed"
	echo "Command for installing curl: \"sudo apt-get install curl\" "
	exit 1
fi

# Check if hping3 is installed
STATUS_HPING3=$( dpkg -s hping3 &> /dev/null; echo $? )
if [ $STATUS_HPING3 -ne 0 ]; then
        echo "hping3 is not installed"
        echo "Command for installing hping3: \"sudo apt-get install hping3\" "
        exit 1
fi

# Log Variables
LOG_AGE="14"
LOG_DIR="${HOME}/batch_logs"
LOG_DATE=$( date '+%F' )
LOG_FILE="${LOG_DIR}/presencecheck2marker.${LOG_DATE}"
LOG_LINK="${LOG_DIR}/presencecheck2marker"

# Check if Log Dir exists, if not it will create it
if [ ! -d ${LOG_DIR} ]; then
        mkdir -p ${LOG_DIR}
fi

# Check if Symlink to latest log exists
if [ ! -L ${LOG_LINK} ]; then
        ln -s ${LOG_FILE} ${LOG_LINK}
else
        unlink ${LOG_LINK}
        ln -s ${LOG_FILE} ${LOG_LINK}
fi


DATE=$( date +%F_%H-%M-%S%N )
echo "${DATE} - Start Presence Check"

# Check if Smartphonees logged in"
PRESENCE=0
for SMARTPHONE in ${SMARTPHONE_IP}; do
	DATE=$( date +%F_%H-%M-%S%N )
	echo "${DATE} - ${SMARTPHONE} check running" >> ${LOG_FILE}
	sudo nmap -sU -sT ${SMARTPHONE} -p U:5353,T:62078 > /dev/null
	sudo hping3 -2 -c 10 -p 5353 --fast ${SMARTPHONE} > /dev/null 2>&1
	sleep 1
        if [ $( sudo nmap -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host is up" ; echo $? ) -eq 0 ]; then
                DATE=$( date +%F_%H-%M-%S%N )
                echo "${DATE} - $SMARTPHONE online #check 1" >> ${LOG_FILE}
                PRESENCE=1
	elif [ $( /usr/sbin/arp -n ${SMARTPHONE} | grep -q incomplete; echo $? ) -eq 1 ]; then
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - $SMARTPHONE online #check 2" >> ${LOG_FILE}
		PRESENCE=1
        elif [ $( sudo nmap -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host seems down"; echo $? )  -eq 0 ]; then
                DATE=$( date +%F_%H-%M-%S%N )
                echo "${DATE} - $SMARTPHONE offline" >> ${LOG_FILE}
        else   
                echo "Unexpeted Error during Host Check" >> ${LOG_FILE}
	fi
	
	DATE=$( date +%F_%H-%M-%S%N )
	echo "${DATE} - -----" >> ${LOG_FILE}
done

# Get actual Marker Status from LMA
PARAMS_TEMP='/tmp/params.json'
curl -s http://${LMA_IP}/params.json > ${PARAMS_TEMP}
MARKER_STATUS=$( printf  "%32.${MARKER}s\n" $( jq -r '.["marker state"]' ${PARAMS_TEMP} ) | awk '{print substr($0,length,1)}' )
rm -f ${PARAMS_TEMP}

# Check if Marker Status differ from Presence Status
if [ ${MARKER_STATUS} -eq ${PRESENCE} ]; then
	DATE=$( date +%F_%H-%M-%S%N )
	echo "${DATE} - no Marker-Update needed" >> ${LOG_FILE}
else
	# Set Marker Depending from Presence Status
	if [ ${PRESENCE} -eq 1 ]; then
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - Presence activ" >> ${LOG_FILE}
		STATUS=$( curl -s http://${LMA_IP}/control?key=${SCENE_ON} )
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - LightManager Marker Update Status: ${STATUS}" >> ${LOG_FILE}
	else 
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - Presence deactive" >> ${LOG_FILE}
		STATUS=$( curl -s http://${LMA_IP}/control?key=${SCENE_OFF} )
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - LightManager Marker Update Status: ${STATUS}" >> ${LOG_FILE}
	fi
fi

DATE=$( date +%F_%H-%M-%S%N )
echo "${DATE} - -------------------------------------" >> ${LOG_FILE}

# Delete old Logfiles
find ${LOG_DIR} -type f -name "presencecheck2marker*" -mtime ${LOG_AGE} -exec rm {} \;

# =========================================================================== #
# ########################################################################### #

# ########################################################################### #
# =========================================================================== #
# CleanUp Section

unset LMA_IP
unset SMARTPHONE_IP
unset SCENE_ON
unset SCENE_OFF
unset STATUS_NMAP
unset STATUS_CURL
unset STATUS_HPING3
unset SMARTPHONE
unset STATUS
unset MARKER_STATUS
unset MARKER
unset PARAMS_TEMP
unset PRESENCE
unset DATE
unset LOG_AGE
unset LOG_DIR
unset LOG_DATE
unset LOG_FILE
unset LOG_LINK

# =========================================================================== #
# ########################################################################### #

exit
