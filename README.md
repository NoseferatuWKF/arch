# IN CASE I FORGOT

## partitioning

```
cfdisk

# /dev/sda1 - root
# /dev/sda2 - swap
# /dev/sda3 - boot

mkfs.btrfs /dev/sda1 # remember to set zstd compression and noatime in fstab
mkswap /dev/sda2
mkfs.ext4 -O ^has_journal /dev/sda3 # similar with ext2 but this one is better, also use bash, zsh doesn't work here

mount /dev/sda1 /mnt
swapon /dev/sda2
```

## pacstrap

```
pacstrap -K base base-devel linux dhcpcd neovim git
```

## fstab

```
genfstab -U /mnt >> /mnt/etc/fstab
```

## going deep

```
arch-chroot /mnt

systemctl enable dhcpcd@<interface>.service # after ip link

ln -sf /usr/share/zoneinfo/<current>/<location> /etc/localtime

hwclock --systohc

nvim /etc/locale.gen # uncomment en_US.UTF-8
locale-gen
nvim /etc/locale.conf # LANG=en_US.UTF-8
nvim /etc/vconsole.conf # KEYMAP=us

nvim /etc/hostname # arch-chad

mkinitpcio -P

passwd

pacman -S grub
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# once everything is ok
exit
umount /dev/sda1
reboot
```


## arch-chad

```
pacman -Syy && pacman -Syu

git clone https://github.com/NoseferatuWKF/arch.git
make user
make arch chad

reboot
```
