#!/bin/bash

# headless.sh				Last updated: 07-01-2022 From: xubuntu
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

# Defaults
user="pi"
server="pi64"
server_dir="/home/pi"
install_dir="$HOME/headless"

# --help
if [ "$1" = "--help" ]; then
cat << EOF
HEADLESS.sh

Description:
Connects to remote server, mounts sshfs, opens vncvierew
and ssh. Cleans up when done. Supports multiple connections
at a time.

Usage:
headless [no arguments will launch with default settings]
headless [user] [server(ip/hostname)] [server_dir]
headless [option]

	--help			Display this message
	--clean			Killall shfs and remove
					empty mount directories
	--config        Edit script to change defaults
	--defaults		List default arguments
	--install		Link to /usr/local/bin
	--remove		Remove link to /usr/local/bin

For VNC Connections put your exported vnc config file 
(ie server.vnc) in the script directory.

Installation:
cd ~/
git clone https://github.com/harvp0wn/headless
cd headless
./headless --install

EOF
exit 0
fi

# Variables
sh="$USER@$HOSTNAME:$(pwd)\$"

# --defaults
if [ "$1" = "--defaults" ]; then
echo "Defaults: $user@$server:$server_dir"
echo "Script Directory: $install_dir"
echo "Goodbye :)"
exit 0
fi

# --config
if [ "$1" = "--config" ]; then
nano "$0"
echo "Goodbye :)"
exit 0
fi

# --install
if [ "$1" = "--install" ]; then
echo "$sh sudo ln -s $install_dir/headless.sh /usr/local/bin/headless"
sudo ln -s "$install_dir/headless.sh" /usr/local/bin/headless
echo "Goodbye :)"
exit 0
fi

# --clean
if [ "$1" = "--clean" ]; then
echo "$sh killall sshfs"
killall sshfs
sleep 1s
echo "$sh rmdir ~/sshfs-*-*"
rmdir ~/sshfs-*-*
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
if [ ! -d ~/sshfs-$user-${server} ]; then
	echo "$sh mkdir ~/sshfs-$user-${server}"
	mkdir ~/sshfs-$user-${server}
	dir_existed=0
else
	echo "CAUTION! ~/sshfs-$user-${server} already exists and will not be removed on exit"
	dir_existed=1
fi
}

# Disconnect Fxn
disconnect () {
# Disconnect sshfs when ssh session is exited
if [ $dir_existed = 0 ]; then
	echo "$sh fusermount -u ~/sshfs-$user-${server}"
	fusermount -u ~/sshfs-$user-${server}
	sleep 1s
	echo "$sh rmdir ~/sshfs-$user-${server}"
	rmdir ~/sshfs-$user-${server}
	echo "Goodbye :)"
	exit 0
elif [ $dir_existed = 1 ]; then
	echo "CAUTION! ~/sshfs-$user-${server} must be manually unmounted and removed try:"
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

echo "$sh sshfs $user@${server}:${server_dir} ~/sshfs-$user-${server}"
sshfs $user@${server}:${server_dir} ~/sshfs-$user-${server}

vnc_connect

echo "$sh thunar ~/sshfs-$user-${server} &"
thunar ~/sshfs-$user-${server} &

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
	# if no argument then use defaults
	connect
fi

if [ $# = 3 ]; then
	# server [user] [server] [server_dir]
	user=$1
	server=$2
	server_dir=$3
	connect
fi

if [ $# -lt 3 ]; then
	echo "ERROR! not enough arguments. Exiting ..."
	exit 1
fi

if [ $# -gt 3 ]; then
	echo "ERROR! too many arguments. Exiting ..."
	exit 1
fi

