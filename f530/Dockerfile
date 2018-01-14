# ARTIK 530 Fedora
#
# To set up the "fed-artik-build" tool, you need two steps:
#  fed-artik-host-init-buildsys and fed-artik-init-buildsys.
#
# The first step is to extract the rootfs file and create a configuration file.
# It is already included in the image build process("docker build ..."). And
# the second step is to set the chroot environment, which takes a lot of time
# to perform system updates and so on. However, it was not included in the
# image build process because it requires "--privileged" option when using the
# "mount --bind ..." command. This option is only available in the
# "docker run ..." phase.
#
# To deploy an image with all steps, use the steps below.
# $ docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-office/f530 -t artik_devenv_f530_base
# $ docker run --cidfile /tmp/f530-base.cid --privileged artik_devenv_f530_base fed-artik-init-buildsys
# $ dl=`cat /tmp/f530-base.cid`
# $ docker commit --change='CMD ["zsh"]' $dl artik_devenv_f530
#
# Upgrade chroot environment to latest.
# $ docker run --cidfile /tmp/f530-base.cid -it --privileged artik_devenv_f530
# ➜  ~ fed-artik-chroot
# Disable sslverify option of fedora
# [root@e8f619fb9ef8 /]# dnf update
# [root@e8f619fb9ef8 /]# exit
# ➜  ~ exit
# $ dl=`cat /tmp/f530-base.cid`
# $ docker commit --change='CMD ["zsh"]' $dl artik_devenv_f530
#
# Now, you can create a container using "artik_devenv_f530" image.
# $ docker run -it --privileged artik_devenv_f530

FROM webispy/artik_devenv
LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="ARTIK Development environment for ARTIK 530 Fedora"

ENV ROOTFS=fedora-arm-artik530-rootfs-0530GC0F-44F-01Q4-20170425.192021-1e007ebbf12d9c7499be3a4b9e9d8e6a.tar.gz

RUN wget https://github.com/SamsungARTIK/fedora-spin-kickstarts/releases/download/release%2FA530_os_2.0.0/$ROOTFS \
		&& fed-artik-host-init-buildsys -I $ROOTFS \
		&& rm $ROOTFS

CMD ["zsh"]
