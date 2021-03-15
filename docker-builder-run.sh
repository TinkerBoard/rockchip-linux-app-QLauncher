#!/bin/bash

set -xe

if [ -x "$(command -v docker)" ]; then
    echo "Docker is installed and the execute permission is granted."
    if getent group docker | grep &>/dev/null "\b$(id -un)\b"; then
	echo "User $(id -un) is in the group docker."
    else
        echo "Docker is not managed as a non-root user."
	echo "Please refer to the following URL to manage Docker as a non-root user."
        echo "https://docs.docker.com/install/linux/linux-postinstall/"
	exit
    fi
else
    echo "Docker is not installed or the execute permission is not granted."
    echo "Please refer to the following URL to install Docker."
    echo "http://redmine.corpnet.asus/projects/configuration-management-service/wiki/Docker"
    exit
fi

if dpkg-query -s qemu-user-static 1>/dev/null 2>&1; then
    echo "The package qemu-user-static is installed."
else
    echo "The package qemu-user-static is not installed yet and it will be installed now."
    sudo apt-get install -y qemu-user-static
fi

if dpkg-query -s binfmt-support 1>/dev/null 2>&1; then
    echo "The package binfmt-support is installed."
else
    echo "The package binfmt-support is not installed yet and it will be installed now."
    sudo apt-get install -y binfmt-support
fi

DIRECTORY_PATH_TO_DOCKER_BUILDER="$(dirname $(readlink -f $0))"
DIRECTORY_PATH_TO_SOURCE="$(dirname $DIRECTORY_PATH_TO_DOCKER_BUILDER)"

function usage
{
    echo -e "usage: $0 [[[-c command to execute] [-d directory path to the source]] | [-h]]\n"
}

while getopts 'c:d:h' opt;
do
    case $opt in
	c)
            CMD="$OPTARG"
            ;;
	d)
            DIRECTORY_PATH_TO_SOURCE="$OPTARG"
            ;;
	h|?)
            usage
            exit 1
	    ;;
    esac
done

echo "DIRECTORY_PATH_TO_DOCKER_BUILDER: $DIRECTORY_PATH_TO_DOCKER_BUILDER"
echo "The directory path to the source is set to [$DIRECTORY_PATH_TO_SOURCE]."
if [ ! -d $DIRECTORY_PATH_TO_SOURCE ]; then
    echo "The source directory [$DIRECTORY_PATH_TO_SOURCE] is not found."
    exit
fi

DOCKER_IMAGE="asus/builder:latest"
docker build --tag $DOCKER_IMAGE \
    --file $DIRECTORY_PATH_TO_DOCKER_BUILDER/Dockerfile $DIRECTORY_PATH_TO_DOCKER_BUILDER

DOCKER_OPTIONS="--interactive --privileged --rm --tty"
DOCKER_OPTIONS+=" --volume $DIRECTORY_PATH_TO_SOURCE:/source"
DOCKER_OPTIONS+=" --workdir /source"
echo "Options to run docker: $DOCKER_OPTIONS"

if [ -z ${CMD+x} ]; then
    docker run $DOCKER_OPTIONS $DOCKER_IMAGE /bin/bash -c "groupadd --gid $(id -g) $(id -g -n); \
        useradd -m -e \"\" -s /bin/bash --gid $(id -g) --uid $(id -u) $(id -u -n); \
        passwd -d $(id -u -n); \
        echo \"$(id -u -n) ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers; \
	sudo -E -u $(id -u -n) --set-home /bin/bash -i"
else
    docker run $DOCKER_OPTIONS $DOCKER_IMAGE /bin/bash -c "groupadd --gid $(id -g) $(id -g -n); \
        useradd -m -e \"\" -s /bin/bash --gid $(id -g) --uid $(id -u) $(id -u -n); \
        passwd -d $(id -u -n); \
        echo \"$(id -u -n) ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers; \
        sudo -E -u $(id -u -n) --set-home $CMD"
fi
