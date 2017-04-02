#!/bin/bash
# ########################################################################### #
# =========================================================================== #
# Filename:	LmaWeatherStats.sh
# Author:	BooosesThaSnipper
# Version:	0.1
# Date:		2017-04-02
# Project:	SmartHome
# =========================================================================== #
# Description:	
# A script to to pull weather data from LightManager and push it into a 
# InfluxDB for virtualisation within Grafana
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #
# START - Declaration of Variables

# Enter your LightManager Air IP
LMA_IP='xxx.xxx.xxx.xxx'

# Weather Temp File
LMA_TEMP='/tmp/weather.json'

# InfluxDB Database
DB='LightManager'

# END - Declaration of Variables 
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
# =========================================================================== #
# ########################################################################### #



# ########################################################################### #
# =========================================================================== #

# Check if jq is installed
STATUS_JQ=$( dpkg -s jq &> /dev/null; echo $? )
if [ $STATUS_JQ -ne 0 ]; then
	echo "jq is not installed"
	echo "Command for installing jq: \"sudo apt-get install jq\" "
	exit 1
fi

# Check if curl is installed
STATUS_CURL=$( dpkg -s curl &> /dev/null; echo $? )
if [ $STATUS_CURL -ne 0 ]; then
	echo "curl is not installed"
	echo "Command for installing curl: \"sudo apt-get install curl\" "
	exit 1
fi

# Check if Database exists, if not it will create it
DB_CHECK=$( curl --silent -G http://localhost:8086/query --data-urlencode "q=SHOW DATABASES" | jq -r ".results[].series[].values" | grep -q "${DB}"; echo $? )
if [ ${DB_CHECK} -eq 0 ]; then
	# Database exist, nothing to to
	: 
elif [ ${DB_CHECK} -eq 1 ]; then
        echo "Database does not exist - will create it "
	curl --silent -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE ${DB}" > /dev/null 
else
        echo "Unexpeted Error during Database Check"
        exit 2
fi

# Save weather.json local for fast processing
curl --silent http://${LMA_IP}/weather.json > ${LMA_TEMP}

# Get information from weather.json and push it into InfluxDB
for i in internal owm $( for j in `seq 1 10`; do echo "channel${j}"; done ); do

	# Get Temperature and check value
	TEMPERATURE=$( jq -r ".${i}.temperature" ${LMA_TEMP} )
	if [ -z $TEMPERATURE ]; then
                CURL_TEMPERATURE=""
        elif [ $TEMPERATURE = null ]; then
                CURL_TEMPERATURE=""
        else
                CURL_TEMPERATURE="temperature=${TEMPERATURE}"
        fi

	
	# Get Humidity and check value
	HUMIDITY=$( jq -r ".${i}.humidity" ${LMA_TEMP} )
        if [ -z $HUMIDITY ]; then
		CURL_HUMIDITY=""
	elif [ $HUMIDITY = null ]; then
		CURL_HUMIDITY=""
	else
		CURL_HUMIDITY="humidity=${HUMIDITY}"
        fi


	# If both values not empty we have to add a serperator 
	if [ ! -z $CURL_TEMPERATURE ] &&  [ ! -z $CURL_HUMIDITY ]; then
		SEPERATOR=","
		PUSH=1
	elif [ -z $CURL_TEMPERATURE ] &&  [ -z $CURL_HUMIDITY ]; then
		PUSH=0
	else
		PUSH=1
	fi


	# If values exist, push it to DB
	if [ $PUSH -eq 1 ]; then
		curl --silent -i -XPOST "http://localhost:8086/write?db=${DB}" --data-binary "environment,sensor=${i} ${CURL_TEMPERATURE}${SEPERATOR}${CURL_HUMIDITY}" > /dev/null
	fi

done

rm -f $LMA_TEMP

# =========================================================================== #
# ########################################################################### #

exit
