# IN CASE I FORGOT

## partitioning

```
cfdisk

# some examples
# /dev/sda1 - root
# /dev/sda2 - swap
# /dev/sda3 - efi

mkfs.btrfs /dev/sda1 # remember to set zstd compression and noatime in fstab
mkswap /dev/sda2
mkfs.fat -F 32 /dev/sda3

mount /dev/sda1 /mnt
swapon /dev/sda2
```

## pacstrap

```
pacstrap -K \mnt base base-devel linux linux-firmware linux-headers wpa_supplicant dhcpcd neovim git
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

nvim /etc/fstab # update realtime to noatime & compress=zstd to save ssd life

nvim /etc/locale.gen # uncomment en_US.UTF-8
locale-gen
nvim /etc/locale.conf # LANG=en_US.UTF-8
nvim /etc/vconsole.conf # KEYMAP=us

nvim /etc/hostname # arch-chad

mkinitpcio -P

passwd

pacman -S grub
grub-install --target=x86_64-efi --recheck /dev/sda
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

exit
reboot
```
