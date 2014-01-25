#!/bin/bash


####################################
### *** PREPARE REPOSITORIES *** ###
####################################

# backup software sources
sudo cp /etc/apt/sources.list{,.`date +%y%m%d`}
# Add partner
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
# help > https://help.ubuntu.com/community/Repositories/CommandLine

# Prepare for repository installs
sudo apt-get update



###################################
### *** REMOVE BUNDLED APPS *** ###
###################################

### Clean up OS install

sudo apt-get remove -y unity-lens-shopping  # prevent purchasable items appearing in software list
# credit > http://www.omgubuntu.co.uk/2012/10/10-things-to-do-after-installing-ubuntu-12-10

sudo apt-get remove -y abiword		# remove abiword to avoid doc corruption issues
# sudo apt-get remove -y abiword abiword-common
## or will this do it all?
# sudo apt-get autoremove



######################################
### *** *** *** BASICS *** *** *** ###
######################################

# including some proprietary (non-libre) packages
# pre-answer the accept EULA to avoid the install waiting
sudo sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"
# credit > http://askubuntu.com/questions/16225/how-can-i-accept-microsoft-eula-agreement-for-ttf-mscorefonts-installer
sudo apt-get install `echo ${DESKTOP_SESSION,}`-restricted-extras -y
# help > https://help.ubuntu.com/community/RestrictedFormats


####################################
### *** *** APPLICATIONS *** *** ###
####################################

# Supersedes list in HTML doc section - Applications - General Apps

#! / bin / bash
cat > ./package_list <<EOF

######## ALL MACHINES ############

# MultiMedia
gstreamer		
# none-open formats incl DVDs - also needs post install code below
# might be part of other media player like totem
pulseaudio	
# should be in by default
pavucontrol	
# pulse volume control
# AUDIO usually works fine out of the box unless you want to use Bluetooth Audio Sink

flashplugin-installer	
# Adobe Flash plugin for browsers - alternatives are swfdec-gnome or gnash
cups-pdf		
# PDF printer


######## LAPTOPS ############
guvcview		
# support for most webcams
skype
# back in the repos since 13.10 - no longer need manual script


########### KIDS #############
# for more ideas see...
# https://wiki.ubuntu.com/Edubuntu/AppGuide

# infants
childsplay gcompris tuxpaint kwordquiz ri-li

# practice
tuxtype ktouch tuxmath gbrainy kig kalgebra

# programming
basic256 laby kturtle

# geo-astro
celestia stellarium kstars marble kgeography

#play

aisleriot airstrike glchess glines gnect gnibbles gnobots2 gnome-sudoku
gnomine gnotravex gtali iagno gnotski fraqtive khangman solfege

# the following do not seem to be included with 12.04
# gnome-mahjongg

# the following do not seem to be included with 11.04
# klotski
# lightsoff
# quadrapassel
# swell-foop

################# EITHER #################

libreoffice		
# office - prefer to replace abiword - should we remove gnumeric too?

# notes
vym

# Dropbox - manual, see other script

# advanced
gimp
inkscape
dia-gnome
scribus

### Alternative music players ###

# on lubuntu default player is Audacious
# Audacious works but not great interface for finding tracks in big library
#
# consider alternative like:
#
# LXMusic might be too simple as well
# Banshee does it out of the box
# VLC might be getting into album art browsing
# Clementine has strong fan base
# Musique is lightweight and QT-based
# did YaRock continue developing?
# Rhythmbox is commonly used
## Cover Art is still a Third party plug in:
### sudo add-apt-repository ppa:fossfreedom/rhythmbox-plugins
### sudo apt-get update && sudo apt-get install rhythmbox-plugin-coverart-browser
## can preset library using gsettings set org/gnome/rhythmbox/rhythmdb locations or similar
## https://help.ubuntu.com/community/Rhythmbox#Multiple_Library_Directories



############## TECH STUFF ################

meld					
# file and folder diffs...
#  alternatives: xxdiff - also kdiff3 (floss) + diffMerge (free) are Win/Nux
# http://askubuntu.com/questions/312604/how-do-i-install-xxdiff-in-13-04 

geany					
# syntax highlighting editor
# alternatives: gedit (ubuntu default), sublime text??,  xemacs21 (no app menu shortcut), vim (_really_?), gVim?

epiphany-browser	
# alternative lightweight browser
transmission			
# torrent client

gftp					
# file transfer client

pandoc				
# convert documents between markup formats 
# sample command 
# pandoc -f markdown -t html -o output.htm input.txt

calibre					
# convert docs to AZW kindle format for USB download

python					
# code execution

# decompression
# for ubuntu, p7zip for 7z format (fits into fileroller)
# or for xubuntu, xarchiver (includes p7zip)

### Other Candidates
# jockey-gtk
# hardware drivers 

### Busines Apps
# gnucash

### Utilities
# vlc vlc-plugin-esd mozilla-plugin-vlc
# txt2tags


# WSYIWYG html editor - kompozer no longer in repos
# see > https://help.ubuntu.com/community/InstallKompozer 
# alternatives: http://www.bluegriffon.org/ although not in repos
# What about Amaya?
# Is BlueFish visual? Aptana is more web dev

EOF

while read -r line; do [[ $line = \#* ]] && continue; sudo apt-get install -y $line; done < package_list
# while read -r line; do [[ $line = \#* ]] && continue; echo -e "$line"; done < package_list
# credit > http://mywiki.wooledge.org/BashFAQ/001

# not sure why this one fails

# cat package_list | xargs -r -d # sudo apt-get install 


################################
### *** Post App Install *** ###
################################


### Allow 
# play dvds
sudo /usr/share/doc/libdvdread4/install-css.sh 


########################################
### *** *** *** DEFAULTS *** *** *** ###
########################################

# Update-Alternatives

# x-www-browser /bin/firefox

#######################################
### *** *** *** CLEANUP *** *** *** ###
#######################################

# after all applications are installed and/or upgraded, consider clean up using...
# sudo apt-get autoremove -y


