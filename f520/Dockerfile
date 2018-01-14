# ARTIK 520 Fedora
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
# $ docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-office/f520 -t artik_devenv_f520_base
# $ docker run --cidfile /tmp/f520-base.cid --privileged artik_devenv_f520_base fed-artik-init-buildsys
# $ dl=`cat /tmp/f520-base.cid`
# $ docker commit --change='CMD ["zsh"]' $dl artik_devenv_f520
#
# Upgrade chroot environment to latest.
# $ docker run --cidfile /tmp/f520-base.cid -it --privileged artik_devenv_f520
# ➜  ~ fed-artik-chroot
# Disable sslverify option of fedora
# [root@e8f619fb9ef8 /]# dnf update
# [root@e8f619fb9ef8 /]# exit
# ➜  ~ exit
# $ dl=`cat /tmp/f520-base.cid`
# $ docker commit --change='CMD ["zsh"]' $dl artik_devenv_f520
#
# Now, you can create a container using "artik_devenv_f520" image.
# $ docker run -it --privileged artik_devenv_f520

FROM webispy/artik_devenv
LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="ARTIK Development environment for ARTIK 520 Fedora"

ENV ROOTFS=fedora-arm-artik5-rootfs-0520GC0F-3AF-01Q6-20160928.203457-0e632fcf9ee1badf5724751af6bd0670.tar.gz

RUN wget https://github.com/SamsungARTIK/fedora-spin-kickstarts/releases/download/release%2FA520_os_2.0.0/$ROOTFS \
		&& fed-artik-host-init-buildsys -I $ROOTFS \
		&& rm $ROOTFS

CMD ["zsh"]
