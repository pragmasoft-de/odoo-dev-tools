#!/bin/bash

# Script to add the desktop icon for Pycharm to the launcher
# (c) Josef Kaser 2016
# http://www.pragmasoft.de
#
# adds the desktop icon for Pycharm to the launcher

cd ~/.local/share/applications

gsettings set com.canonical.Unity.Launcher favorites "`gsettings get com.canonical.Unity.Launcher favorites | sed s/.$//` ,'$1/pycharm.desktop']"

