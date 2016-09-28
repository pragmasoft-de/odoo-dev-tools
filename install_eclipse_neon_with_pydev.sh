#!/bin/bash

# Script to install Eclipse Neon with PyDev 5.2.0 on Ubuntu 16.04 LTS.
# (c) Josef Kaser 2016
# http://www.pragmasoft.de
#
# installs Eclipse and all components that are required for odoo development

# needed later in the script to go back to the script directory
START_DIR=$PWD

# get architecture of the system (32 or 64 bit)
ARCH=`arch`

# get the download link for Eclipse Neon that corresponds to the architecture
case $ARCH in
        x86_64)
                ECLIPSE_DL_LINK="http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/neon/R/eclipse-java-neon-R-linux-gtk-x86_64.tar.gz"
				ECLIPSE_FILE_NAME="eclipse-java-neon-R-linux-gtk-x86_64.tar.gz"
				WKHTMLTOPDF_DL_LINK="http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR_XZ="wkhtmltox-0.12.3_linux-generic-amd64.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR="wkhtmltox-0.12.3_linux-generic-amd64.tar"
                ;;
        i386)
                ECLIPSE_DL_LINK="http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/neon/R/eclipse-java-neon-R-linux-gtk.tar.gz"
				ECLIPSE_FILE_NAME="eclipse-java-neon-R-linux-gtk.tar.gz"
				WKHTMLTOPDF_DL_LINK="http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-i386.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR_XZ="wkhtmltox-0.12.3_linux-generic-i386.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR="wkhtmltox-0.12.3_linux-generic-i386.tar"
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

# install required Ubuntu packages for Python development
apt-get install gcc unzip python2.7 python-dev python-pychart python-gnupg python-pil python-zsi python-ldap python-lxml python-dateutil libxslt1.1 libxslt1-dev libldap2-dev libsasl2-dev python-pip poppler-utils xfonts-base xfonts-75dpi xfonts-utils libxfont1 xfonts-encodings xzip xz-utils python-openpyxl python-xlrd python-decorator python-requests python-pypdf python-gevent npm nodejs node-less node-clean-css git mcrypt keychain software-properties-common python-passlib libjpeg-dev libfreetype6-dev zlib1g-dev libpng12-dev -y

# install PostgreSQL
apt-get install postgresql-9.5 postgresql-client postgresql-client-common postgresql-contrib-9.5 postgresql-server-dev-9.5 -y

# install required python modules for odoo development
easy_install --upgrade pip
pip install BeautifulSoup BeautifulSoup4 passlib pillow dateutils polib unidecode flanker simplejson enum py4j

# install Node.js
npm install -g npm
npm install -g less-plugin-clean-css
npm install -g less@1.4.2

ln -s /usr/bin/nodejs /usr/bin/node
rm /usr/bin/lessc
ln -s /usr/local/bin/lessc /usr/bin/lessc

# install Oracle Java 8
./install_oracle_java8.sh

# get the users home directory
USER_HOME=`cat /etc/passwd | grep $USERNAME | awk -F ":" '{print $6}'`

# create eclipse.desktop from template and set some parameters
if [ -f eclipse.desktop ]
	then rm eclipse.desktop
fi

cp eclipse.desktop.template eclipse.desktop
sed -i s/{{username}}/$USERNAME/ eclipse.desktop

# install wkhtmltopdf
cd /tmp
mkdir wkhtmltopdf
cd wkhtmltopdf
wget $WKHTMLTOPDF_DL_LINK
unxz $WKHTMLTOPDF_FILE_NAME_TAR_XZ
tar xvf $WKHTMLTOPDF_FILE_NAME_TAR
cd wkhtmltox/bin
cp * /usr/local/bin/
cd /usr/bin
ln -s /usr/local/bin/wkhtmltopdf ./wkhtmltopdf
cd /tmp
rm -rf wkhtmltopdf

# download and untar Eclipse Neon
cd /tmp
mkdir eclipse
cd eclipse
wget "$ECLIPSE_DL_LINK"
tar xvfz "$ECLIPSE_FILE_NAME"

# download and unzip the PyDev plugin
cd /tmp
mkdir pydev
cd pydev
wget "$PYDEV_DL_URL"
unzip "$PYDEV_FILE_NAME"

# copy Eclipse and PyDev to its destination
cd $USER_HOME
mkdir eclipse
cd eclipse
cp -r /tmp/eclipse/eclipse/* .
cd dropins
mkdir pydev
cd pydev
cp -r /tmp/pydev/* .
chown $USERNAME.$USERNAME $USER_HOME/eclipse -R

# build debugger speedups for PyDev
/usr/bin/python2.7 $USER_HOME/eclipse/dropins/pydev/plugins/org.python.pydev_5.2.0.201608171824/pysrc/setup_cython.py build_ext --inplace

# create desktop shortcut file from template
cd $USER_HOME/.local/share/applications
cp $START_DIR/eclipse.desktop .
chown $USERNAME.$USERNAME eclipse.desktop
chmod +x eclipse.desktop

# add shortcut to Unity launcher
if [ `env | grep -w "INSTANCE" | awk -F "=" '{print $2}'` = "Unity" ]; then
	gsettings set com.canonical.Unity.Launcher favorites "['eclipse.desktop']"
fi

rm -rf /tmp/eclipse
rm -rf /tmp/pydev

