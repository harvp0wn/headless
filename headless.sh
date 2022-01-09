#!/bin/bash

# headless.sh				Last updated: 08-01-2022 From: xubuntu
# Author: Harvey Noel		email:harveynoel@pm.me

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

# --help
if [ "$1" = "--help" ]; then
cat << EOF
HEADLESS.sh

Description:
Connects to remote server, mounts sshfs, opens vncviewe and ssh. Cleans
up when done. Supports multiple connections at a time. Useful for 
connecting to headless systems such as raspberrypi. Usefull for quickly
connecting with a new client.

Usage:
headless [no arguments will launch with default.conf]
headless [user] [server(ip/hostname)] [server_dir]
headless [option]

Options:
-h	--help						Display help message
	--clean						Stop all SSHFS sessions and remove empty 
								mount dirs
-c	--config [file]				Use a different config file
-d	--defaults					Edit default.conf
	--install					Link headless.sh to 
								/usr/local/bin/headless
	--sshsetup [user] [server]	Generate keys and share with server
	--uninstall					Remove link /usr/local/bin/headless

For VNC Connections to work put your exported vnc config file 
(ie server.vnc) in the install directory.

Installation:
cd ~/
git clone https://github.com/harvp0wn/headless
cd headless
./headless --install

EOF
exit 0
fi

# Select config file
if [ "$1" = "--config" ]||[ "$1" = "-c" ]&&[ "$#" = "2" ]; then
	if [ -e $2.conf ]; then
	config="$2.conf"
	elif [ -e $2 ]; then
	config="$2"
	else
	echo "ERROR! Configuration file $2 Not found. Exiting..."
	exit 1
	fi
else
config="default.conf"
# Generate default.conf
if [ ! -e default.conf ]; then
echo "CAUTION! Generating default.conf"
cat > default.conf<< EOF
# Default config for headless
# headless [no arguments will launch with default.conf]
# headless [user] [server(ip/hostname)] [server_dir]

user="pi"
server="pi64"
server_dir="/home/pi"
install_dir="$HOME/headless"
EOF
fi
fi

# Load config file
. $config

# Variables
sh="$USER@$HOSTNAME:\$"
rootsh="root@$HOSTNAME:\$"

# -d --defaults
if [ "$1" = "--defaults" ]||[ "$1" = "-d" ]; then
nano default.conf
echo "Goodbye :)"
exit 0
fi

# --install
if [ "$1" = "--install" ]; then
echo "$rootsh sudo ln -s $install_dir/headless.sh /usr/local/bin/headless"
sudo ln -s "$install_dir/headless.sh" /usr/local/bin/headless
echo "Goodbye :)"
exit 0
fi

# --sshsetup
if [ "$1" = "--sshsetup" ]&&[ "$#" = "3" ]; then
user="$2"
server="$3"
echo "$sh ssh-keygen"
ssh-keygen
echo "$sh ssh-keygen $user@$server"
ssh-copy-id $user@$server
echo "Goodbye :)"
exit 0
fi

# --uninstall
if [ "$1" = "--uninstall" ]; then
echo "$rootsh sudo rm /usr/local/bin/headless"
sudo rm /usr/local/bin/headless
echo "Goodbye :)"
exit 0
fi

# --clean
if [ "$1" = "--clean" ]; then
echo "$sh killall sshfs"
killall sshfs
sleep 1s
echo "$sh rmdir $install_dir/sshfs-*-*"
rmdir $install_dir/sshfs-*-*
echo "Goodbye :)"
exit 0
fi

# Valid Server Fxn [ $1=port ] [returns y or n ]
valid_server () {
if nc -zw1 $server $1; then
	# Server exists and port is open
	echo "y"
else
	echo "n"
fi
}

# Make Mount Fxn
mk_mnt () {
if [ ! -d $install_dir/sshfs-$user-${server} ]; then
	echo "$sh mkdir $install_dir/sshfs-$user-${server}"
	mkdir $install_dir/sshfs-$user-${server}
	dir_existed=0
else
	echo "CAUTION! $install_dir/sshfs-$user-${server} already exists and will not be removed on exit"
	dir_existed=1
fi
}

# Disconnect Fxn
disconnect () {
# Disconnect sshfs when ssh session is exited
if [ $dir_existed = 0 ]; then
	echo "$sh fusermount -u $install_dir/sshfs-$user-${server}"
	fusermount -u $install_dir/sshfs-$user-${server}
	sleep 1s
	echo "$sh rmdir $install_dir/sshfs-$user-${server}"
	rmdir $install_dir/sshfs-$user-${server}
	echo "Goodbye :)"
	exit 0
elif [ $dir_existed = 1 ]; then
	echo "CAUTION! $install_dir/sshfs-$user-${server} must be manually unmounted and removed try:"
	echo "headless --clean"
	echo "Goodbye :)"
	exit 1
fi
}

# VNC Connect Fxn
vnc_connect () {
# Does a vnc profile exist? Does it match $user? and is the server available?
if [ -e $install_dir/$server.vnc ]&&[ "UserName=$user" = "$(cat $install_dir/$server.vnc | grep UserName)" ]&&[ "$(valid_server 5900)" = "y" ]; then
echo "$sh vncviewer $install_dir/$server.vnc &"
vncviewer $install_dir/$server.vnc &
fi	
}

# Connect Fxn
connect () {

if [ "$(valid_server ssh)" = "y" ]; then
	echo "Connecting to $server ... "
else
	echo "ERROR! $server is not available. Exiting ..."
	exit 1
fi

mk_mnt

echo "$sh sshfs $user@${server}:${server_dir} $install_dir/sshfs-$user-${server}"
sshfs $user@${server}:${server_dir} $install_dir/sshfs-$user-${server}

vnc_connect

echo "$sh thunar $install_dir/sshfs-$user-${server} &"
thunar $install_dir/sshfs-$user-${server} &

echo "$sh ssh $user@${server}"
ssh $user@${server}

disconnect
}

# Program
# Exit Status:
# exit 0 = success
# exit 1 = error
# exit 3 = debug

if [ $# = 0 ]; then
	connect
fi

if [ $# = 3 ]; then
	# server [user] [server] [server_dir]
	user=$1
	server=$2
	server_dir=$3
	connect
fi

if [ "$1" = "--config" ]||[ "$1" = "-c" ]&&[ "$#" -lt "3" ]; then
	connect
	else
	echo "ERROR! not enough arguments. Exiting ..."
	exit 1
fi

if [ $# -gt 3 ]; then
	echo "ERROR! too many arguments. Exiting ..."
	exit 1
fi

