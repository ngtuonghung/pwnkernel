#!/bin/bash -e
# stop script if anything fails

echo "[+] Building kernel in Docker container..."
# build docker image and name it
docker build -t pwnkernel-build .

echo "[+] Creating temporary container..."
# make a container but don't run it yet
CONTAINER_ID=$(docker create pwnkernel-build)

echo "[+] Extracting linux-5.4 folder..."
rm -rf ./linux-5.4
# grab the kernel files from the container
docker cp $CONTAINER_ID:/build/linux-5.4 ./linux-5.4

echo "[+] Extracting filesystem..."
rm -rf ./fs
# grab the filesystem from the container
docker cp $CONTAINER_ID:/build/fs ./fs

echo "[+] Cleaning up container..."
# delete the temporary container
docker rm $CONTAINER_ID

echo ""
echo "================================"
echo "[+] Build complete!"
echo "    Kernel: ./linux-5.4/"
echo "    bzImage: ./linux-5.4/arch/x86/boot/bzImage"
echo "    vmlinux: ./linux-5.4/vmlinux"
echo "    filesystem: ./fs/"
echo "================================"
