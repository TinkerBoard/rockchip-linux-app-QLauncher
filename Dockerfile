FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y apt-utils
RUN apt-get install -y build-essential bc python libssl-dev kmod sudo wget \
    qemu-user-static cpio time expect tzdata unzip rsync parted udev gdisk \
    git python3 zip

RUN wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/ubuntu-build-service/packages/debootstrap_1.0.87_all.deb
RUN wget https://github.com/rockchip-linux/rk-rootfs-build/raw/master/ubuntu-build-service/packages/live-build_3.0.5-1linaro1_all.deb
RUN wget http://launchpadlibrarian.net/343927385/device-tree-compiler_1.4.5-3_amd64.deb
RUN dpkg -i debootstrap_1.0.87_all.deb live-build_3.0.5-1linaro1_all.deb device-tree-compiler_1.4.5-3_amd64.deb
RUN apt-get install -f -y
RUN rm debootstrap_1.0.87_all.deb live-build_3.0.5-1linaro1_all.deb device-tree-compiler_1.4.5-3_amd64.deb
