#!/bin/bash

# Script to install Oracle Java 8 on Ubuntu 16.04 LTS.
# (c) Josef Kaser 2016
# http://www.pragmasoft.de
#
# based on https://gist.github.com/mugli/8720670

apt-get install python-software-properties -y
add-apt-repository ppa:webupd8team/java -y
apt-get update

# Enable silent install
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

apt-get install oracle-java8-installer -y

# Not always necessary, but just in case...
update-java-alternatives -s java-8-oracle

# Setting Java environment variables
apt-get install oracle-java8-set-default -y
