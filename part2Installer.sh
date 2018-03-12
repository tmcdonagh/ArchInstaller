#!/bin/bash
pacman -S --noconfirm dialog

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwlock --systohc
sed -i "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
while : ; do
  hostname=$(dialog --inputbox "What do you want your hostname to be?"  10 25 --output-fd 1)
  dialog \
    --yesno "Is $hostname correct?" 10 30 
  if [ $? == 0 ]
  then
    break
  fi
done

echo $hostname > /etc/hostname
mkinitcpio -p linux
while : ; do
  dialog \
    --msgbox "\nInput your password for root after this screen" 10 30
  passwd
  dialog \
    --yesno "\nIs that the right password?" 10 30
  if [ $? == 0 ]
  then
    break
  fi
done
while : ; do
  dialog \
    --yesno "Do you want another user?" 10 30
  if [ $? == 1 ] 
  then
    break
  fi
  username=$(dialog --inputbox "What's the name of this user?" 10 25 --output-fd 1)
  useradd -m $username
  dialog \
    --msgbox "\nInput $username 's password after this screen" 10 30
  passwd $username
  dialog \
    --yesno "Add user to list of sudoers?" 10 30
  if [ $? == 0 ]
  then
    echo "$username ALL=(ALL) ALL" >> /etc/sudoers
  fi
  dialog \
    --yesno "Do you want to set a password?" 10 30
  if [ $? == 0 ]
  then
    dialog \
done
dialog \
  --checklist "Packages" 20 75 5 \
  "Xfce4" "Lightweight DE of Choice" off \
  "Xfce4 Goodies" "Extras for Xfce4" off \
  "i3" "Popular Window Manager" off \
  "Defaults" "All programs I would find necessary excluding those on this list" off \
  "LightDM" "Login with DE selection" off \
  2> packageList.txt
packageArray=( "Xfce4" "Xfce4 Goodies" "i3" "Defaults" "LightDM" )
for package in ${packageArray[@]}
do
  if grep -q $package packageList.txt
  then
    if [ $package == "Xfce4" ]
    then
      pacman -S --noconfirm xorg xfce4
    fi
    if [ $package == "Xfce4 Goodies" ]
    then
      pacman -S --noconfirm xfce4-goodies 
    fi
    if [ $package == "i3" ]
    then
      pacman -S --noconfirm i3 dmenu
    fi
    if [ $package == "Defaults" ]
    then
      pacman -S --noconfirm docker gparted htop mupdf network-manager-applet rhythmbox speedtest-cli tigervnc tmux gtk3 intel-ucode network-manager wpa_supplicant

    fi
    if [ $package == "LightDM" ]
    then
      pacman -S -noconfirm lightdm lightdm-gtk-greeter
      systemctl enable lightdm 
    fi
  fi
done
grubdisk=$(dialog --inputbox "Where do you want grub installed? (e.g /dev/sda not /dev/sda1" 10 25 --output-fd 1)
pacman -S --noconfirm bash-completion grub-bios os-prober

grub-install --recheck $grubdisk
grub-mkconfig -o /boot/grub/grub.cfg

exit
