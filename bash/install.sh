#!/bin/bash

#LOG = "/media/usb"
#check for internet connectivity
test=google.com

echo "testing access to $test"
if nc -zw1 $test 443 && echo |openssl s_client -connect $test:443 2>&1 |awk '
  handshake && $1 == "Verification" { if ($2=="OK") exit; exit 1 }
  $1 $2 == "SSLhandshake" { handshake = 1 }'
then
  #internet access confirmed update apt-get
  echo "$test available, installing packages"
  sudo apt-get -y update

  #TODO: install/upgrade missing packages and save them to drive repository
else
  #no internet connection, confirm install from usb drive
  read -r -p "$test unavailable, install from usb? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    #TODO find usb mount point and cp stored .deb files to /var/cache/apt/archive
    #TODO add argument to specify version of .deb archive to cp?
    #for now assume usb is mounted at /media/usb
    echo DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    echo "deb file:/media/usb/AirDojo/archives/base-v1 ./" >> /etc/apt/sources.list
    #if [ -d "$archive" ]; then
    #  sudo cp -rf "$archive/." "/var/cache/apt/archive/"
    #fi
    #archive=/media/usb/AirDojo/archives/apt-base/*.deb

    #for f in $archive
    #do
    #  echo "Caching $f"
    #  sudo dpkg -i $f
    #done

    #sudo dpkg -i /media/usb/AirDojo/archives/base-v1/*.deb

    apt-get update

    for package in `cat /media/usb/AirDojo/archives/base-v1/package_names`
    do
      echo "  "
      echo "==============================================="
      echo "installing $package"
      echo "+++++++++++++++++++++++++++++++++++++++++++++++"
      apt-get install -y $package
    done

    apt-cache dump | grep -oP 'Package: \K.*' | sort -n | while read -r line
    do
      apt-get install -y $line
    done



    #sudo apt-get -f install

      #dpkg -I /var/cache/apt/archive/usbmount_0.0.22_all.deb | grep Depends | sed 's/.*://'
  else
    #no intenet connection and refusal to install from usb, exit script
    echo "Please connect C.H.I.P to internet with the command: 'sudo nmcli device wifi connect '(your wifi network name/SSID)' password '(your wifi password)' ifname wlan0' or your method of choice. And try again"
    exit 2
  fi
fi



sudo apt-get -fy upgrade

sudo apt-get -fy install dnsmasq-base
sudo apt-get -fy install git zip unzip
sudo apt-get -fy install usbmount
sudo apt-get -fy install nodejs
