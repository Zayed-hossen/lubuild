# Lubuild / Help / Diagnose / Network

For some background on network interfaces and utilities you may find [https://wiki.openwrt.org/doc/networking/network.interfaces] interesting - its NOT specific to Lubuntu, but practical and applicable nonetheless. 

see also:
* [General hardware diagnostics](https://github.com/artmg/lubuild/blob/master/help/diagnose/hardware.md) including radio devices
* 


## Basic Connectivity

Usually the first diagnostic step is to determine whether a connection can be made to a remote server, 
by trying out the end-to-end connectivity. 

```
# Name (or IP address) of remote server to test
HOST_NAME=host.domain.tld
# if you are not sure which specific server to try testing against, 
# use 8.8.8.8 which is Google's (highly available) Public DNS service


### PING
# This uses Internet Control Message Protocol (ICMP) error reporting
# which is quick and easy, but some servers may be configured to ignore these
# As well as showing if the connection works at all, it also shows the latency, 
# which means how long it took to get there and back, and this can indicate
# the quality of connection
ping $HOST_NAME


### TracePath
# This simple utility is installed by default in Lubuntu. 
# It can take a while to show results as it resolves each name as it goes, 
# but it will show you each node your traffic passes through on its way
# which helps you understand where any disconnect happens
tracepath $HOST_NAME


### MTR - MyTraceRoute
# mtr-tiny is a console app using ncurses for a tabular display, with few dependencies
# It should be installed by default on Lubuntu, but if not present then
# sudo apt-get install mtr-tiny
# For a speedy, interactive, tabular output that updates as it goes along
mtr $HOST_NAME

# or for a standard 'linear' console output (e.g. to pipe to a file)
mtr -rw $HOST_NAME


### TraceRoute
# This is the linux terminal equivalent of Windows TRACERT command (not installed by default)
# To compare and contract TraceRoute and MTR see
# * introduction to the two - https://www.digitalocean.com/community/tutorials/how-to-use-traceroute-and-mtr-to-diagnose-network-issues
# * one professional's view - https://blog.thousandeyes.com/caveats-of-popular-network-tools-traceroute/
# * several people's views - http://serverfault.com/questions/585862/why-mtr-is-much-faster-than-traceroute
sudo apt-get install traceroute

traceroute $HOST_NAME


### test remote server response
# if ping fails, but tracing the route seems to work, 
# you can test the response at the remote server, 
# as long as you know the Port you expect it to respond on
# - if not see http://www.networksorcery.com/enp/protocol/ip/ports00000.htm 
PORT_NO=xx

# simply, using telnet
telnet $HOST_NAME $PORT_NO

# quickly and definitively using netcat
nc -zv $HOST_NAME $PORT_NO
# you can also specify multiple port numbers, or even a range

```


## Physical and Transport

### diagnosing Network Manager Connections

```
# check the connection state
nmcli d

sudo less /var/log/syslog

#### for full debug logging, edit the configuration to add (without comments)
# [logging]
# level=DEBUG
sudo editor /etc/NetworkManager/NetworkManager.conf

# then restart nm afterwards
sudo service network-manager restart

# check log contents
sudo cat /var/log/syslog

```

### diagnosing dhcpcd connections

```
# check the interface config
cat /etc/network/interfaces
# look for hooks used
ls -l /lib/dhcpcd/dhcpcd-hooks/
# see what wireless settings are
cat /etc/wpa_supplicant/wpa_supplicant.conf

# check some statuses
cat /proc/net/dev
cat /proc/net/route
cat /proc/net/arp
cat /proc/net/wireless

# diagnosing issues (including hotplugging)
ip link show
ip address
# after making changes see...
# check log contents
sudo cat /var/log/syslog

# check service
systemctl status dhcpcd.service 
systemctl cat dhcpcd.service
# and config
cat /etc/dhcpcd.conf 

# check leases
cat /var/lib/dhcp/dhclient.*.leases
tail -vn +1 /var/lib/dhcpcd5/*

# to disable specific interface(s)
# echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf
# sudo service dhcpcd restart


# Check name resolution
cat /etc/resolv.conf
# check where this links to
ls -l /etc/resolv.conf
# check other possible files
cat /run/resolvconf/resolv.conf 
cat /run/systemd/resolve/resolv.conf 
cat /etc/systemd/resolved.conf 

# and systemd resolved if used
systemd-resolve --status
# check the order of name resolution
cat /etc/nsswitch.conf
# show per interface resolution config
tail -vn +1 /run/resolvconf/interface/*


# test name resolution
dig google.com
nslookup -debug google.com
nslookup -debug google.com 8.8.8.8

# if you want to try restarting
sudo systemctl restart systemd-resolved.service

```


### diagnosing wireless connection issues

#### Wifi (WLAN)

##### Issues Connecting

```
# iwconfig # deprecated in favour of iw
iw dev

ip address

```

##### Limited Bandwidth 

```
# credit [https://www.cyberciti.biz/tips/linux-find-out-wireless-network-speed-signal-strength.html]
watch -n 1 cat /proc/net/wireless
```

see also:
* iperf below
* **wavemon** cli utility
* [https://wiki.archlinux.org/index.php/Wireless_network_configuration#Troubleshooting]

#### WWAN (Mobile Broadband)

If it does not connect up automatically, try using 
Network Manager to Edit Connections then Add 
to create a new "Mobile Broadband" Connection 
```
# list connections#
nmcli c
# bring one of them up by name
nmcli c up "Connection Name"
# or by uuid
nmcli c up uuid aaaaaaa-bbbb-cccc-dddddddd
# credit http://askubuntu.com/a/451964

##### using wvdial...


##### check modem manager
# list modems
mmcli -L
# using last number in path from list, view settings
mmcli -m 9
# using bearer number returned, check details
nmcli -b 22



```

see generic information [https://wiki.archlinux.org/index.php/USB_3G_Modem]

Search also for device specifics (e.g. [https://wiki.archlinux.org/index.php/Huawei_E220] )
or for network specifics (e.g. the {now defunct} [https://www.howtoforge.com/vodafone_mobile_connect_card_driver_linux] )

Ater the basic diagnostics above...
```
ls -l /dev/ttyUSB*
```

### diagnosing ethernet connection issues

```
ip link show
# credit http://serverfault.com/q/15776

grep "" /sys/class/net/enp6s0/*
# http://stackoverflow.com/a/808599

sudo apt-get install ethtool
ethtool enp6s0

```

## Names and Addresses

```
# If you are not sure what your name and address stack is using
# see what packages are installed
dpkg -l | grep "dns\|dhcp\|unbou\|network-ma"
# check which services are enabled
systemctl list-unit-files
```

### DHCP addressing

#### All interfaces

```
# list of interfaces
nmcli dev

# details of each interface
nmcli dev show

# the next two commands look better on a wider console
# display the interfaces available
ip link show

# show the amount of traffic that has passed through each interface
cat /proc/net/dev

# check if an IP address is assigned to your interface
ip addr
# ifconfig # works but is deprecated in favour of ip addr

# see if the interface has any manually assigned parameters
cat /etc/network/interfaces

# display details of lease(s) obtained
cat /var/lib/dhcp/dhclient.leases
# cat /var/lib/dhcp/dhclient.*.leases


# /var/lib/dh* 
# no longer seems to hold anything useful

# dhclient
# doesn't do much on its own - see 
```

#### Renew DHCP address

```
# when renewing DHCP, try purging locally cached lease file
sudo dhclient -r -v && sudo rm /var/lib/dhcp/dhclient.* ; sudo dhclient -v
# credit - http://askubuntu.com/a/431385
# if you're still having issues, check the lease has been removed from the DHCP server too
```

#### Specific interface

```
INTERFACE=eth0

# display current settings
nmcli dev show $INTERFACE
# nmcli dev list iface $INTERFACE - old syntax
# ifconfig $INTERFACE - deprecated
```

### DNS Resolution

#### local (Network Manager)

```
# By default, since around 12.04, NetworkManager has relied on a local DNS cache provided by
# dnsmasq running on localhost, which passes requests out when the host is not cached.
# credit - http://askubuntu.com/a/368935
# help - https://help.ubuntu.com/community/Dnsmasq
# FAQ - http://thekelleys.org.uk/dnsmasq/docs/FAQ

# Check the configuration
cat /etc/NetworkManager/NetworkManager.conf
# if you update this config (e.g. comment out dns=dnsmasq) then you need to restart nm afterwards
sudo restart network-manager
# To see this running check
dig -x 127.0.0.1
# and note the response comes from ;; SERVER: 127.0.1.1#53

# check the (dynamically generated) resolver settings
cat /run/resolvconf/resolv.conf 
# check the order of name resolution
cat /etc/nsswitch.conf
# help - http://manpages.ubuntu.com/manpages/wily/man5/nsswitch.conf.5.html

# check what DNS server is set on your network interface(s)
nmcli dev show | grep DNS
```

#### dnsmasq

```
# if your Network Manager conf (see above) uses dnsmasq then ...

# flush dns cache
/etc/init.d/dnsmasq restart
# is this a generic alternative? - sudo /etc/init.d/dns-clean    (  add option:    start    ??)

# temporarily switch name server by killing and hardcoding during restart
killall dnsmasq
dnsmasq --server=192.168.2.1
# credit - http://askubuntu.com/a/682058
```

#### browser dns cache

```
# ?? chrome://net-internals/#dns  - Clear Host Cache

# firefox - either restart browser
# or use DNS Flusher addon - https://addons.mozilla.org/en-us/firefox/addon/dns-flusher/

#### resolving

# Advanced options for attempting to resolve names

HOST_NAME=host.domain.tld

# verbose host output
host -v $HOST_NAME

nslookup -debug $HOST_NAME

# "domain information groper" from dnsutils (included by default in Lubuntu?)
dig $HOST_NAME
# use @a.b.c.d before other parameters to specify dns server
# help - http://manpages.ubuntu.com/manpages/trusty/man1/dig.1.html
# examples - http://www.tecmint.com/10-linux-dig-domain-information-groper-commands-to-query-dns/
```

#### network DNS

If you are having issues on your local network where the local DNS server 
(or the locally 'recommended' server from your ISP) is failing to resolve 

```
# compare your own name response with google
nslookup domain.tld

nslookup domain.tld 8.8.8.8

# and more info from dig
dig domain.tld

dig @8.8.8.8 domain.tld

```

##### choosing alternate DNS providers

use **namebench** or *DNS benchmark* utilities to identify optimal 



## Discovery

### Services

Browse a list of local services advertising themselves as being available to you
```
# CLI
sudo apt-get install -y avahi-utils
avahi-browse -a

# GUI
sudo apt-get install -y avahi-discover
avahi-discover
```

The Avahi (Bonjour/Zeroconf) service can broadcast names across your network, using Multicast DNS (mDNS). Unfortunately some routers can block these multicast packets, so the first thing to make sure is that you really are on the same network. If you are trying to resolve to a wired device, plug in a wire - if your remote device is on wifi, then go wireless too.

For more on ''Name Resolution'' see ''Networked Services'' page.

### Topology Map 

How to build up an idea of your network topology and devices

Even when hosts are not explicitly advertising their services for autodiscovery, you may be able to identify hosts and services using the following order of steps.

* ping sweep 
** follow up with reverse DNS lookup
** ARP check after the scan 
* TCP SYN scan
* full port scan

The first step is the simplest, quickest and least aggressive, but may not work on some networks. As you work down this list, although you are more likely to get results, each option becomes more time consuming, and importantly such actions can be considered signs of aggression. On a securely managed network, you, the discoverer, may find yourself being "discovered" by administrators, and potentially even banned!

If you choose to try such steps then one of the most popular and fully functioned tools is '''nmap''' and it's handy GUI '''zenmap'''. On the other hand, if you own the network, and want to discover who is doing this kind of scan, then '''Wireshark''' is a good starting point as a traffic analyser :)

#### nmap CLI 

```
sudo apt-get install -y nmap

SUBNET_SPEC=192.168.1.0/24

# quick ping scan showing hostnames, computer type and latency
sudo nmap -sn $SUBNET_SPEC

# basic reverse DNS lookup (no root)
nmap -sL $SUBNET_SPEC

# TCP SYN connection to 1000 of the most common ports
nmap $SUBNET_SPEC

# scan for ALL ports (using TCP SYN and UDP)
sudo nmap -sS -sU -PN -p 1-65535 $SUBNET_SPEC

# credit - http://bencane.com/2013/02/25/10-nmap-commands-every-sysadmin-should-know/
```

#### zenmap GUI 

 sudo apt-get install -y zenmap
 sudo zenmap

You may find this [beginners guide](https://www.linux.com/learn/tutorials/381794-audit-your-network-with-zenmap) useful

Other pictorial tools include:

* [cheops-ng tool](http://cheops-ng.sourceforge.net/index.php)
    * # old software, package no longer in repos - sudo apt-get install cheops-ng
* [OpenNMS server(s)](http://www.opennms.org/about/)
* [SpiceWorks IT-ad-supported free tools](http://www.spiceworks.com/free-network-mapping-software/)
* 

## Performance 

### ISP Diagnostics 

```
# browser based using an HTML5 (flash-free) server...
x-www-browser http://speedof.me

# bandwidth measurement from terminal
speedtest-cli
# install instructions?

#### MTU
# have you checked your MTU is set to ISP recommended (e.g. 1492 instead of Auto)


#### old Network download speed tests ####

# quite a close sever for browser-based testing
x-www-browser http://speedtest.uk.net/
 
# the fastest ubuntu mirror seems to be kent for the moment
wget 'http://www.mirrorservice.org/sites/cdimage.ubuntu.com/cdimage/lubuntu/releases/13.10/release/lubuntu-13.10-desktop-amd64.iso' -O /dev/null
# 400-500KB/s is reasonable over wifi, 1MB/s is possible over ethernet
# or try germany...
wget 'http://mirror.skylink-datacenter.de/ubuntu-releases/13.10/ubuntu-13.10-desktop-amd64.iso' -O /dev/null
```


### Internal bandwidth tests 

```
# to set up network performance tests
sudo apt-get install iperf
# server: iperf -s
# client: iperf -c <hostname or ip> (options)
# e.g. iperf -c myIperfSvr -i 1 -t 100  # report every second for 100 seconds
# Android clients include: ???
# install as daemon:
# sudo iperf -s -D > ??? tee

#### Interface issues?

# Latest NIC drivers? Correct drivers for card?
# does dmesg show errors?

# Duplex
sudo /sbin/ethtool eth0
sudo /sbin/ethtool -s eth0 full
sudo /sbin/ethtool -s eth0 half
# http://askubuntu.com/questions/277805/why-does-my-internet-speed-roughly-double-when-switching-from-ubuntu-to-win-xp

# Wifi power management 
sudo iwconfig wlan0 power off 
```

### What's using my bandwidth ? 

These are linux utilities to display network traffic per process per remote host...

Candidates:
* iftop (see cli options)
* nethogs
* lsof -i
* netactview (GUI)

Sources:
* http://serverfault.com/questions/248223/how-do-i-know-what-processes-are-using-the-network
* http://www.reddit.com/r/linux/comments/r1v5x/is_there_an_app_in_linux_that_shows_perprocess/
* http://how-to.wikia.com/wiki/How_to_monitor_network_traffic_on_a_Linux_or_Unix_like_OS

