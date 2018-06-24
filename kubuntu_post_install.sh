#!/bin/bash
# ---------------------------------------------------------------------------
# kubuntu_post_install.sh - Installation of dev environment on Kubuntu 16+
# Usage: kubuntu_post_install.sh [-h|--help] [-p|--path path]
# ---------------------------------------------------------------------------
# Using MIT license
#
# Copyright 2017 Wwarrior
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ---------------------------------------------------------------------------
# Revision history:
# 2017-04-17 Created ver 1.0
# ---------------------------------------------------------------------------

PROGNAME=${0##*/}
VERSION="1.0"

# MAIN VARIABLES
SOFTWARE_PATH=/opt

# --- Creating log ---
exec > >(tee -i kubuntu_post_install.log)
exec 2>&1

# --- Printing on terminal ---
sout() {
  echo -e "\e[92m"
  echo -n "+ -------------"
  echo_n_times $1
  echo " +"
  echo    "| Installing - "\'$1\'" |"
  echo -n "+ -------------"
  echo_n_times $1
  echo -e " +\e[0m"
  
#  echo -e -n "\e[2m + Press to continue...\e[0m"; read -p ""    # COMMENT IT - TO AUTOMATICALLY RUN SCRIPT ----
}

sout_header() {
  echo -e "\e[92m\e[1m"
  echo -n "+ "
  echo_n_times_header $1
  echo " +"
  echo    "| "\'$1\'" |"
  echo -n "+ "
  echo_n_times_header $1
  echo -e " +\e[0m"
  
#  echo -e -n "\e[2m + Press to continue...\e[0m"; read -p ""    # COMMENT IT - TO AUTOMATICALLY RUN SCRIPT ----
}

echo_n_times() {
 len=$((${#1}+2))
 v=$(printf "%-${len}s" "-")
 echo -n "${v// /-}"
}

echo_n_times_header() {
 len=$((${#1}+2))
 v=$(printf "%-${len}s" "=")
 echo -n "${v// /=}"
}

usage() {
  echo -e "Usage: $PROGNAME [-h|--help] [-u] [-p|--path path]"
}

help_message() {
  cat <<- _EOF_
  $PROGNAME ver. $VERSION
  Installation of dev environment on Kubuntu

  $(usage)

  Options:
  -h, --help  Display this help message and exit.
  -p, --path SOFTWARE_PATH  specify path where software will be installed
    Where 'SOFTWARE_PATH' is the absolute path to a root software directory.

  NOTE: You must be the superuser to run this script.

_EOF_
  return
}
# ---------------------------

# --- Handle different types of exit ---
error_exit() {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  return    # pre-exit housekeeping
  exit 1
}

graceful_exit() {
  return    # pre-exit housekeeping
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}
# ---------------------------

# --- Trap signals ---
# trap "signal_exit TERM" TERM HUP
# trap "signal_exit INT"  INT

# --- Check for root UID ---
if [[ $(id -u) == 0 ]]; then
  error_exit "You cannot be the superuser to run this script."
fi

# --- Check K/Ubuntu version ---
UBUNTU_NAME=`cat /etc/issue | head -n 1 | awk '{print $1}'`
UBUNTU_VER=`cat /etc/issue | head -n 1 | awk '{print $2}' | awk -F. '{print $1}'`

if [ "$UBUNTU_NAME" != "Ubuntu" ]; then
  echo "Your system is not Ubuntu! Script was not tested on other systems yet."
fi

if [ "$((UBUNTU_VER))" -lt "16" ]; then
  error_exit "You must have (K)Ubuntu 16+"
fi
# ---------------------------

# --- Parse command-line ---
while [[ -n $1 ]]; do
  case $1 in
    -h | --help)
      help_message; graceful_exit ;;
    -p | --path)
      echo "Setting absolute path for software root directory"; shift; SOFTWARE_PATH=$1;
      if [[ ! -d "$SOFTWARE_PATH" ]]; then
        sudo mkdir $SOFTWARE_PATH
      fi ;;
    -* | --*)
      usage
      error_exit "Unknown option $1" ;;
    *)
      echo "Argument $1 to process..." ;;
  esac
  shift
done

ppa_install() {
    the_ppa=$1
    if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        yes | sudo add-apt-repository ppa:$the_ppa
    else
        echo " ++ '$the_ppa' already exists..."
    fi
    
    sudo apt update
}

# + ------------------ +
# |     Main logic     |
# + ------------------ +

sout_header "PREPARATION"
sudo apt update
echo "- - - - - - - - - - - - - - - - - - -"
yes | sudo apt install software-properties-common python-software-properties # for add-apt-repository
yes | sudo apt install curl git
echo "- - - - - - - - - - - - - - - - - - -"


sout_header "INSTALLATION_-_Utils"

sout "Tools_1_(netstat_net-tools_tree_where_whereis_locate)"
yes | sudo apt install netstat net-tools tree where whereis locate

sout "Tools_2_(htop_cpu-checker_screenfetch)"
yes | sudo apt install htop cpu-checker screenfetch

sout "VIM_(extended_mode)"
yes | sudo apt install vim

sout "TLP_(Advanced_Power_Management)"
yes | sudo apt install tlp 

sout "Grub_customizer"
ppa_install "danielrichter2007/grub-customizer"
yes | sudo apt install grub-customizer

sout "PulseAudio_Volume_Control"
yes | sudo apt install pavucontrol

sout "GParted"
yes | sudo apt install gparted

#sout "Synaptic_Package_Manager"
#yes | sudo apt install synaptic

sout "Bleachbit_(cleaner)"
yes | sudo apt install bleachbit

sout "CPU_frequency_indicator"
yes | sudo apt install indicator-cpufreq

echo "- - - - - - - - - - - - - - - - - - -"


sout_header "INSTALLATION_-_Apps"

sout "Firefox_Developer_Edition"
ppa_install "ubuntu-mozilla-daily/firefox-aurora"
yes | sudo apt install firefox
# using umake
# ( echo pl ) | umake web firefox-dev $SOFTWARE_PATH/web/firefox-dev

sout "Thunderbird"
ppa_install "mozillateam/thunderbird-next"      # Thunderbird Beta
yes | sudo apt install thunderbird

sout "Yakuake"
yes | sudo apt install yakuake

sout "Latte_Dock"
yes | sudo apt install latte-dock

sout "Gimp"
yes | sudo apt install gimp

sout "Filezilla"
yes | sudo apt install filezilla

sout "Chrome"
the_ppa="http://dl.google.com/linux/chrome/deb/"
if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt update
else
    echo " ++ '$the_ppa' already exists..."
fi
yes | sudo apt install google-chrome-stable

sout "Skype"
the_ppa="https://repo.skype.com/deb"
if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    yes | sudo apt install apt-transport-https
    curl https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
    echo "deb https://repo.skype.com/deb stable main" | sudo tee /etc/apt/sources.list.d/skypeforlinux.list
    sudo apt update
else
    echo " ++ '$the_ppa' already exists..."
fi
yes | sudo apt install skypeforlinux

# sout "VLC"
# ppa_install "videolan/stable-daily"
# yes | sudo apt install vlc

sout "Audacity_+_Lame"
yes | sudo apt install audacity libmp3lame0

sout "MusicBrainz_Picard"
yes | sudo apt install picard

echo "- - - - - - - - - - - - - - - - - - -"


sout_header "INSTALLATION_-_Programming_tools"

sout "Docker"
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
yes | sudo apt install docker-ce

sout "Maven"
yes | sudo apt install maven

sout "Gradle"
ppa_install "cwchien/gradle"
yes | sudo apt install gradle

sout "Java_8"
ppa_install "webupd8team/java"
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
yes | sudo apt install oracle-java8-installer
yes | sudo update-java-alternatives -s java-8-oracle
yes | sudo apt install oracle-java8-set-default
echo '*** Oracle Java 8 set as default JDK ***'

sout "Atom"
curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt update
yes | sudo apt install atom
# umake
# echo | umake ide atom $SOFTWARE_PATH/atom

sout "NodeJS"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
yes | sudo apt install nodejs
# umake
# echo | umake nodejs nodejs-lang $SOFTWARE_PATH/nodejs/nodejs-lang

sout "Visual_Studio_Code"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
yes | sudo apt install code
# umake
# echo | umake ide visual-studio-code $SOFTWARE_PATH/ide/visual-studio-code --accept-license

sout "Android_Studio"
ppa_install "maarten-fonville/android-studio"
yes | sudo apt install android-studio
# umake
# echo | umake android android-studio $SOFTWARE_PATH/android/android-studio --accept-license

# sout "Ubuntu_Make"
# ppa_install "ubuntu-desktop/ubuntu-make"
# yes | sudo apt install ubuntu-make

# sout "Android_SDK"
# echo | umake android android-sdk $SOFTWARE_PATH/android/android-sdk --accept-license

# sout "Haskell_+_Cabal_+_Stack"
# ppa_install "hvr/ghc"
# CABAL=`sudo apt-cache search "^cabal-install-[0-9]+.[0-9]*$" --names-only | sort -r | head -n 1 | awk '{print $1;}' `
# GHC=`sudo apt-cache search "^ghc-[0-9]+.[0-9]*.[0-9]*$" --names-only | sort -r | head -n 1 | awk '{print $1;}' `
# CABAL_VER=`$CABAL | awk -F- '{print $3}'`
# GHC_VER=`$GHC | awk -F- '{print $2}'`
# yes | sudo apt install $CABAL $GHC haskell-stack
# cat >> ~/.bashrc <<EOF
# export PATH="\$HOME/.cabal/bin:/opt/cabal/\$CABAL_VER/bin:/opt/ghc/\$GHC_VER/bin:\$PATH"
# EOF
# export PATH=~/.cabal/bin:/opt/cabal/\$CABAL_VER/bin:/opt/ghc/\$GHC_VER/bin:$PATH

sout "ZSH_+_Oh-My-ZSH"
yes | sudo apt install zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

sout "---_BACKPORTS_---"
ppa_install "kubuntu-ppa/backports"

echo "- - - - - - - - - - - - - - - - - - -"


sout_header "UPDATE_+_UPGRADE_+_CLEANUP"
#yes | sudo apt update
#echo "- - - - - - - - - - - - - - - - - - -"
yes | sudo apt full-upgrade
echo "- - - - - - - - - - - - - - - - - - -"
yes | sudo apt autoremove

echo "- - - - - - - - - - - - - - - - - - -"


sout_header "OTHER"
echo -e "\e[1m Please install manually: \e[0m"
echo -e "   Anaconda (\e[31m https://www.continuum.io/downloads \e[0m)"
echo -e "   Scala / SBT (\e[31m https://www.scala-lang.org/download/ \e[0m)"
echo -e "   Apache Tomcat (\e[31m http://tomcat.apache.org/whichversion.html \e[0m)"
echo -e "   Slack (\e[31m https://slack.com/downloads/linux \e[0m)"
echo -e "   Telegram (\e[31m https://desktop.telegram.org/ \e[0m)"
echo -e "   VMware Workstation (\e[31m http://www.vmware.com/products/workstation-for-linux.html \e[0m)"
echo -e "   FreeFileSync (\e[31m https://www.freefilesync.org/download.php \e[0m)"
echo ""

echo "- - - - - - - - - - - - - - - - - - -"


graceful_exit
