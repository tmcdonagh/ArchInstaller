#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
backtitle="Muh Arch Installer"
title="Installation"
dialog \
  --backtitle "$backtitle" \
  --title "$title" \
  --yesno "\nStart Installer?" 10 30
if [ $? ==  0 ]
then
  dialog \
    --backtitle "$backtitle" \
    --title "$title" \
    --yesno "Check internet connection?" 10 30
  if [ $? == 0 ]
  then
    ping -c 2 google.com
    dialog \
      --backtitle "$backtitle" \
      --title "$title" \
      --yesno "\nAre you connected?" 10 30
    if [ $? == 1 ]
    then
      dialog \
        --backtitle "$backtitle" \
        --title "$title" \
        --yesno "Start wifi-menu?" 10 30
      if [ $? == 0 ]
      then
        wifi-menu
      fi
    fi
  fi
  # Time ctl thingy
  timedatectl set-ntp true
  while : ; do
    fdisk -l
    echo "${bold}Type drive below with /dev/ included"
    read drive
    echo $drive
    dialog \
      --backtitle "$backtitle" \
      --title "$title" \
      --yesno "\nIs $drive correct?" 10 30
    if [ $? == 0 ]
    then
      break
    fi
  done
  cfdisk $drive

  while : ; do

    mainDrive=$(dialog --inputbox "Where is your main partition? (e.g. /dev/sda1)" 10 25 --output-fd 1)
    fs=$(dialog --inputbox "What filesystem do you want?" 10 25 --output-fd 1)
    dialog \
      --backtitle "$backtitle" \
      --title "$title" \
      --yesno "\nDo you have a swap partition?" 10 30 
    if [ $? == 0 ]
    then
      swapDrive=$(dialog --inputbox "Where is the swap partition (e.g. /dev/sda2)" 10 25 --output-fd 1)


    else
      swapDrive="None"
    fi

    dialog \
      --yesno "\nIs this correct?\nMain partition = $mainDrive\nFilesystem = $fs\nSwap = $swapDrive" 10 30
    if [ $? == 0 ]
    then
      break
    fi
  done
  mkfs.$fs $mainDrive
  if [ $swapDrive != "None" ]
  then
    mkswap $swapDrive
    swapon $swapDrive
  fi

  mount $mainDrive /mnt
  pacstrap /mnt base base-devel
  genfstab -U /mnt >> /mnt/etc/fstab
  cp part2Installer.sh /mnt/
  arch-chroot /mnt ./part2Installer.sh
else
  exit 1
fi
