#!/bin/bash -ex

if [ $# -ne 2 ]; then
	echo "Usage: $0 CATEGORY ARCH"
	echo "$0 ubuntu16.04_gui arm64"
	echo "$0 ubuntu16.04_gui armhf"
	echo "$0 ubuntu16.04_terminal arm64"
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
sudo tar -xpf ubuntu-common-${CATEGORY}-${ARCH}-*.tar.gz -C $TARGET_ROOTFS_DIR


# 在这里添加操作

# 启动以太网
sudo cp -rf overlay-norco/etc/network/interfaces.d/eth0 $TARGET_ROOTFS_DIR/etc/network/interfaces.d/eth0

# 主机名 域名
sudo cp -rf overlay-norco/etc/hostname $TARGET_ROOTFS_DIR/etc/hostname
sudo cp -rf overlay-norco/etc/hosts $TARGET_ROOTFS_DIR/etc/hosts

# 启动脚本
sudo cp -rf overlay-norco/etc/rc.local $TARGET_ROOTFS_DIR/etc/rc.local
sudo cp -rf overlay-norco/etc/norco.sh $TARGET_ROOTFS_DIR/etc/norco.sh
sudo cp -rf overlay-norco/etc/profile.d/norco.sh $TARGET_ROOTFS_DIR/etc/profile.d/norco.sh

# root用户在串口终端自动登录
sudo cp -rf overlay-norco/lib/systemd/system/serial-getty@.service $TARGET_ROOTFS_DIR/lib/systemd/system/serial-getty@.service

echo $CATEGORY | grep -q "gui" && {
	# root用户在桌面自动登录
	sudo cp -rf overlay-norco/etc/lightdm/lightdm.conf $TARGET_ROOTFS_DIR/etc/lightdm/lightdm.conf
	# 避免root用户无法进入桌面 
	sudo cp -rf overlay-norco/root/.profile $TARGET_ROOTFS_DIR/root/.profile
	# 关闭自动休眠
	sudo cp -rf overlay-norco/etc/xset.sh $TARGET_ROOTFS_DIR/etc/xset.sh
	# 关闭双屏显示
	sudo cp -rf overlay-norco/etc/xrandr.sh $TARGET_ROOTFS_DIR/etc/xrandr.sh
}

echo $CATEGORY | grep -q "terminal" && {
	# root用户在vt终端自动登录
	sudo cp -rf overlay-norco/lib/systemd/system/getty@.service $TARGET_ROOTFS_DIR/lib/systemd/system/getty@.service
	# 关闭自动休眠
	sudo cp -rf overlay-norco/etc/bash.bashrc $TARGET_ROOTFS_DIR/etc/bash.bashrc
}

# ATE支持
#sudo mkdir -p $TARGET_ROOTFS_DIR/data/
#sudo mkdir -p $TARGET_ROOTFS_DIR/data/ate/
#sudo cp -rf overlay-norco/data/ate/client_common $TARGET_ROOTFS_DIR/data/ate/client_common
#sudo cp -rf overlay-norco/etc/ate.sh $TARGET_ROOTFS_DIR/etc/ate.sh

# 4G模块启动脚本 mcu_init_arm程序
sudo cp -rf overlay-norco/etc/ec20.sh $TARGET_ROOTFS_DIR/etc/ec20.sh
# 修改wifi和以太网网卡名称
sudo cp -rf overlay-norco/etc/udev/rules.d/70-persistent-net.rules $TARGET_ROOTFS_DIR/etc/udev/rules.d/70-persistent-net.rules
if [ $ARCH == armhf ]; then
	sudo cp -rf overlay-norco/usr/bin/quectel-CM $TARGET_ROOTFS_DIR/usr/bin/quectel-CM
	sudo chmod a+x $TARGET_ROOTFS_DIR/usr/bin/quectel-CM
	sudo cp -rf overlay-norco/usr/bin/atsha204_client $TARGET_ROOTFS_DIR/usr/bin/atsha204_client
	sudo chmod a+x $TARGET_ROOTFS_DIR/usr/bin/atsha204_client
	sudo cp -R overlay-norco/etc/norco $TARGET_ROOTFS_DIR/etc/
fi


echo -e "\033[36m Change root.....................\033[0m"
finish() {
	./ch-mount.sh -u $TARGET_ROOTFS_DIR/
	exit 2
}
trap finish ERR

./ch-mount.sh -m $TARGET_ROOTFS_DIR/

cat <<EOF | sudo chroot $TARGET_ROOTFS_DIR

apt-get clean

EOF

./ch-mount.sh -u $TARGET_ROOTFS_DIR/


