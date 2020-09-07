FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

# Install required packages for building Tinker Board (S) Debian
RUN apt-get update && \
    apt-get install -y git gcc-arm-linux-gnueabihf u-boot-tools \
    device-tree-compiler mtools parted libudev-dev libusb-1.0-0-dev libssl-dev \
    autotools-dev libsigsegv2 m4 libdrm-dev curl sed make binutils \
    build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip \
    rsync file bc wget libncurses5 libglib2.0-dev openssh-client time

# Install additional packages
# kmod: depmod is required by "make modules_install"
RUN apt-get install -y kmod expect

# Install required packages for building Tinker Board (S) base Debian system
RUN apt-get install -y binfmt-support qemu-user-static apt-utils dosfstools \
    python-dbus python-debian python-parted python-yaml sudo
RUN wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/ubuntu-build-service/packages/debootstrap_1.0.87_all.deb
RUN wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/ubuntu-build-service/packages/linaro-image-tools_2012.12-0ubuntu1~linaro1_all.deb
RUN wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/ubuntu-build-service/packages/live-build_3.0.5-1linaro1_all.deb
RUN wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/ubuntu-build-service/packages/python-linaro-image-tools_2012.12-0ubuntu1~linaro1_all.deb
RUN wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb
RUN dpkg -i python-support_1.0.15_all.deb debootstrap_1.0.87_all.deb linaro-image-tools_2012.12-0ubuntu1~linaro1_all.deb live-build_3.0.5-1linaro1_all.deb python-linaro-image-tools_2012.12-0ubuntu1~linaro1_all.deb
RUN apt-get install -f -y
RUN rm python-support_1.0.15_all.deb debootstrap_1.0.87_all.deb linaro-image-tools_2012.12-0ubuntu1~linaro1_all.deb live-build_3.0.5-1linaro1_all.deb python-linaro-image-tools_2012.12-0ubuntu1~linaro1_all.deb

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
