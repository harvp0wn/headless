# HEADLESS.sh

## Description:
Connects to remote server, mounts sshfs, opens vncvierew and ssh. Cleans up when done. Supports multiple connections at a time.

## Installation:
```
cd ~/
git clone https://github.com/harvp0wn/headless
cd headless
./headless --install
```
## Usage:
headless [no arguments will launch with default settings]
headless [user] [server(ip/hostname)] [server_dir]
headless [option]

	--help			Display this message
	--clean			Killall shfs and remove empty mount directories
	--config		Edit script to change defaults
	--defaults		List default arguments
	--install		Link to /usr/local/bin
	--remove		Remove link to /usr/local/bin

For VNC Connections put your exported vnc config file (ie server.vnc) in the install directory.

## Defaults:
```
user="pi"
server="pi64"
server_dir="/home/pi"
install_dir="$HOME/headless"
```

