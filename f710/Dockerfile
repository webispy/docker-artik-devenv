# ARTIK 710 Fedora
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
# $ docker build --build-arg http_proxy=http://x.x.x.x:port --build-arg https_proxy=http://x.x.x.x:port docker-artik-office/f710 -t artik-office-f710-base
# $ docker run --cidfile /tmp/f710-base.cid --privileged artik-office-f710-base fed-artik-init-buildsys
# $ dl=`cat /tmp/f710-base.cid`
# $ docker commit --change='CMD ["zsh"]' $dl artik-office-f710
#
# Now, you can create a container using "artik-office-f710" image.
# $ docker run -it --privileged artik-office-f710

FROM webispy/artik_devenv
LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="ARTIK Development environment for ARTIK 710 Fedora"

ENV DEBIAN_FRONTEND noninteractive

RUN wget https://github.com/SamsungARTIK/fedora-spin-kickstarts/releases/download/release%2FA710_os_2.2.0/fedora-arm-artik710-rootfs-0710GC0F-44F-01QC-20170713.175433-f63a17cbfdaffd3385f23ea12388999a.tar.gz \
		&& fed-artik-host-init-buildsys -I fedora-arm-artik710-rootfs-0710GC0F-44F-01QC-20170713.175433-f63a17cbfdaffd3385f23ea12388999a.tar.gz \
		&& rm fedora-arm-artik710-rootfs-0710GC0F-44F-01QC-20170713.175433-f63a17cbfdaffd3385f23ea12388999a.tar.gz

CMD ["zsh"]
