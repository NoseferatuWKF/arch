SHELL := /bin/bash

user : 
	useradd -m -g users -G audio,wheel noseferatu && passwd noseferatu; \
	EDITOR=nvim visudo; \
	su noseferatu; \
	rm -rf ~/arch

init :
	sudo pacman -Syu --noconfirm && sudo pacman -Syy --noconfirm

base :
	sudo pacman -S --noconfirm zsh tmux git; \
	chsh -s $$(which zsh) $$USER 

wayland :
	sudo pacman -S --noconfirm xorg-server wayland xorg-xwayland xorg-xinit xorg-xrandr

utils :
	sudo pacman -S --noconfirm stow openssh fzf ripgrep cmake inetutils man ansible rsync entr flameshot xclip

interfaces :
	sudo pacman -S --noconfirm alsa-utils pipewire-alsa wireplumber dmenu nitrogen lf dunst; \
	sudo make -C /root/arch/st clean install; \
	sudo make -C /root/arch/dwm clean install; \
	sudo make -C /root/arch/slstatus clean install

zsh :
	curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

tmux :
	git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm

google-chrome :
	git clone https://aur.archlinux.org/google-chrome.git ~/google-chrome; \
	cd ~/google-chrome; \
	makepkg -si; \
	rm -rf ~/google-chrome

apps :
	sudo pacman -S --noconfirm obsidian discord; \

ansible :
	read -s -p "password:" pass; \
	echo $$pass > ~/pass; \
	ansible-pull -U https://github.com/NoseferatuWKF/ansible.git --become-pass-file ~/pass --vault-pass-file ~/pass -t 'secrets, repo, post'; \
	rm ~/pass

config :
	cd ~/.dotfiles; \
	stow --adopt -v zsh tmux nvim git dunst nitrogen pipewire; \
	git restore .

arch : init base

chad : wayland interfaces utils tmux google-chrome apps ansible config

