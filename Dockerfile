# ARTIK Development environment
# - TizenRT build and fusing
# - RPM and DEB packaging
# - Useful tools (git, zsh, vim, minicom, ...)
#
# Supported boards
# - 05x series (053, 055, ...): TizenRT
# - 5x0 series (520, 530, ...): Fedora, Ubuntu
# - 7x0 series (710, ...): Fedora, Ubuntu
#
# Not supported boards
# - 020 (Bluetooth): use the Simplicity Studio (Silicon Labs)
# - 030 (Zigbee/Thread): use the Simplicity Studio (Silicon Labs)
#
# docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-office -t artik-office
# docker run -it -v /dev/bus/usb:/dev/bus/usb -v ~/.ssh:/home/work/.ssh --privileged artik-office
#

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com" \
      version="0.2" \
      description="ARTIK Development environment"

ARG http_proxy
ARG https_proxy

ENV http_proxy=$http_proxy \
    https_proxy=$https_proxy \
    DEBIAN_FRONTEND=noninteractive \
    USER=work \
    LC_ALL=en_US.UTF-8 \
    LANG=$LC_ALL

# Modify apt repository to KR mirror
RUN apt-get update && apt-get install -y --no-install-recommends sed apt-utils \
		&& sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/' /etc/apt/sources.list \
		&& apt-get update \
		&& apt-get install -y ca-certificates language-pack-en \
		&& locale-gen $LC_ALL \
		&& dpkg-reconfigure locales \
		&& apt-get install -y --no-install-recommends \
		bison \
		build-essential \
		chrpath \
		cmake \
		createrepo \
		cscope \
		curl \
		debhelper \
		debootstrap \
		devscripts \
		dh-autoreconf dh-systemd \
		dnsutils \
		exuberant-ctags \
		fakeroot \
		flex \
		g++ \
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
		man \
		minicom \
		moreutils \
		net-tools \
		qemu-user-static \
		quilt \
		rpm \
		sbuild \
		scons \
		sudo \
		ubuntu-dev-tools \
		vim \
		wget \
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
RUN git clone http://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
		&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# fed-artik-tools for RPM packaging
RUN git clone https://github.com/SamsungARTIK/fed-artik-tools.git tools/fed-artik-tools \
		&& cd tools/fed-artik-tools \
		&& debuild -us -uc \
		&& sudo dpkg -i ../*.deb \
		&& cd \
		&& rm -rf tools

# sbuild
COPY sbuild/.sbuildrc sbuild/.mk-sbuild.rc /home/$USER/
RUN mkdir -p ubuntu/scratch && mkdir -p ubuntu/build && mkdir -p ubuntu/logs \
		&& echo "/home/$USER/ubuntu/scratch    /scratch    none    rw,bind    0    0" | sudo tee -a /etc/schroot/sbuild/fstab \
		&& sudo chown $USER.$USER .sbuildrc && sudo chown $USER.$USER .mk-sbuild.rc

# vundle
COPY vim/.vimrc /home/$USER/
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
		&& vim +PluginInstall +qall \
		&& sudo chown $USER.$USER .vimrc

CMD ["zsh"]
