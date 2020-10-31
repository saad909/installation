#Wifi setup
wifiSetup(){
	while :
	do
		printf "Want to connect to wifi(y/n):"
		read selection
		if [[ $selection == 'y' || $selection == 'Y' ]]
		then
			echo "Connect your wifi in this fashion"
			echo "station "
			iwctl
			return

		elif [[ $selection == 'n' || $selection == 'N' ]]
		then
			return
		else
			echo "Please enter the valid option!"
			continue
		fi
	done
	return
}

# Partition starts here

#variables
#root=0
#swap=0
#efi=0
#ehd=0
#home=0

getMountPoints(){

	#get parititions numbers in variables
	clear
	lsblk
	printf "efi: "
	read efi
	efi="/dev/sda""$efi"

	printf "root: "
	read root
	root="/dev/sda""$root"

	printf "swap: "
	read swap
	swap="/dev/sda""$swap"

	printf "home: "
	read home
	home="/dev/sda""$home"

	printf "External HDD: "
	read ehd

	printf "Your Selection is

			efi			=	$efi
			root                    =	$root
			swap			=	$swap
			home			=	$home
			External HDD		=	$ehd
	"
	while :
	do
		printf "Do want to change mount points(y/n): "
		read change
		if [[ $change == 'y' || $change == 'Y' ]]
		then
			getMountPoints
		elif [[ $change == 'n' || $change == 'N' ]]
		then
			return
		else
			echo "Please enter a valid choice"
			continue

		fi
	done
 
}

createPart(){
	clear 
	printf "Create your partitions carefully!.\nPress enter to continue"
	read hold
	cfdisk
	lsblk
	while :
	do
		printf "Want to paritition again(y/n): "
		read change
		if [[ $change == 'y' || $change == 'Y' ]]
		then
			createPart
		elif [[ $change == 'n' || $change == 'N' ]]
		then
			return
		else
			echo "Please enter a valid choice"
			continue

		fi
	done
}


partition(){
	#Want Paritioning
	while :
	do
		printf "Want Partioning(y/n):"
		read selection

		#Dont want to parition
		if [[ $selection == 'n' || $selection == 'N' ]]
		then
			getMountPoints
			return


		#Want to parition
		elif [[ $selection == 'y' || $selection == 'Y' ]]
		then
			createPart
			getMountPoints
			return
		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done

}
simpleFormat(){
	
	#Repartition if some paritition is not given

	#efi
	[ -z $efi ] && printf "No efi Partition!\nReparition again" && partition; mkfs.fat -F32 $efi

	#root
	[ -z $root ] && printf "No root Partition!\nReparition again" && partition; mkfs.ext4 $root -f

	#swap
	while :
	do
		printf "Want swap(y/n): "
		read selection

		# Don't have a swap partition
		if [[ $selection == 'n' || $selection == 'N' ]]
		then
			break

		# Format a swap partition
		elif [[ $selection == 'y' || $selection == 'Y' ]]
		then
			[ -z $swap ] && printf "No swap Partition!\nReparition again" && partition; mkswap $swap && swapon $swap
			break

		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done



	#home
	while :
	do
		printf "Want to format home partition(y/n): "
		read selection

		# Don't format home partition
		if [[ $selection == 'n' || $selection == 'N' ]]
		then
			break

		# Format home partition
		elif [[ $selection == 'y' || $selection == 'Y' ]]
		then
			[ -z $home ] && printf "No home Partition!\nReparition again" && partition; mkfs.ext4 $home -f
			return

		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done


}
btrfsFormat(){
	
	pacman -S btrfs-progs  --noconfirm
	#Repartition if some paritition is not given

	#efi
	[ -z $efi ] && printf "No efi Partition!\nReparition again" && partition; mkfs.fat -F32 $efi

	#root
	[ -z $root ] && printf "No root Partition!\nReparition again" && partition; mkfs.btrfs $root -f

	#swap
	while :
	do
		printf "Want swap(y/n): "
		read selection

		# Don't have a swap partition
		if [[ $selection == 'n' || $selection == 'N' ]]
		then
			break

		# Format a swap partition
		elif [[ $selection == 'y' || $selection == 'Y' ]]
		then
			[ -z $swap ] && printf "No swap Partition!\nReparition again" && partition; mkswap $swap && swapon $swap
			break

		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done



	#home
	while :
	do
		printf "Want to format home partition(y/n): "
		read selection

		# Don't format home partition
		if [[ $selection == 'n' || $selection == 'N' ]]
		then
			break

		# Format home partition
		elif [[ $selection == 'y' || $selection == 'Y' ]]
		then
			[ -z $home ] && printf "No home Partition!\nReparition again" && partition; mkfs.btrfs $home -f
			return

		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done



}

