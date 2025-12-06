#!/bin/bash -e

echo "[+] Building kernel in Docker container..."
docker build -t pwnkernel-build .

echo "[+] Creating temporary container..."
CONTAINER_ID=$(docker create pwnkernel-build)

echo "[+] Extracting bzImage..."
docker cp $CONTAINER_ID:/build/linux-5.4/arch/x86/boot/bzImage ./bzImage

echo "[+] Extracting vmlinux..."
docker cp $CONTAINER_ID:/build/linux-5.4/vmlinux ./vmlinux

echo "[+] Extracting filesystem..."
rm -rf ./fs
docker cp $CONTAINER_ID:/build/fs ./fs

echo "[+] Cleaning up container..."
docker rm $CONTAINER_ID

echo ""
echo "================================"
echo "[+] Build complete!"
echo "    bzImage: ./bzImage"
echo "    vmlinux: ./vmlinux"
echo "    filesystem: ./fs/"
echo "================================"
