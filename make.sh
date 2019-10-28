#!/bin/bash -ex


CATEGORY=ubuntu16.04_gui
ARCH=armhf

# 基于ubuntu16.04 base添加基本修改，若已构建，不再构建
if [ ! -e ubuntu-common-${CATEGORY}-${ARCH}-*.tar.gz ]; then
	./mk-rootfs-common.sh $CATEGORY $ARCH
fi

# 增加norco修改
./mk-rootfs-norco.sh $CATEGORY $ARCH


