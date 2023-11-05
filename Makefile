SHELL := /bin/bash

user :
	useradd -m -g users -G audio,wheel noseferatu && passwd noseferatu; \
	EDITOR=nvim visudo; \
	su noseferatu; \
	rm -rf ~/arch

init :
	sudo pacman -Syu --noconfirm && sudo pacman -Syy --noconfirm

# install openntpd for time sync
base :
	sudo pacman -S --noconfirm zsh tmux git; \
	chsh -s $$(which zsh) $$USER 

# TODO: wayland
display :
	sudo pacman -S --noconfirm \
	xorg-server xorg-xinit xorg-xrandr picom

utils :
	sudo pacman -S --noconfirm \
	stow openssh fzf ripgrep cmake inetutils man tldr \
	ansible entr tokei xclip magic-wormhole neofetch

# audio, app-launcher, file-manager, notification, screenshot, DE
# remember to set default sink
interfaces :
	sudo pacman -S --noconfirm \
	pipewire-alsa pipewire-jack pipewire-pulse wireplumber qjackctl \
	dmenu nitrogen lf dunst flameshot btop; \
	sudo make -C /root/arch/st clean install; \
	sudo make -C /root/arch/dwm clean install; \
	sudo make -C /root/arch/slstatus clean install

zsh :
	curl -s https://ohmyposh.dev/install.sh | bash -s; \
	curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

tmux :
	git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm

slack :
	sudo pacman -R slack-desktop; \
	git clone https://aur.archlinux.org/slack-desktop.git ~/slack; \
	cd ~/slack; \
	makepkg -si; \
	rm -rf ~/slack

# TODO: hack nerd font
fonts :
	sudo pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji

nerdctl :
	sudo pacman -S --noconfirm containerd runc; \
	mkdir -p /home/noseferatu/nerdctl; \
	mkdir -p /opt/cni/bin; \
	curl -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz -o /home/noseferatu/nerdctl/cni.tar.gz; \
	curl -L https://github.com/moby/buildkit/releases/download/v0.11.5/buildkit-v0.11.5.linux-amd64.tar.gz -o /home/noseferatu/nerdctl/buildkit.tar.gz; \
	curl -L https://github.com/containerd/nerdctl/releases/download/v1.2.1/nerdctl-1.2.1-linux-amd64.tar.gz -o /home/noseferatu/nerdctl/nerdctl.tar.gz; \
	sudo tar -C /usr/local/bin -xzf /home/noseferatu/nerdctl/nerdctl.tar.gz; \
	sudo tar -C /opt/cni/bin -xzf /home/noseferatu/nerdctl/cni.tar.gz; \
	sudo tar -C /usr/local -xzf /home/noseferatu/nerdctl/buildkit.tar.gz; \
	sudo curl -L https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/system/buildkit.socket -o /lib/systemd/system/buildkit.socket; \
	sudo curl -L https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/system/buildkit.service -o /lib/systemd/system/buildkit.service; \
	sudo systemctl enable containerd; \
	sudo systemctl enable buildkit; \
	sudo systemctl start containerd; \
	sudo systemctl start buildkit; \
	rm -rf /home/noseferatu/nerdctl

# use vlc for video player
# use remmina for remote display
apps :
	sudo pacman -S --noconfirm obsidian discord spotify-launcher vivaldi

ansible :
	read -s -p "password:" pass; \
	echo $$pass > ~/pass; \
	ansible-pull -U https://github.com/NoseferatuWKF/ansible.git --ask-become-pass --vault-pass-file ~/pass -t 'arch, secrets, post' playbooks/arch.yml; \
	rm ~/pass

arch : init base

chad : display interfaces fonts utils zsh tmux nerdctl apps ansible

.PHONY: init base display interfaces utils zsh tmux nerdctl apps slack ansible config arch chad