format(){
	while :
	do
		printf "Want btrfs(y/n): "
		read btrfs

		#Simple Format
		if [[ $btrfs == 'n' || $btrfs == 'N' ]]
		then
			simpleFormat
			return


		# Btrfs Formatting
		elif [[ $btrfs == 'y' || $btrfs == 'Y' ]]
		then
			btrfsFormat
			return
		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done
	
}
chkEHDD(){

	while :
	do
		printf "External HDD is not mounted.Want to mount it(y/n): "
		read selection

		#Dont mount
		if [[ $selection == 'n' || $selection == 'N' ]]
		then
			return

		#Mount it
		elif [[ $selection == 'y' || $selection == 'Y' ]]
		then
			clear
			lsblk
			printf "External HDD mount point: "
			read ehd
			return
		#Invalid input for paritioning
		else
			printf "Please enter the correct option!\n"
			continue

		fi
	done
	
}

baseInstall(){

	pacman -S reflector  --noconfirm && reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
	if [[ $btrfs == 'n' || $btrfs == 'N' ]]
	then
		mount $root /mnt
		pacstrap /mnt base base-devel linux linux-firmware
		mkdir -p /mnt/boot/efi;mount $efi /mnt/boot/efi
		[ ! -z $home ] && mount $home /mnt/home && (mkdir -p /mnt/home/ExternalHDD ; [ ! -z $ehd ] && mount $ehd /mnt/home/ExternalHDD)

	# Base install to btrfs filesystem
	elif [[ $btrfs == 'y' || $btrfs == 'Y' ]]
	then
		#root
		mount $root /mnt
		btrfs su cr /mnt/@
		umount /mnt
		mount -o noatime,compress=lzo,space_cache,subvol=@ $root /mnt/
		#install base
		pacstrap /mnt base base-devel linux linux-firmware  
		#mount efi
		mount $efi /mnt/boot/efi
		mkdir -p { /mnt/boot/efi,/mnt/home }
		#mount home if exits
		[ ! -z $home ] && mount $home /mnt/home && btrfs su cr /mnt/home/@home ; umount /mnt/home && mount -o noatime,compress=lzo,space_cache,subvol=@home $home /mnt/home && (mkdir -p /mnt/home/ExternalHDD ; [ ! -z $ehd ] && mount $ehd /mnt/home/ExternalHDD)
		#create subvolumes var and snapshots and mount them to /var and /.snapshots respectively
		btrfs su cr /mnt/@var
		btrfs su cr /mnt/@snapshots
		mkdir /mnt/.snapshots ; mount -o noatime,compress=lzo,space_cache,subvol=@var $root /mnt/.snapshots 
		mkdir /mnt/var; mount -o noatime,compress=lzo,space_cache,subvol=@snapshots $root /mnt/var
	fi
}


echo "1.Wifi Setup"
wifiSetup

echo "2.Partitioning"
partition

echo "3.Formatting"
format

echo "4.Check External HDD is mounted"
[ -z $ehd ] && chkEHDD

echo "5.Base Install"
baseInstall

echo "6.Generate fstab"
genfstab -U /mnt > /mnt/etc/fstab
#change fstab for proper mounting external hdd
[ ! -z $ehd ] && pacman -S ntfs-3g --noconfirm && echo "Edit fstab for ExternalHDD" && read hold && printf "Press enter to continue" && vim /mnt/etc/fstab

echo "7.Set timezone"
hwclock --systohc
timedatectl set-timezone Asia/Karachi

echo "8.hostname"
printf "Computer Name: "
read hostname
echo "$hostname" > /mnt/etc/hostname

echo "9.loopback"
echo "
127.0.0.127	xml.cisco.com
127.0.0.1	localhost
127.0.0.1	$hostname
::1		localhost
" >> /mnt/etc/hosts

echo "10.Generate locale"
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo  "11.Install network utilities,sudo and grub"
arch-chroot /mnt pacman -S networkmanager dhcpcd sudo grub efibootmgr os-prober net-tools wireless_tools zsh --noconfirm
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable NetworkManager

echo "12.Changing root password"
echo "Enter root Password"
arch-chroot /mnt passwd

command="arch-chroot /mnt "

echo "13.create a user"
printf "username: "
read username
useradd -mG wheel  $username
echo "
${username} ALL=(ALL) ALL
" |  tee -a /etc/ers
echo "set password"
passwd $username

echo "13.Installing grub"
echo "Base install complete"
# Installing Grub
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=Arch --efi-directory=/boot/efi
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "Rebooting" && sleep 5
reboot

