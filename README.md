# HEADLESS.sh

## Description:
Connects to remote server, mounts sshfs, opens vncviewe and ssh. Cleans up when done. Supports multiple connections at a time. Useful for connecting to headless systems such as raspberrypi. Usefull for quickly connecting with a new client.

## Installation:
```
cd ~/
git clone https://github.com/harvp0wn/headless
cd headless
./headless --install
```
## Usage:
```
headless [no arguments will launch with default.conf]
headless [user] [server(ip/hostname)] [server_dir]
headless [option]

Options:
-h	--help				Display help message
	--clean				Stop all SSHFS sessions and remove empty mount dirs
-c	--config [file]			Use a different config file
-d	--defaults			Edit default.conf
	--install			Link headless.sh to /usr/local/bin/headless
	--sshsetup [user] [server]	Generate keys and share with server
	--uninstall			Remove link /usr/local/bin/headless
```
For VNC Connections to work put your exported vnc config file (ie server.vnc) in the install directory.
