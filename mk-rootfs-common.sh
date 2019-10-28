#!/bin/bash -ex

if [ $# -ne 2 ]; then
	echo "Usage: $0 CATEGORY ARCH"
	echo "$0 ubuntu16.04_gui armhf"
	echo "$0 ubuntu16.04_terminal armhf"
	exit 1
fi

CATEGORY=$1
ARCH=$2

TARGET_ROOTFS_DIR="binary"
if [ -d $TARGET_ROOTFS_DIR ]; then
	sudo rm -rf $TARGET_ROOTFS_DIR
fi

mkdir $TARGET_ROOTFS_DIR 
echo -e "\033[36m Extract image \033[0m"
sudo tar -xpf ubuntu-base-16.04.6-base-${ARCH}.tar.gz -C $TARGET_ROOTFS_DIR


set +e
dpkg -l | grep -q qemu-user-static
if [ $? -ne 0 ]; then
	sudo apt-get -f -y install qemu-user-static
fi
set -e

if [ x$ARCH == xarmhf ]; then
	sudo cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
else
	echo "ARCH should be armhf"
	exit 2
fi


# 准备网络
sudo cp -b /etc/resolv.conf $TARGET_ROOTFS_DIR/etc/resolv.conf

# 替换国内源，加速构建
sudo cp -b overlay-common/etc/apt/sources.list $TARGET_ROOTFS_DIR/etc/apt/sources.list

sudo bash -c "echo ${CATEGORY}-${ARCH} > $TARGET_ROOTFS_DIR/etc/version"


echo -e "\033[36m Change root.....................\033[0m"

finish() {
	./ch-mount.sh -u $TARGET_ROOTFS_DIR/
	exit 3
}
trap finish ERR

./ch-mount.sh -m $TARGET_ROOTFS_DIR/

cat <<EOF | sudo chroot $TARGET_ROOTFS_DIR

apt-get update

apt-get -y install sudo vim udev kmod usbutils net-tools ethtool wireless-tools inetutils-ping openssh-server bash-completion can-utils build-essential u-boot-tools i2c-tools wget 
apt-get -y install qt5-default
apt-get -y install autoconf automake libtool
apt-get -y install ntp ntpdate iptables traceroute resolvconf
apt-get -y install nfs-kernel-server nfs-common

cat /etc/version | grep -q gui && {
	apt-get -y install locales
	apt-get -y install tzdata
	apt-get -y install language-pack-zh-hans
	apt-get -y install language-pack-en-base
	apt-get -y install keyboard-configuration

	apt-get -y install lxde
	apt-get -y install lubuntu-default-session
}


#---------------Clean-------------- 
apt-get clean

EOF

./ch-mount.sh -u $TARGET_ROOTFS_DIR/


echo -e "\033[36m tar image \033[0m"
BUILD_TIME=`date +%Y%m%d`
sudo tar zcf ubuntu-common-${CATEGORY}-${ARCH}-${BUILD_TIME}.tar.gz -C $TARGET_ROOTFS_DIR/ .


