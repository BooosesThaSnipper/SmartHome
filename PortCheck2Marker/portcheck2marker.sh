#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:	portcheck2marker.sh
# Author:	BooosesThaSnipper
# Version:	0.1
# Date:		2017-03-20
# Project:	SmartHome
# =========================================================================== #
# Description:	
# A script to check if a Service within the local LAN is reachable and depending
# from the status a LightManager Air Marker will be activated or deactivated
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #
# START - Declaration of Variables

# Enter your LightManager Air IP
LMA_IP='xxx.xxx.xxx.xxx'

# Enter the IP of the Host you want to check
HOST_IP='xxx.xxx.xxx.xxx'

# Enter the Port of the Service you want to check
PORT='xx'

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
STATUS_NETCAT=$( dpkg -s netcat-openbsd &> /dev/null; echo $? )
if [ $STATUS_NETCAT -ne 0 ]; then
	echo "netcat-openbsd is not installed"
	echo "Command for installing netcat-openbsd: \"sudo apt-get install netcat-openbsd\" "
	exit 1
fi

# Check if curl is installed
STATUS_CURL=$( dpkg -s curl &> /dev/null; echo $? )
if [ $STATUS_CURL -ne 0 ]; then
	echo "curl is not installed"
	echo "Command for installing curl: \"sudo apt-get install curl\" "
	exit 1
fi


# Check if Service is online
STATUS_CHECK=$( netcat -z -w 3 ${HOST_IP} ${PORT}; echo $? )
if [ ${STATUS_CHECK} -eq 0 ]; then
	echo "Service Online"
	curl http://${LMA_IP}/control?key=${SCENE_ON}
elif [ ${STATUS_CHECK} -eq 1 ]; then
	echo "Service Offline"
	curl http://${LMA_IP}/control?key=${SCENE_OFF}
else
	echo "Unexpeted Error during Host Check"
	exit 2
fi


# =========================================================================== #
# ########################################################################### #

exit
