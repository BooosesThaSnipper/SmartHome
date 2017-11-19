#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:	PresenceCheck2Marker.sh
# Author:	BooosesThaSnipper
# Version:	0.4.1
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

# Debug Mode - 0 = off - 1 = on
DEBUG='0'

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
BIN_ARP=$( sudo which arp )
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
LOG_NAME=$( basename -a -s .sh $0 )
LOG_DATE=$( date '+%F' )
LOG_FILE="${LOG_DIR}/${LOG_NAME}.${LOG_DATE}"
LOG_LINK="${LOG_DIR}/${LOG_NAME}"

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
find ${LOG_DIR} -type f -name "${LOG_NAME}*" -mtime ${LOG_AGE} -exec rm {} \;

# =========================================================================== #
# ########################################################################### #


# ########################################################################### #
# =========================================================================== #
# Check Online Status of Smartphones

echo "$( date +%F_%H-%M-%S%N ) - Start Presence Check"

# Debug Logging
if [ ${DEBUG} -eq 1 ]; then
	echo "$( date +%F_%H-%M-%S%N ) - Start Presence Check" >> ${LOG_FILE}
fi

# Check if Smartphonees logged in"
PRESENCE=0
for SMARTPHONE in ${SMARTPHONE_IP}; do
	echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} check running"

	# Debug Logging
	if [ ${DEBUG} -eq 1 ]; then
		echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} check running" >> ${LOG_FILE}
	fi

	# Delete ARP Entry for Smartphone
	sudo ${BIN_ARP} -d ${SMARTPHONE} > /dev/null 2>&1
	# do a short nmap network scan
	sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078 > /dev/null
	# tries to wake up phone if it sleeps
	sudo ${BIN_HPING3} -2 -c 50 -p 5353 --fast ${SMARTPHONE} > /dev/null 2>&1

	# wait a short moment
	sleep 1

	# check if Smartphone is reachable through a fast network scan
	if [ $( sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host is up" ; echo $? ) -eq 0 ]; then
		echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} online #check 1"
	
		# Debug Logging
		if [ ${DEBUG} -eq 1 ]; then
			echo "$( date +%F_%H-%M-%S%N ) - sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078" >> ${LOG_FILE}
			echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} online #check 1" >> ${LOG_FILE}
		fi
		PRESENCE=1

	# check if Smartphone's MAC is correct in the local arp table
	elif [ $( sudo ${BIN_ARP} -n ${SMARTPHONE} | grep -q -E '(incomplete|no entry|unvollständig|kein Eintrag)'; echo $? ) -eq 1 ]; then
		echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} online #check 2"

		# Debug Logging
		if [ ${DEBUG} -eq 1 ]; then
			echo "$( date +%F_%H-%M-%S%N ) - sudo ${BIN_ARP} -n ${SMARTPHONE}" >> ${LOG_FILE}
			echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} online #check 2" >> ${LOG_FILE}
		fi		
		PRESENCE=1

	# If both checks are negativ, it seems smarthone is offline, but dopple check it
	elif [ $( sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host seems down"; echo $? )  -eq 0 ]; then
		echo "$$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} offline"
		
		# Debug Logging
		if [ ${DEBUG} -eq 1 ]; then
			echo "$( date +%F_%H-%M-%S%N ) - sudo ${BIN_NMAP} -sU -sT ${SMARTPHONE} -p U:5353,T:62078" >> ${LOG_FILE}
			echo "$( date +%F_%H-%M-%S%N ) - ${SMARTPHONE} offline" >> ${LOG_FILE}
		fi

	# Error Handling
	else
		echo "Unexpeted Error during Host Check"

		# Debug Logging
		if [ ${DEBUG} -eq 1 ]; then
			echo "Unexpeted Error during Host Check" >> ${LOG_FILE}
		fi
	fi
	
	# for pretty logfile
	echo "$( date +%F_%H-%M-%S%N ) - -----"
	if [ ${DEBUG} -eq 1 ]; then
		echo "$( date +%F_%H-%M-%S%N ) - -----" >> ${LOG_FILE}
	fi
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
	echo "$( date +%F_%H-%M-%S%N ) - no Marker-Update needed"
	
	# Debug Logging
	if [ ${DEBUG} -eq 1 ]; then
		echo "$( date +%F_%H-%M-%S%N ) - no Marker-Update needed" >> ${LOG_FILE}
	fi	
else
	# Set Marker Depending from Presence Status
	if [ ${PRESENCE} -eq 1 ]; then
		echo "$( date +%F_%H-%M-%S%N ) - Presence activ"
		echo "$( date +%F_%H-%M-%S%N ) - Presence activ" >> ${LOG_FILE}
		STATUS=$( ${BIN_CURL} -s http://${LMA_IP}/control?key=${SCENE_ON} )
		echo "$( date +%F_%H-%M-%S%N ) - LightManager Marker Update Status: ${STATUS}"
		
		# Debug Logging
		if [ ${DEBUG} -eq 1 ]; then
			echo "$( date +%F_%H-%M-%S%N ) - LightManager Marker Update Status: ${STATUS}" >> ${LOG_FILE}
		fi
	else 
		echo "$( date +%F_%H-%M-%S%N ) - Presence deactive"
		echo "$( date +%F_%H-%M-%S%N ) - Presence deactive" >> ${LOG_FILE}
		STATUS=$( ${BIN_CURL} -s http://${LMA_IP}/control?key=${SCENE_OFF} )
		echo "$( date +%F_%H-%M-%S%N ) - LightManager Marker Update Status: ${STATUS}"
		
		# Debug Logging
		if [ ${DEBUG} -eq 1 ]; then
			echo "$( date +%F_%H-%M-%S%N ) - LightManager Marker Update Status: ${STATUS}" >> ${LOG_FILE}
		fi
	fi
fi

# for pretty logfile
echo "$( date +%F_%H-%M-%S%N ) - -------------------------------------"
if [ ${DEBUG} -eq 1 ]; then
	echo "$( date +%F_%H-%M-%S%N ) - -------------------------------------" >> ${LOG_FILE}
fi

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
unset SMARTPHONE
unset PRESENCE
unset PARAMS_TEMP
unset MARKER_COUNT
unset MARKER_STATUS
unset STATUS

# =========================================================================== #
# ########################################################################### #

exit
