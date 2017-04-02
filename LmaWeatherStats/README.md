# LightManager Weather Stats
Filename:	LmaWeatherStats.sh

Author:		BooosesThaSnipper 

Version:	0.1 

Date:		2017-04-02 

Project:	SmartHome 


## Description:	
A script to to pull weather data from LightManager and push it into a 
InfluxDB for virtualisation within Grafana


### Installation (Deutsch)

#### Rasbian Betriebsystem aktualisieren

Bevor Ihr beginnt bitte unbedingt folgende Schrite durchf�hren, damit euer System wirklich aktuell ist:

```
sudo apt-get update
sudo apt-get dist-upgrade
sudo pip install --upgrade pip
```


#### Notwendiges Software Repository hinzuf�gen und konfigurieren

Um die notwendige Software zu installieren, ben�tigen wir aus dem Debian Bereich das SID Repository welches wir innerhalb der APT-Sources eintragen m�ssen, dazu die source.list mitteils vi �ffnen.

**sudo vi /etc/apt/sources.list***

```
# Debian Sid Repository
deb http://ftp.de.debian.org/debian sid main
```


Danach holen wir uns noch die passenden Keys damit dem Repository auch vertraut wird:
```
gpg --keyserver pgpkeys.mit.edu --recv-key  8B48AD6246925553      
gpg -a --export 8B48AD6246925553 | sudo apt-key add -
```


Nun editieren wir noch die apt-config und erg�ngen sie um folgend Eintr�ge:

**sudo vi /etc/apt/apt.conf.d/50raspi**

```
# Set Default Release
APT::Default-Release "jessie";
# Install only needed Packages
APT::Install-Recommends "false";
```


Nun kommt der erste spannende Schritt, wenn ihr alles richtig gemacht habt, sollten nun beim erneuten Updaten keine Updates angezeigt bekommen:

```
sudo apt-get update
sudo apt-get dist-upgrade
```


**Solltet Ihr hier nun jede Menge Updates angezeigt bekommen, solltet ihr hier auf alle F�lle aufh�ren und die Schritte oben r�ckg�ngig machen, da ihr sonst euer komplettes System damit kaputt machen k�nnt.**



Eventuell kommt hier noch ein Fehler zwecks einem ung�ltigen Key, den beheben wir aber gleich im Nachgang, der Fehler ist nur "kosmetischer" Natur.

```
sudo apt-get install debian-archive-keyring debian-keyring
```


#### Installation Grafana & InfluxDB


Nun beginnt die eigentliche Installation:
```
sudo apt-get install grafana influxdb influxdb-client jq
```


Nun solltet ihr wenn alles gut gelaufen ist, schon auf die Grafana Oberfl�che zugreifen k�nnen:

http://RaspberryIP:3000

Log�n: admin

Passwort: admin


** Passwort solltet ihr nat�rlich �ndern! **