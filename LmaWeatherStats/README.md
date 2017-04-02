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

Bevor Ihr beginnt bitte unbedingt folgende Schrite durchführen, damit euer System wirklich aktuell ist:

```
sudo apt-get update
sudo apt-get dist-upgrade
sudo pip install --upgrade pip
```


#### Notwendiges Software Repository hinzufügen und konfigurieren

Um die notwendige Software zu installieren, benötigen wir aus dem Debian Bereich das SID Repository welches wir innerhalb der APT-Sources eintragen müssen, dazu die source.list mitteils vi öffnen.

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


Nun editieren wir noch die apt-config und ergängen sie um folgend Einträge:

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


**Solltet Ihr hier nun jede Menge Updates angezeigt bekommen, solltet ihr hier auf alle Fälle aufhören und die Schritte oben rückgängig machen, da ihr sonst euer komplettes System damit kaputt machen könnt.**



Eventuell kommt hier noch ein Fehler zwecks einem ungültigen Key, den beheben wir aber gleich im Nachgang, der Fehler ist nur "kosmetischer" Natur.

```
sudo apt-get install debian-archive-keyring debian-keyring
```


#### Installation Grafana & InfluxDB


Nun beginnt die eigentliche Installation:
```
sudo apt-get install grafana influxdb influxdb-client jq
```


Nun solltet ihr wenn alles gut gelaufen ist, schon auf die Grafana Oberfläche zugreifen können:

http://RaspberryIP:3000

Logín: admin

Passwort: admin


** Passwort solltet ihr natürlich ändern! **