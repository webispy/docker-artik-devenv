# ARTIK Development environment
# - TizenRT build and fusing
# - RPM and DEB packaging
# - Useful tools (git, zsh, vim, minicom, ...)
#
# Supported boards
# - 05x series (053, 055, ...): TizenRT
# - 5x0 series (520, 530, ...): Fedora, Ubuntu
# - 7x0 series (710, ...): Fedora, Ubuntu(arm64)
#
# Not supported boards
# - 020 (Bluetooth): use the Simplicity Studio (Silicon Labs)
# - 030 (Zigbee/Thread): use the Simplicity Studio (Silicon Labs)
#
# Manual image build
# $ git clone https://github.com/webispy/docker-artik-devenv
# $ docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-devenv -t artik_devenv
# $ docker run -it -v /dev/bus/usb:/dev/bus/usb -v ~/.ssh:/home/work/.ssh --privileged artik_devenv
#

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.5" \
      description="ARTIK Development environment"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=work \
    LC_ALL=en_US.UTF-8 \
    LANG=$LC_ALL

# Modify apt repository to KR mirror
RUN apt-get update && apt-get install -y ca-certificates language-pack-en \
		&& locale-gen $LC_ALL \
		&& dpkg-reconfigure locales \
		&& apt-get install -y --no-install-recommends \
		apt-utils \
		binfmt-support \
		bison \
		build-essential \
		chrpath \
		cmake \
		cpio \
		createrepo \
		cscope \
		curl \
		debianutils \
		debhelper \
		debootstrap \
		devscripts \
		dh-autoreconf dh-systemd \
		diffstat \
		dnsutils \
		exuberant-ctags \
		elfutils \
		fakeroot \
		flex \
		g++ \
		gawk \
		gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
		gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
		gcc-arm-none-eabi \
		gdb-arm-none-eabi \
		gettext \
		git \
		gperf \
		iputils-ping \
		kpartx \
		libncurses5-dev \
		libguestfs-tools \
		libsdl1.2-dev \
		man \
		minicom \
		moreutils \
		net-tools \
		pkg-config \
		python3-pip \
		python3-pexpect \
		qemu-user-static \
		quilt \
		rpm \
		sbuild \
		schroot \
		scons \
		sed \
		socat \
		sudo \
		ubuntu-dev-tools \
		unzip \
		texinfo \
		vim \
		wget \
		xterm \
		xz-utils \
		zlib1g-dev \
		zsh \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# Apply custom certificate
COPY certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

# '$USER' user configuration
# - sudo permission
# - Add user to dialout group to use COM ports
# - Add user to sbuild group to use DEB packaging
RUN useradd -ms /bin/bash $USER \
		&& echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
		&& chmod 0440 /etc/sudoers.d/$USER \
		&& echo 'Defaults env_keep="http_proxy https_proxy ftp_proxy no_proxy"' >> /etc/sudoers \
		&& adduser $USER dialout \
		&& adduser $USER sbuild

# kconfig for TizenRT
RUN wget http://ymorin.is-a-geek.org/download/kconfig-frontends/kconfig-frontends-4.11.0.1.tar.bz2 \
		&& tar xvf kconfig-frontends-4.11.0.1.tar.bz2 \
		&& cd kconfig-frontends-4.11.0.1 \
		&& ./configure --prefix=/usr --enable-mconf --disable-gconf --disable-qconf \
		&& make \
		&& make install \
		&& rm -rf /kconfig-frontends-4.11.0.1*

# --- USER -------------------------------------------------------------------

# ZSH & oh-my-zsh
RUN chsh -s /bin/zsh $USER
USER $USER
ENV HOME /home/$USER
WORKDIR /home/$USER
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
		&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
		&& echo "DISABLE_AUTO_UPDATE=true" >> ~/.zshrc

# fed-artik-tools for RPM packaging
# - https://github.com/SamsungARTIK/fed-artik-tools
RUN git clone https://github.com/SamsungARTIK/fed-artik-tools.git tools/fed-artik-tools \
		&& cd tools/fed-artik-tools \
		&& debuild -us -uc \
		&& sudo dpkg -i ../*.deb \
		&& cd \
		&& rm -rf tools

# Sbuild for DEB packaging
# - https://github.com/SamsungARTIK/ubuntu-build-service
# - https://wiki.debian.org/sbuild
#
# * Sbuild in docker issue
#   Sbuild internally has logic to mount using overlayfs or aufs, which fails
#   for files in the docker. To use sbuild, you must add the following option
#   when running the 'docker run' command.
#
#     -v /var/lib/schroot
#
#   Declare /var/lib/schroot as a docker volume. This is internally recognized
#   to ext4, so there is no problem with sbuild's overlay and aufs.
#
COPY sbuild/.sbuildrc sbuild/.mk-sbuild.rc /home/$USER/
RUN mkdir -p ubuntu/scratch && mkdir -p ubuntu/build && mkdir -p ubuntu/logs \
		&& echo "/home/$USER/ubuntu/scratch    /scratch    none    rw,bind    0    0" | sudo tee -a /etc/schroot/sbuild/fstab \
		&& sudo chown $USER.$USER .sbuildrc && sudo chown $USER.$USER .mk-sbuild.rc

# sbuild tmpfs setup to speed-up
COPY sbuild/04tmpfs /etc/schroot/setup.d/
RUN sudo chmod 755 /etc/schroot/setup.d/04tmpfs \
		&& echo "none /var/lib/schroot/union/overlay tmpfs uid=root,gid=root,mode=0750 0 0" | sudo tee -a /etc/fstab

# vundle
COPY vim/.vimrc /home/$USER/
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
		&& vim +PluginInstall +qall \
		&& sudo chown $USER.$USER .vimrc

CMD ["zsh"]
