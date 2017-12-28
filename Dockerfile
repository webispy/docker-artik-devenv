# ARTIK Development environment
#
# docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-office -t artik-office
# docker run -it -v /dev/bus/usb:/dev/bus/usb -v ~/.ssh:/home/work/.ssh --privileged artik-office

FROM ubuntu:xenial
LABEL maintainer="webispy@gmail.com"
LABEL version="0.1"
LABEL description="ARTIK Development environment"

ARG http_proxy
ARG https_proxy

ENV http_proxy $http_proxy
ENV https_proxy $https_proxy
ENV DEBIAN_FRONTEND noninteractive

# Modify apt repository to KR mirror
RUN apt-get update && apt-get install -y sed apt-utils
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/' /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y

# Apply custom certificate
RUN apt-get install -y ca-certificates
COPY certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Language configuration
RUN apt-get install -y language-pack-en \
		&& locale-gen en_US.UTF-8 \
		&& dpkg-reconfigure locales
ENV LC_ALL en_US.UTF-8

# Utility
RUN apt-get install -y sudo iputils-ping net-tools dnsutils \
		wget curl git vim man zsh minicom

# Development environment
RUN apt-get install -y qemu-user-static build-essential cmake kpartx \
		gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
		gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
		gcc-arm-none-eabi gdb-arm-none-eabi \
		bison flex gperf libncurses5-dev zlib1g-dev gettext g++ \
		libguestfs-tools chrpath scons

# Fedora and Debian development environment
RUN apt-get install -y rpm createrepo debhelper
RUN apt-get clean

# Add 'work' user with sudo permission
RUN useradd -ms /bin/bash work
RUN echo "work ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/work \
		&& chmod 0440 /etc/sudoers.d/work

# Add 'work' user to dialout group to use COM ports
RUN adduser work dialout

# Fix proxy environment issue on sudo command
RUN echo 'Defaults env_keep="http_proxy https_proxy ftp_proxy no_proxy"' >> /etc/sudoers

# Build & Install kconfig
RUN wget http://ymorin.is-a-geek.org/download/kconfig-frontends/kconfig-frontends-4.11.0.1.tar.bz2 \
		&& tar xvf kconfig-frontends-4.11.0.1.tar.bz2 \
		&& cd kconfig-frontends-4.11.0.1 \
		&& ./configure --prefix=/usr --enable-mconf --disable-gconf --disable-qconf \
		&& make \
		&& make install

# ZSH
RUN chsh -s /bin/zsh work
USER work
ENV HOME /home/work
WORKDIR /home/work
RUN git clone http://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
		&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

CMD ["zsh"]
