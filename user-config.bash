#!/bin/bash

# options used
# $LUBUILD_HARDWARE_TYPE_EXTERNAL_SCREEN
# $LUBUILD_HARDWARE_TYPE_LAPTOP 


### Screen locking issues in 14.04 & 14.10
# do we want to force screensaver to lock, or let user config manually?
#
if \
 [[ "${DESKTOP_SESSION} $(lsb_release -sr)" == "Lubuntu 14.04" ]] \
 || [[ "${DESKTOP_SESSION} $(lsb_release -sr)" == "Lubuntu 14.10" ]] \
; then
  echo === change C-A-L lock shortcut to use light locker
  cp ~/.config/openbox/lubuntu-rc.xml{,.`date +%y%m%d.%H%M%S`}
  sed -i 's/lxsession-default lock/light-locker-command -l/' \
   ~/.config/openbox/lubuntu-rc.xml
fi

# consider changing (unconditionally) shortcut from key="C-A-l" to key="W-l"
# or at least adding in a copy (like W-p below) to use both shortcuts



### Set laptop mode ###
if [[ $LUBUILD_HARDWARE_TYPE_LAPTOP -eq TRUE ]] ; then ( 
  if \
    [[ "${DESKTOP_SESSION} $(lsb_release -sr)" == "Lubuntu 14.04" ]] \
    ; then
    # credit > http://askubuntu.com/a/361286
    cp ~/.config/lxsession/Lubuntu/desktop.conf{,.`date +%y%m%d.%H%M%S`}
    echo modify the following setting in the named section ; \
    echo [State] ; \
    echo laptop_mode=yes ; \
    sudo leafpad ~/.config/lxsession/Lubuntu/desktop.conf 
  fi
) ; fi



######### toggle external screen display using SUPER-P ###########################
#
# Lubuntu's (LXDE's) LXRandR gui allows you to set a specific configuration,
# but not toggle / cycle between alternative modes you choose to predefine
#
# try using ARandR ?
# help - http://christian.amsuess.com/tools/arandr/
# proc - http://askubuntu.com/questions/162028/how-to-use-shortcuts-to-switch-between-displays-in-lxde

# the solution below works well to toggle between two modes
# for alternative scripts that can cycle between 3 or more modes, 
# see... (in ascending order of complexity)
# http://crunchbang.org/forums/viewtopic.php?id=10182
# http://unix.stackexchange.com/a/168141
# https://gist.github.com/davidfraser/4131369
# https://awesome.naquadah.org/wiki/Using_Multiple_Screens

### MANUALLY ***** check screen IDs
# 
# Set all connected monitors to automatic (full native) resolution
xrandr -q | grep " connected " | while read first rest ; do
xrandr --output $first --auto
done

# command to identify internal and external monitors
xrandr  -q|grep connected
# e.g.
# LVDS connected 1366x768+0+0 (normal left inverted right x axis y axis) 256mm x 144mm
# HDMI-0 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 509mm x 286mm
# VGA-0 disconnected (normal left inverted right x axis y axis)

#
# ensure there are no trailing spaces after \\
#
if [[ $LUBUILD_HARDWARE_TYPE_LAPTOP -eq TRUE ] && [ $LUBUILD_HARDWARE_TYPE_EXTERNAL_SCREEN -eq TRUE ]] ; then ( 
mkdir -p ~/bin
cat <<-EOF! > ~/bin/toggle_external_monitor.sh
#!/bin/bash
# credit - http://crunchbang.org/forums/viewtopic.php?id=28846
   INTERNAL_DEVICE=LVDS \\
&& EXTERNAL_DEVICE=HDMI-0 \\
&& EXTERNAL_IN_USE="HDMI.*1920x1080+0+0" \\
&& xrandr | grep -q "\$EXTERNAL_IN_USE"  \\
&& xrandr --output \$INTERNAL_DEVICE --auto --output \$EXTERNAL_DEVICE --off \\
|| xrandr --output \$INTERNAL_DEVICE --auto --output \$EXTERNAL_DEVICE --auto
# multiway options 
# credit - http://www.thinkwiki.org/wiki/Sample_Fn-F7_script
EOF!

chmod +x ~/bin/toggle_external_monitor.sh

# insert section.....
#  <keybind key="W-p">
#    <action name="Execute">
#      <command>~/bin/toggle_external_monitor.sh</command>
#    </action>
#  </keybind>
cp ~/.config/openbox/lubuntu-rc.xml{,.`date +%y%m%d`}

cat ~/.config/openbox/lubuntu-rc.xml.`date +%y%m%d` \
| xmlstarlet ed \
 -s "/_:openbox_config/_:keyboard" \
   -t elem -n keybind  \
| xmlstarlet ed \
 -i "/_:openbox_config/_:keyboard/_:keybind[last()]" \
   -t attr -n key -v W-p \
 -s "/_:openbox_config/_:keyboard/_:keybind[last()]" \
   -t elem -n action  \
| xmlstarlet ed \
 -i "/_:openbox_config/_:keyboard/_:keybind[last()]/_:action" \
   -t attr -n name -v Execute \
 -s "/_:openbox_config/_:keyboard/_:keybind[last()]/_:action" \
   -t elem -n command  \
| xmlstarlet ed \
 -s "/_:openbox_config/_:keyboard/_:keybind[last()]/_:action/_:command" \
   -t text -n text -v "~/bin/toggle_external_monitor.sh" \
> ~/.config/openbox/lubuntu-rc.xml

openbox --reconfigure

) ; fi

