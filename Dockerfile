FROM ubuntu:18.04

ENV KERNEL_VERSION=5.4
ENV BUSYBOX_VERSION=1.32.0

# Install all build dependencies
RUN apt-get update && apt-get install -y \
    bc \
    bison \
    flex \
    libelf-dev \
    cpio \
    build-essential \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

#
# Download and extract kernel
#
RUN wget --progress=bar:force https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.gz && \
    tar xzf linux-${KERNEL_VERSION}.tar.gz && \
    rm linux-${KERNEL_VERSION}.tar.gz

#
# Configure and build kernel
#
WORKDIR /build/linux-${KERNEL_VERSION}

RUN make defconfig && \
    echo "CONFIG_NET_9P=y" >> .config && \
    echo "CONFIG_NET_9P_DEBUG=n" >> .config && \
    echo "CONFIG_9P_FS=y" >> .config && \
    echo "CONFIG_9P_FS_POSIX_ACL=y" >> .config && \
    echo "CONFIG_9P_FS_SECURITY=y" >> .config && \
    echo "CONFIG_NET_9P_VIRTIO=y" >> .config && \
    echo "CONFIG_VIRTIO_PCI=y" >> .config && \
    echo "CONFIG_VIRTIO_BLK=y" >> .config && \
    echo "CONFIG_VIRTIO_BLK_SCSI=y" >> .config && \
    echo "CONFIG_VIRTIO_NET=y" >> .config && \
    echo "CONFIG_VIRTIO_CONSOLE=y" >> .config && \
    echo "CONFIG_HW_RANDOM_VIRTIO=y" >> .config && \
    echo "CONFIG_DRM_VIRTIO_GPU=y" >> .config && \
    echo "CONFIG_VIRTIO_PCI_LEGACY=y" >> .config && \
    echo "CONFIG_VIRTIO_BALLOON=y" >> .config && \
    echo "CONFIG_VIRTIO_INPUT=y" >> .config && \
    echo "CONFIG_CRYPTO_DEV_VIRTIO=y" >> .config && \
    echo "CONFIG_BALLOON_COMPACTION=y" >> .config && \
    echo "CONFIG_PCI=y" >> .config && \
    echo "CONFIG_PCI_HOST_GENERIC=y" >> .config && \
    echo "CONFIG_GDB_SCRIPTS=y" >> .config && \
    echo "CONFIG_DEBUG_INFO=y" >> .config && \
    echo "CONFIG_DEBUG_INFO_REDUCED=n" >> .config && \
    echo "CONFIG_DEBUG_INFO_SPLIT=n" >> .config && \
    echo "CONFIG_DEBUG_FS=y" >> .config && \
    echo "CONFIG_DEBUG_INFO_DWARF4=y" >> .config && \
    echo "CONFIG_DEBUG_INFO_BTF=y" >> .config && \
    echo "CONFIG_FRAME_POINTER=y" >> .config

RUN sed -i 'N;s/WARN("missing symbol table");\n\t\treturn -1;/\n\t\treturn 0;\n\t\t\/\/ A missing symbol table is actually possible if its an empty .o file.  This can happen for thunk_64.o./g' tools/objtool/elf.c && \
    sed -i 's/unsigned long __force_order/\/\/ unsigned long __force_order/g' arch/x86/boot/compressed/pgtable_64.c

RUN make -j$(nproc) bzImage

#
# Download and build busybox
#
WORKDIR /build

RUN wget --progress=bar:force https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 && \
    tar xjf busybox-${BUSYBOX_VERSION}.tar.bz2 && \
    rm busybox-${BUSYBOX_VERSION}.tar.bz2

WORKDIR /build/busybox-${BUSYBOX_VERSION}

RUN make defconfig && \
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config && \
    make -j$(nproc) && \
    make install

#
# Build filesystem
#
WORKDIR /build

# Copy fs directory structure (will be provided via build context)
COPY fs /build/fs

RUN mkdir -p fs/bin fs/sbin fs/etc fs/proc fs/sys fs/usr/bin fs/usr/sbin fs/root fs/home/ctf && \
    cp -a busybox-${BUSYBOX_VERSION}/_install/* fs/

#
# Build kernel modules
#
COPY src /build/src

WORKDIR /build/src
RUN make

WORKDIR /build
RUN cp src/*.ko fs/

# Final outputs:
# /build/linux-5.4/arch/x86/boot/bzImage
# /build/linux-5.4/vmlinux
# /build/fs/
