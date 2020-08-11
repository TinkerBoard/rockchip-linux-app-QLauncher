FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

# Install required packages for building Tinker Board (S) Debian
RUN apt-get update && \
    apt-get install -y git gcc-arm-linux-gnueabihf u-boot-tools \
    device-tree-compiler mtools parted libudev-dev libusb-1.0-0-dev \
    python-linaro-image-tools linaro-image-tools libssl-dev autotools-dev \
    libsigsegv2 m4 libdrm-dev curl sed make binutils build-essential gcc g++ \
    bash patch gzip bzip2 perl tar cpio python unzip rsync file bc wget \
    libncurses5 libglib2.0-dev openssh-client time

# Install required packages for building Tinker Board (S) base Debian system
RUN apt-get install -y binfmt-support qemu-user-static live-build debootstrap
#RUN dpkg -i /packages/* || apt-get install -f -y

# Install additional packages
# kmod: depmod is required by "make modules_install"
RUN apt-get install -y kmod expect

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
