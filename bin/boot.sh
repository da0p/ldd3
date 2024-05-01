#!/bin/bash

KERNEL="5.15.157"
MACHINE="x86_64"
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
export LDD_ROOT="$(cd "${SCRIPTDIR}"/../../kernels/ && pwd)"
export ROOTFS_DIR="$(cd "${SCRIPTDIR}"/../../rootfs/ && pwd)"
export QEMU_DIR=$(cd "${SCRIPTDIR}"/../../qemu-9.0.0/ && pwd)

QEMU_BIN="${QEMU_DIR}/build/qemu-system-${MACHINE}"

INITRAMFS="${ROOTFS_DIR}/initramfs.cpio.gz"

if [ ! -e "$INITRAMFS" ]; then
  echo "Could not locate initramfs.cpio.gz."
  exit 1
fi

KERNELPATHA="${LDD_ROOT}/linux-${KERNEL}/arch/x86_64/boot/bzImage"
if [ ! -e "${KERNELPATHA}" ]; then
  KERNELPATHB="${LDD_ROOT}/kernel/linux-${KERNEL}/arch/x86_64/boot/bzImage"
  if [ ! -e "${KERNELPATHB}" ]; then
    echo "Could not locate bzImage file in linux kernel in ${KERNELPATHA} and ${KERNELPATHB}."
    exit 1
  else
    KERNELPATH="${KERNELPATHB}"
  fi
else
  KERNELPATH="${KERNELPATHA}"
fi


${QEMU_BIN} \
    -enable-kvm \
    -kernel "$KERNELPATH" \
    -initrd "$INITRAMFS" \
    -append 'console=ttyS0' \
    -nographic \
    -net nic,model=e1000 \
    -net user,hostfwd=tcp::7023-:23 \
#    -vnc none \
    -m 512M \
    -device isa-kmod-edu,chardev=pr1 \
    -chardev file,id=pr1,path=/tmp/isa_edu \
    -device pci-kmod-edu \
    -device qemu-xhci \
    -device usb-kmod-edu \
    -device edu

