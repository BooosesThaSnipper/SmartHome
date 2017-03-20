#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:	hostping2marker.sh
# Author:	BooosesThaSnipper
# Version:	0.1
# Date:		2017-03-20
# Project:	SmartHome
# =========================================================================== #
# Description:	
# A script to check if a Host within the local LAN is reachable and depending
# from the status a LightManager Air Marker will be activated or deactivated
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #
# START - Declaration of Variables

# Enter your LightManager Air IP
LMA_IP='192.168.178.254'

# Enter the IP of the Host you want to check
HOST_IP='192.168.178.253'


# END - Declaration of Variables 
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #

# Check if fping is installed
STATUS_FPING=$( dpkg -s fping &> /dev/null; echo $? )
if [ $STATUS_FPING -ne 0 ]; then
	echo "fping is not installed"
	echo "Command for installing fping: \"sudo apt-get install fping\" "
	exit 1
fi

# Check if Host is online
STATUS_CHECK=$( fping -q ${HOST_IP}; echo $? )
if [ ${STATUS_CHECK} -eq 0 ]; then
	echo "Host Online"
elif [ ${STATUS_CHECK} -eq 1 ]; then
	echo "Host Offline"
else
	echo "Unexpeted Error during Host Check"
	exit 2
fi


# =========================================================================== #
# ########################################################################### #

