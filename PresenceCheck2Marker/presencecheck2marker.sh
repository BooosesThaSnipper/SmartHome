#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:     PresenceCheck2Marker.sh
# Author:       BooosesThaSnipper
# Version:      0.3.2
# Date:         2017-04-11
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

# Check if hping3 is installed
STATUS_HPING3=$( dpkg -s hping3 &> /dev/null; echo $? )
if [ $STATUS_HPING3 -ne 0 ]; then
        echo "hping3 is not installed"
        echo "Command for installing hping3: \"sudo apt-get install hping3\" "
        exit 1
fi

DATE=$( date +%F_%H-%M-%S%N )
echo "${DATE} - Start Presence Check"

# Check if Smartphonees logged in"
PRESENCE=0
for SMARTPHONE in ${SMARTPHONE_IP}; do
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - ${SMARTPHONE} check running"
        sudo nmap -sU -sT ${SMARTPHONE} -p U:5353,T:62078 > /dev/null
        sudo hping3 -2 -c 10 -p 5353 --fast ${SMARTPHONE} > /dev/null 2>&1
        sleep 1
        if [ $( sudo nmap -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host is up" ; echo $? ) -eq 0 ]; then
                DATE=$( date +%F_%H-%M-%S%N )
                echo "${DATE} - $SMARTPHONE online"
                PRESENCE=1
        elif [ $( arp -an | grep "${SMARTPHONE}" | grep -q "incomplete" ; echo $? ) -eq 1 ]; then
                DATE=$( date +%F_%H-%M-%S%N )
                echo "${DATE} - $SMARTPHONE online"
                PRESENCE=1
        elif [ $( sudo nmap -sU -sT ${SMARTPHONE} -p U:5353,T:62078 | grep -q "Host seems down"; echo $? )  -eq 0 ]; then
                DATE=$( date +%F_%H-%M-%S%N )
                echo "${DATE} - $SMARTPHONE offline"
        else
                echo "Unexpeted Error during Host Check"
        fi

        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - -----"
done

# Set Marker Depending from Presence Status
if [ ${PRESENCE} -eq 1 ]; then
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - Presence activ"
        STATUS=$( curl -s http://${LMA_IP}/control?key=${SCENE_ON} )
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - LightManager Marker Update Status: ${STATUS}"
else
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - Presence deactive"
        STATUS=$( curl -s http://${LMA_IP}/control?key=${SCENE_OFF} )
        DATE=$( date +%F_%H-%M-%S%N )
        echo "${DATE} - LightManager Marker Update Status: ${STATUS}"
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
unset STATUS_NMAP
unset STATUS_CURL
unset STATUS_HPING3
unset SMARTPHONE
unset STATUS
unset PRESENCE
unset DATE

# =========================================================================== #
# ########################################################################### #

exit
