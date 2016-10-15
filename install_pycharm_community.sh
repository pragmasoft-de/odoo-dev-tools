#!/bin/bash

# Script to install Pycharm Community Edition on Ubuntu 16.04 LTS.
# (c) Josef Kaser 2016
# http://www.pragmasoft.de
#
# installs Pycharm and all components that are required for odoo development

# needed later in the script to go back to the script directory
START_DIR=$PWD

# get architecture of the system (32 or 64 bit)
ARCH=`arch`

# version of Pycharm
PYCHARM_VERSION='2016.2.3'

# get the download link for Pycharm Community Edition that corresponds to the architecture
case $ARCH in
        x86_64)
                PYCHARM_DL_LINK="https://download.jetbrains.com/python/pycharm-community-$PYCHARM_VERSION.tar.gz"
				PYCHARM_FILE_NAME="pycharm-community-$PYCHARM_VERSION.tar.gz"
				WKHTMLTOPDF_DL_LINK="http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR_XZ="wkhtmltox-0.12.3_linux-generic-amd64.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR="wkhtmltox-0.12.3_linux-generic-amd64.tar"
                ;;
        i386)
                PYCHARM_DL_LINK="https://download.jetbrains.com/python/pycharm-community-$PYCHARM_VERSION.tar.gz"
				PYCHARM_FILE_NAME="pycharm-community-$PYCHARM_VERSION.tar.gz"
				WKHTMLTOPDF_DL_LINK="http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-i386.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR_XZ="wkhtmltox-0.12.3_linux-generic-i386.tar.xz"
				WKHTMLTOPDF_FILE_NAME_TAR="wkhtmltox-0.12.3_linux-generic-i386.tar"
                ;;
        *)
                PYCHARM_DL_LINK="unsupported architecture"
                ;;
esac

# script must be run as root
if [ $USER != "root" ]; then
	echo "Script must be run as root"
	exit
fi

# script must be called with the name of the user who will run Pycharm as the first parameter
if [ -z "$1" ]; then
	echo "Usage: $0 username"
	exit
fi

# exit if the script is executed on an unsupported architecture
if [ $PYCHARM_DL_LINK = "unsupported architecture" ]; then
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
apt-get install postgresql-9.5 postgresql-client postgresql-client-common postgresql-contrib-9.5 postgresql-server-dev-9.5 pgadmin3 -y

# create database user "odoo"
/usr/bin/sudo -u postgres ./create_pg_role.sh

# install required python modules for odoo development
easy_install --upgrade pip
pip install BeautifulSoup BeautifulSoup4 passlib pillow dateutils polib unidecode flanker simplejson enum py4j

# install Node.js
npm install -g npm
npm install -g less-plugin-clean-css
npm install -g less

ln -s /usr/bin/nodejs /usr/bin/node
rm /usr/bin/lessc
ln -s /usr/local/bin/lessc /usr/bin/lessc

# install Oracle Java 8
./install_oracle_java8.sh

# get the users home directory
USER_HOME=`cat /etc/passwd | grep $USERNAME | awk -F ":" '{print $6}'`

# create pycharm.desktop from template and set some parameters
if [ -f pycharm.desktop ]
	then rm pycharm.desktop
fi

cp pycharm.desktop.template pycharm.desktop
sed -i s/{{username}}/$USERNAME/ pycharm.desktop

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

# download and untar Pycharm Community Edition
cd /tmp
mkdir pycharm
cd pycharm
wget "$PYCHARM_DL_LINK"
tar xvfz "$PYCHARM_FILE_NAME"

# copy Pycharm to its destination
cd $USER_HOME
mkdir pycharm
cd pycharm
cp -r /tmp/pycharm/pycharm-community-$PYCHARM_VERSION/* .
chown $USERNAME.$USERNAME $USER_HOME/pycharm -R

# build debugger speedups for Pycharm
/usr/bin/python2.7 $USER_HOME/pycharm/helpers/pydev/setup_cython.py build_ext --inplace

# create desktop shortcut file from template
cd $USER_HOME/.local/share/applications
cp $START_DIR/pycharm.desktop .
chown $USERNAME.$USERNAME pycharm.desktop
chmod +x pycharm.desktop

# add shortcut to Unity launcher
/usr/bin/sudo -u $USERNAME ./create_pycharm_launcher_shortcut.sh

rm -rf /tmp/pycharm

