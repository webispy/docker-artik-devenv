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
      version="0.1" \
      description="ARTIK Development environment"

ARG http_proxy
ARG https_proxy

ENV http_proxy=$http_proxy \
    https_proxy=$https_proxy \
    DEBIAN_FRONTEND=noninteractive \
    USER=work

# Modify apt repository to KR mirror
RUN apt-get update && apt-get install -y sed apt-utils \
		&& sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/' /etc/apt/sources.list \
		&& apt-get update && apt-get upgrade -y \
		&& apt-get install -y ca-certificates language-pack-en \
		&& locale-gen en_US.UTF-8 \
		&& dpkg-reconfigure locales
ENV LC_ALL en_US.UTF-8

# Packages
RUN apt-get install -y --no-install-recommends sudo iputils-ping net-tools \
		dnsutils wget curl git vim man zsh minicom \
		qemu-user-static build-essential cmake kpartx \
		gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
		gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
		gcc-arm-none-eabi gdb-arm-none-eabi \
		bison flex gperf libncurses5-dev zlib1g-dev gettext g++ \
		libguestfs-tools chrpath scons rpm createrepo debhelper \
		devscripts fakeroot quilt dh-autoreconf dh-systemd \
		ubuntu-dev-tools sbuild moreutils debootstrap \
		exuberant-ctags cscope \
		&& apt-get clean

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
		&& make install

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
		&& find ./ -name "*.deb" -exec sudo dpkg -i '{}' \;

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
