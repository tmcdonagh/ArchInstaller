#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwlock --systohc
sed -i "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
locale-gen
echo echo again?
read echoans
if [ $echoans == y ]
then
  echo LANG=en_US.UTF-8 > /etc/locale.conf
fi
while : ; do
hostname=$(dialog --inputbox "What do you want your hostname to be?"  10 25 --output-fd 1)
dialog \
  --yesno "Is $hostname correct?" 10 30 
if [ $? == 0 ]
  then
    break
  fi
done

echo do hostname again?
read hostnameansw
if [ $hostnameansw == y ]
then
  echo $hostname > /etc/hostname
fi
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
  --yesno "Add user to list of sudoers?" 10 30
if [ $? == 0 ]
then
  echo "$username ALL=(ALL) ALL" > /etc/sudoers
fi
done
dialog \
  --yesno "Do you need intel drivers?" 10 30
if [ $? == 0 ]
then
  pacman -S intel-ucode mesa 
fi
dialog \
  --yesno "Do you need nvidia drivers?" 10 30
if [ $? == 0 ]
then
  pacman -S nvidia 
fi
dialog \
  --checklist "Packages" 20 75 5 \
              "Xfce4" "Lightweight DE of Choice" off \
              "Xfce4 Goodies" "Extras for Xfce4" off \
              "i3" "Popular Window Manager" off \
              "Steam" "Gaming Storefront" \
              "Defaults" "All programs I would find necessary" \
              2> packageList.txt
packageArray=( "Xfce4" "Xfce4 Goodies" "i3" "Steam" "Defaults" )
for package in ${array[@]}
do
  if grep -q $package tempfile.txt
  then
    # if statements for whether or not it is what package
  fi
done


if [ $? == 0 ]
then

