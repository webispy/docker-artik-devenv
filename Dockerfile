FROM ubuntu:latest
ENV http_proxy http://12.26.226.2:8080
ENV https_proxy http://12.26.226.2:8080

RUN apt update && apt install -y sudo sed

RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/' /etc/apt/sources.list

RUN apt update

# Development environment
#RUN apt install -y qemu-user-static build-essential cmake git kpartx \
#	gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
#	gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
#	libguestfs-tools doxygen chrpath

# Fedora development environment
#RUN apt install -y rpm createrepo

# Debian development environment
#RUN apt install -y debhelper

# Network utility
RUN apt install -y iputils-ping net-tools

# Terminal
RUN apt install -y xterm
#RUN apt install -y terminator

# Fonts
#RUN apt install -y xfonts-terminus

RUN  mkdir -p /home/work && \
     echo "work:x:1000:1000:Developer,,,:/home/work:/bin/bash" >> /etc/passwd && \
     echo "work:x:1000:" >> /etc/group && \
     echo "work ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/work && \
     chmod 0440 /etc/sudoers.d/work && \
     chown work:work -R /home/work && \
     chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

USER work
ENV HOME /home/work
WORKDIR /home/work

