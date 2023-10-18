#!/usr/bin/env bash

# create partitions
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart primary 512MiB -8GiB
parted /dev/nvme0n1 -- mkpart primary linux-swap -8GiB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 3 esp
mkfs.ext4 -L nixos /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
mkfs.fat -F 32 -n boot /dev/nvme0n1p3

# mount the file systems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

swapon /dev/nvme0n1p2
nixos-generate-config --root /mnt
nix-env -iA nixos.git
git clone https://github.com/startung/nixos-config /mnt/etc/nixos/startung

cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/startung/nixos-config/hosts/desktop/.