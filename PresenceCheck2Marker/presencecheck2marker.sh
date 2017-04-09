#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:	presencecheck2marker.sh
# Author:	BooosesThaSnipper
# Version:	0.1
# Date:		2017-04-09
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

# Enter the IP of the Smartphones you want to check
## for one Smartphone 
# SMARTPHONE_IP='xxx.xxx.xxx.xxx'
## for two or more use space seperated list
SMARTPHONE_IP='xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx'

# Enter The Numer of Scene which will activate the Marker
SCENE_ON="xx"
# Enter The Numer of Scene which will activate the Marker
SCENE_OFF="xx"

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


# Check if Smartphonees logged in"
PRESENCE=0
for SMARTPHONE in ${SMARTPHONE_IP}; do
	if [ $(nmap -sP ${SMARTPHONE} | grep -q "Host seems down"; echo $? )  -eq 0 ]; then
		echo $SMARTPHONE offline
	elif [ $(nmap -sP ${SMARTPHONE} | grep -q "Host is up" ; echo $? ) -eq 0 ]; then
		echo $SMARTPHONE online
		PRESENCE=1
        else   
                echo "Unexpeted Error during Host Check"
	fi
done

# Set Marker Depending from Presence Status
if [ ${PRESENCE} -eq 1 ]; then
	echo "Presence activ"
	curl http://${LMA_IP}/control?key=${SCENE_ON}
else 
	echo "Presence deactive"
	curl http://${LMA_IP}/control?key=${SCENE_OFF}
fi


# =========================================================================== #
# ########################################################################### #

exit
