SHELL := /bin/bash

user-% :
	useradd -m -g users -G audio,wheel $* && passwd $*; \
	EDITOR=nvim visudo; \
	su $*; \
	rm -rf ~/arch

init :
	sudo pacman -Syu --noconfirm && sudo pacman -Syy --noconfirm

# zsh is installing to /sbin nowadays for some reason?
base :
	sudo pacman -S --noconfirm zsh tmux; \
	chsh -s $$(which zsh | sudo tee -a /etc/shells) $$USER 

ntpd :
	sudo pacman -S --noconfirm openntpd; \
	sudo systemctl enable openntpd.service; \
	sudo systemctl start openntpd.service: \
	timedatectl set-ntp true

# TODO: wayland
display :
	sudo pacman -S --noconfirm \
	xorg-server xorg-xinit xorg-xrandr picom; \
	sudo make -C /root/arch/st clean install; \
	sudo make -C /root/arch/dwm clean install; \
	sudo make -C /root/arch/slstatus clean install

utils :
	sudo pacman -S --noconfirm \
	stow openssh fzf ripgrep cmake inetutils man tldr \
	ansible entr tokei xclip magic-wormhole neofetch btop

cargo :
	sudo pacman -S --noconfirm cargo; \
	cargo install --locked yazi-fm git-delta

# remember to set default sink
interfaces :
	sudo pacman -S --noconfirm \
	pipewire-alsa pipewire-jack pipewire-pulse wireplumber qjackctl \
	dmenu nitrogen dunst flameshot

zsh :
	sudo pacman -S --noconfirm unzip; \
	curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin; \
	curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

tmux :
	git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm

# TODO: hack nerd font
fonts :
	sudo pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji

nerdctl :
	sudo pacman -S --noconfirm containerd runc; \
	mkdir -p /home/$$USER/nerdctl; \
	sudo mkdir -p /opt/cni/bin; \
	curl -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz -o /home/$$USER/nerdctl/cni.tar.gz; \
	curl -L https://github.com/moby/buildkit/releases/download/v0.11.5/buildkit-v0.11.5.linux-amd64.tar.gz -o /home/$$USER/nerdctl/buildkit.tar.gz; \
	curl -L https://github.com/containerd/nerdctl/releases/download/v1.2.1/nerdctl-1.2.1-linux-amd64.tar.gz -o /home/$$USER/nerdctl/nerdctl.tar.gz; \
	sudo tar -C /usr/local/bin -xzf /home/$$USER/nerdctl/nerdctl.tar.gz; \
	sudo tar -C /opt/cni/bin -xzf /home/$$USER/nerdctl/cni.tar.gz; \
	sudo tar -C /usr/local -xzf /home/$$USER/nerdctl/buildkit.tar.gz; \
	sudo curl -L https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/system/buildkit.socket -o /lib/systemd/system/buildkit.socket; \
	sudo curl -L https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/system/buildkit.service -o /lib/systemd/system/buildkit.service; \
	sudo systemctl enable containerd; \
	sudo systemctl enable buildkit; \
	sudo systemctl start containerd; \
	sudo systemctl start buildkit; \
	rm -rf /home/$$USER/nerdctl

# vlc for video player
# remmina for remote display
apps :
	sudo pacman -S --noconfirm obsidian discord spotify-launcher vivaldi

ansible-% :
	read -s -p "password:" pass; \
	echo $$pass > ~/pass; \
	ansible-pull -U https://github.com/NoseferatuWKF/ansible.git --ask-become-pass --vault-pass-file ~/pass -t '$*, secrets, post' playbooks/arch.yml; \
	rm ~/pass

arch : init base

chad : ntpd display utils cargo interfaces fonts zsh tmux nerdctl apps ansible-arch

wsl : utils cargo zsh tmux ansible-wsl

.PHONY: init base ntpd display utils cargo interfaces zsh tmux fonts nerdctl apps arch chad wsl
