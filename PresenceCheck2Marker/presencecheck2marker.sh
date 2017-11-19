#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:	PresenceCheck2Marker.sh
# Author:	BooosesThaSnipper
# Version:	0.4.0
# Date:		2017-11-19
# Project:	SmartHome
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
# Check needed Packages

# List of required packages
PACKAGES='bc curl hping3 jq nmap'

for PACKAGE in ${PACKAGES}; do
	# Check if package is installed
	STATUS_PACKAGE=$( dpkg -s ${PACKAGE} 2> /dev/null | grep -q "Status: install ok installed"; echo $? )
	if [ ${STATUS_PACKAGE} -ne 0 ]; then
		echo "${PACKAGE} is not installed"
		echo "Command for installing ${PACKAGE}: \"sudo apt-get install ${PACKAGE}\" "
		exit 1
	fi
done

# Define binary Path
BIN_ARP=$( which arp )
BIN_BC=$( which bc )
BIN_CURL=$( which curl )
BIN_HPING3=$( which hping3 )
BIN_JQ=$( which jq )
BIN_NMAP=$( which nmap )
BIN_WC=$( which wc )

# =========================================================================== #
# ########################################################################### #


# ########################################################################### #
# =========================================================================== #
# Script Logging

# Log Variables
LOG_AGE="14"
LOG_DIR="${HOME}/Cron_Logs"
LOG_DATE=$( date '+%F' )
LOG_FILE="${LOG_DIR}/presencecheck2marker.${LOG_DATE}"
LOG_LINK="${LOG_DIR}/presencecheck2marker"

# Check if Log Directory exists, if not create it
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

# Delete old Logfiles
find ${LOG_DIR} -type f -name "presencecheck2marker*" -mtime ${LOG_AGE} -exec rm {} \;

# =========================================================================== #
# ########################################################################### #


# ########################################################################### #
# =========================================================================== #
# Check Online Status of Smartphones


DATE=$( date +%F_%H-%M-%S%N )
echo "${DATE} - Start Presence Check"

# Check if Smartphonees logged in"
PRESENCE=0
for SMARTPHONE in ${SMARTPHONE_IP}; do
	DATE=$( date +%F_%H-%M-%S%N )
	echo "${DATE} - ${SMARTPHONE} check running"
	sudo ${BIN_ARP} -d ${SMARTPHONE}
	sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078 > /dev/null
	sudo ${BIN_HPING3} -2 -c 50 -p 5353 --fast ${SMARTPHONE} > /dev/null 2>&1
	sleep 1
    if [ $( sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host is up" ; echo $? ) -eq 0 ]; then
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - ${SMARTPHONE} online #check 1"
        PRESENCE=1
	elif [ $( ${BIN_ARP} -n ${SMARTPHONE} | grep -q incomplete; echo $? ) -eq 1 ]; then
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - ${SMARTPHONE} online #check 2"
		PRESENCE=1
    elif [ $( sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host seems down"; echo $? )  -eq 0 ]; then
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - ${SMARTPHONE} offline"
    else   
        echo "Unexpeted Error during Host Check"
	fi
	
	DATE=$( date +%F_%H-%M-%S%N )
	echo "${DATE} - -----"
done

# =========================================================================== #
# ########################################################################### #


# ########################################################################### #
# =========================================================================== #
# Update LightManager Marker Status

# Get actual Marker Status from LMA
PARAMS_TEMP='/tmp/params.json'
${BIN_CURL} -s http://${LMA_IP}/params.json > ${PARAMS_TEMP}
MARKER_COUNT=$( echo $( ${BIN_JQ} -r '.["marker state"]' ${PARAMS_TEMP} | ${BIN_WC} -m ) -1 | ${BIN_BC} )
MARKER_STATUS=$( printf  "%${MARKER_COUNT}.${MARKER}s\n" $( ${BIN_JQ} -r '.["marker state"]' ${PARAMS_TEMP} ) | awk '{print substr($0,length,1)}' )
rm -f ${PARAMS_TEMP}

# Check if Marker Status differ from Presence Status
if [ ${MARKER_STATUS} -eq ${PRESENCE} ]; then
	DATE=$( date +%F_%H-%M-%S%N )
	echo "${DATE} - no Marker-Update needed"
else
	# Set Marker Depending from Presence Status
	if [ ${PRESENCE} -eq 1 ]; then
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - Presence activ"
		echo "${DATE} - Presence activ" >> ${LOG_FILE}
		STATUS=$( ${BIN_CURL} -s http://${LMA_IP}/control?key=${SCENE_ON} )
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - LightManager Marker Update Status: ${STATUS}"
	else 
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - Presence deactive"
		echo "${DATE} - Presence deactive" >> ${LOG_FILE}
		STATUS=$( ${BIN_CURL} -s http://${LMA_IP}/control?key=${SCENE_OFF} )
		DATE=$( date +%F_%H-%M-%S%N )
		echo "${DATE} - LightManager Marker Update Status: ${STATUS}"
	fi
fi

DATE=$( date +%F_%H-%M-%S%N )
echo "${DATE} - -------------------------------------"

# =========================================================================== #
# ########################################################################### #

# ########################################################################### #
# =========================================================================== #
# CleanUp Section

unset LMA_IP
unset SMARTPHONE_IP
unset SCENE_ON
unset SCENE_OFF
unset MARKER
unset LOG_AGE
unset LOG_DIR
unset LOG_DATE
unset LOG_FILE
unset LOG_LINK
unset PACKAGES
unset PACKAGE
unset STATUS_PACKAGE
unset BIN_ARP
unset BIN_BC
unset BIN_CURL
unset BIN_HPING3
unset BIN_JQ
unset BIN_NMAP
unset BIN_WC
unset DATE
unset SMARTPHONE
unset PRESENCE
unset PARAMS_TEMP
unset MARKER_COUNT
unset MARKER_STATUS
unset STATUS

# =========================================================================== #
# ########################################################################### #

exit