# NB: If mouse pointer does not appear when you switch external monitor on then try the following:
# EITHER re-awaken X by switching consoles - CTRL-ALT-F1 then CTRL-ALT-F7 - credit https://bbs.archlinux.org/viewtopic.php?pid=648767#p648767
# OR suspend and resume
##############################################



# Laptop Lid settings - ignore lid close
if [[ $LUBUILD_HARDWARE_TYPE_LAPTOP -eq TRUE ] && [ $LUBUILD_HARDWARE_TYPE_EXTERNAL_SCREEN -eq TRUE ]] ; then ( 
# credit - http://askubuntu.com/questions/407287/change-xfce4-power-manager-option-from-terminal
# credit - http://docs.xfce.org/xfce/xfce4-power-manager/preferences
# help - http://docs.xfce.org/xfce/xfconf/xfconf-query
# help - http://git.xfce.org/xfce/xfce4-power-manager/plain/src/xfpm-xfconf.c

# if you want to check current settings
# xfconf-query -c xfce4-power-manager -l -v
# or
# cat ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml 

# No action on lid close
xfconf-query -c xfce4-power-manager -n -p "/xfce4-power-manager/lid-action-on-ac" -t int -s 0
xfconf-query -c xfce4-power-manager -n -p "/xfce4-power-manager/lid-action-on-battery" -t int -s 0
) ; fi


### The rest of this used to be in user-fixes.bash


# ====Sound controls====
# Acer One not adjusting volume with Fn VolUp and Fn VolDn keys
# credit - http://ubuntuforums.org/archive/index.php/t-1977849.html
# credit - https://bugs.launchpad.net/ubuntu/+source/lxpanel/+bug/1262572

MODEL_NO=`sudo dmidecode -s system-product-name`
AFFECTED_MODELS='|AO722|Latitude E7240|sample other|'

if [[ $AFFECTED_MODELS == *\|$MODEL_NO\|* ]] ; then
  sudo cp $HOME/.config/openbox/lubuntu-rc.xml{,.`date +%y%m%d.%H%M%S`}  # backup original config
  # find the text   XF86AudioRaiseVolume
  # after each of the three  commands   amixer -q   insert the following text before   sset
  #   -D pulse 
  sed -i -e 's|amixer -q sset|amixer -q -D pulse sset|' \
  $HOME/.config/openbox/lubuntu-rc.xml ;

  openbox --reconfigure
 
fi

# now fixed and backported 
## "lxsession-default tasks" (CTRL-ALT-DEL) kills xorg / logs user out
#  sed -i -e 's|lxsession-default tasks|lxtask|' \
#  $HOME/.config/openbox/lubuntu-rc.xml ;
#  openbox --reconfigure
## http://ubuntuforums.org/showthread.php?t=2218356
## http://askubuntu.com/questions/499036/
## https://bugs.launchpad.net/ubuntu/+source/lxsession/+bug/1316832


# no longer needed per user as it's fixed system-wide
## credit - https://bugs.launchpad.net/ubuntu/+source/pcmanfm/+bug/975152/comments/17
## still an issue in Lubuntu 14.10 (Beta 2)
#if \
#  [[ "${DESKTOP_SESSION} $(lsb_release -sr)" == "Lubuntu 14.04" ]] \
#  || [[ "${DESKTOP_SESSION} $(lsb_release -sr)" == "Lubuntu 14.10" ]] \
#  ; then
#  echo === open bash scripts in Terminal from File Manager - Lub 14.04 ;
### This would fail anyhow, as config file not created until you go into GUI preferences
#  sudo cp $HOME/.config/lxpanel/Lubuntu/config{,.`date +%y%m%d.%H%M%S`}
#  sed -i -e 's|lxsession-default terminal|x-terminal-emulator|' \
#  $HOME/.config/lxpanel/Lubuntu/config ;
#fi



### BOOKMARKS #######################
cp ~/.gtk-bookmarks{,.`date +%y%m%d`}
# Add local music folder to bookmarks
echo file:///media/lubuntu/Default/Documents%20and%20Settings/UserName/Local%20Settings/Personal/Music Music.COPY | tee -a ~/.gtk-bookmarks


