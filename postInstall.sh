#!/bin/bash

echo "2.Installing necessary packages"
sudo pacman -S - < packagesList.txt --noconfirm

echo "2.Change default shell"
chsh -s /bin/zsh $username

#echo "3.Installing the dotfiles"
git clone https://github.com/saad909/dots
cd dots
chmod +x install.sh
./install.sh &

echo "4.Installing yay"
git clone https://aur.archlinux.org/yay-git
cd yay-git
makepkg -si

echo "5.Installing Polybar"
yay -S polybar-git --noconfirm --needed 

echo  "installing necessary packages"
yay -S - < ./yay-necessary.txt --noconfirm
# android setup
sudo pacman -S mtpfs  gvfs-mtp gvfs-gphoto2
yay -S jmtpfs-git --noconfirm --needed

# Networking packages
while :
do
	printf "Want networking packages(y/n): "
	read selection
	if [[ $selection == 'y' || $selection == 'Y' ]]
	then
		./yayExtra &
		git clone https://github.com/saad909/scripts
		cd scripts && chmod +x *
		# Install ftp server
		"1.Ftp server"
		./ftp-arch.sh &
		"2.GNS3"
		./gns3.sh
		"3.nvim"
		bash <(curl -s https://raw.githubusercontent.com/ChristianChiarulli/nvim/master/utils/install.sh)
		return

	elif [[ $selection == 'n' || $selection == 'N' ]]
	then
		return
	else
		echo "Please enter the valid option!"
		continue
	fi
done

sudo reboot now






