#!/bin/bash

# Script to install Eclipse Neon with PyDev 5.2.0 on Ubuntu 16.04 LTS.
# (c) Josef Kaser 2016
# http://www.pragmasoft.de
#

# needed later in the script to go back to the script directory
START_DIR=$PWD

# get architecture of the system (32 or 64 bit)
ARCH=`arch`

# get the download link for Eclipse Neon that corresponds to the architecture
case $ARCH in
        x86_64)
                ECLIPSE_DL_LINK="http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/neon/R/eclipse-java-neon-R-linux-gtk-x86_64.tar.gz"
				ECLIPSE_FILE_NAME="eclipse-java-neon-R-linux-gtk-x86_64.tar.gz"
                ;;
        i386)
                ECLIPSE_DL_LINK="http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/neon/R/eclipse-java-neon-R-linux-gtk.tar.gz"
				ECLIPSE_FILE_NAME="eclipse-java-neon-R-linux-gtk.tar.gz"
                ;;
        *)
                ECLIPSE_DL_LINK="unsupported architecture"
                ;;
esac

# download link for PyDev 5.2.0
PYDEV_DL_URL="http://downloads.sourceforge.net/project/pydev/pydev/PyDev%205.2.0/PyDev%205.2.0.zip"
PYDEV_FILE_NAME="PyDev 5.2.0.zip"

# script must be run as root
if [ $USER != "root" ]; then
	echo "Script must be run as root"
	exit
fi

# script must be called with the name of the user who will run Eclipse as the first parameter
if [ -z "$1" ]; then
	echo "Usage: $0 username"
	exit
fi

# exit if the script is executed on an unsupported architecture
if [ $ECLIPSE_DL_LINK = "unsupported architecture" ]; then
	echo "The CPU architecture of your system is not supported."
	exit
fi

USERNAME=$1

# check whether the given username exists
if [ `cat /etc/passwd | grep -i $USERNAME | wc -l` -eq 0 ] ; then
	echo "The given username does not exist or is not correct"
	exit
fi

# install Oracle Java 8
./install_oracle_java8.sh

# get the users home directory
USER_HOME=`cat /etc/passwd | grep $USERNAME | awk -F ":" '{print $6}'`

cp eclipse.desktop.template eclipse.desktop
sed -i s/{{username}}/$USERNAME/ eclipse.desktop

# download and untar Eclipse Neon
cd /tmp
mkdir eclipse
wget $ECLIPSE_DL_LINK
tar xvfz $ECLIPSE_FILE_NAME

# download and unzip the PyDev plugin
cd /tmp
mkdir pydev
cd pydev
wget $PYDEV_DL_URL
unzip $PYDEV_FILE_NAME

# copy Eclipse and PyDev to its destination
cd $USER_HOME
mkdir eclipse
cd eclipse
cp -r /tmp/eclipse/eclipse/* .
cd dropins
mkdir pydev
cd pydev
cp -r /tmp/pydev/features/* .
cp -r /tmp/pydev/plugins/* .
chown $USERNAME.$USERNAME $USER_HOME/eclipse -R

cd $USER_HOME/.local/share/applications
cp $START_DIR/eclipse.desktop .
chown $USERNAME.$USERNAME eclipse.desktop

rm -rf /tmp/eclipse
rm -rf /tmp/pydev

