#!/bin/sh
#
# Copyright (C) 2026 Daaf Wassenaar <contact@daaf.dev>
# License: MIT
#

IMAGE_REF=""
BLUEPRINT_PATH=""
IMAGE_OUTPUT_DIR="./output"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --tag)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                echo "Error: --tag requires an image reference" >&2
                exit 1
            fi
            IMAGE_REF="$2"
            shift 2
            ;;
        --blueprint)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                echo "Error: --blueprint requires a file path" >&2
                exit 1
            fi
            case "$2" in
                /*) BLUEPRINT_PATH="$2" ;;
                *)  BLUEPRINT_PATH="$(pwd)/$2" ;;
            esac
            shift 2
            ;;
        --output)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                echo "Error: --output requires a directory path" >&2
                exit 1
            fi
            case "$2" in
                /*) IMAGE_OUTPUT_DIR="$2" ;;
                *)  IMAGE_OUTPUT_DIR="$(pwd)/$2" ;;
            esac
            shift 2
            ;;
        *)
            echo "Usage: $0 --tag <image reference/tag> [--blueprint <file>] [--output <directory>]" >&2
            exit 1
            ;;
    esac
done

if [ -z "$IMAGE_REF" ]; then
    echo "Usage: $0 --tag <image reference/tag> [--blueprint <file>] [--output <directory>]" >&2
    exit 1
fi

if [ -n "$BLUEPRINT_PATH" ] && [ ! -f "$BLUEPRINT_PATH" ]; then
    echo "Error: blueprint file not found: $BLUEPRINT_PATH" >&2
    exit 1
fi

set -eu

echo "Working directory: $(pwd)"
echo "Container image: $IMAGE_REF"

DISK_IMAGE_NAME="disk-image.raw"
DISK_IMAGE_PATH="${IMAGE_OUTPUT_DIR}/${DISK_IMAGE_NAME}"
BOOT_FILES_DIR="/usr/lib/raspberry-pi-boot-files"

VFAT_MOUNTPOINT="$(mktemp -d /tmp/boot-vfat.XXXXXX)"
BOOT_FILES_SOURCE="$(mktemp -d /tmp/rpi-boot-files.XXXXXX)"

LOOPDEV=""
CONTAINER_ID=""

cleanup() {
    set +e

    if mountpoint -q "$VFAT_MOUNTPOINT"; then
        sudo umount "$VFAT_MOUNTPOINT"
    fi

    if [ -n "$LOOPDEV" ]; then
        sudo losetup -d "$LOOPDEV"
    fi

    if [ -n "$CONTAINER_ID" ]; then
        sudo podman rm -f "$CONTAINER_ID" >/dev/null 2>&1
    fi

    rm -rf "$BOOT_FILES_SOURCE"
    rmdir "$VFAT_MOUNTPOINT" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

mkdir -p "$IMAGE_OUTPUT_DIR"

#
# Extract Raspberry Pi boot files directly from the container image
#

echo "Creating temporary container from $IMAGE_REF..."

CONTAINER_ID="$(
    sudo podman create "$IMAGE_REF"
)"

echo "Copying $BOOT_FILES_DIR from container..."

sudo podman cp \
    "$CONTAINER_ID:$BOOT_FILES_DIR/." \
    "$BOOT_FILES_SOURCE/"

if [ -z "$(find "$BOOT_FILES_SOURCE" -mindepth 1 -print -quit)" ]; then
    echo "Error: no files found in $BOOT_FILES_DIR" >&2
    exit 1
fi

echo "Extracted boot files: $(find "$BOOT_FILES_SOURCE" -type f | wc -l) files total "


echo "Removing temporary container..."

sudo podman rm "$CONTAINER_ID" >/dev/null
CONTAINER_ID=""

echo "Creating disk image: $DISK_IMAGE_PATH..."

# Only add blueprint if provided
set --
if [ -n "$BLUEPRINT_PATH" ]; then
    set -- "$@" -v "$BLUEPRINT_PATH:/blueprint.toml:ro"
fi

sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    "$@" \
    -v "${IMAGE_OUTPUT_DIR}:/output" \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    ghcr.io/osbuild/image-builder-cli:latest \
    build \
    ${BLUEPRINT_PATH:+--blueprint ./blueprint.toml} \
    --output-dir "/output" \
    --output-name "$DISK_IMAGE_NAME" \
    --with-manifest \
    --with-sbom \
    --with-buildlog \
    --with-metrics \
    --bootc-ref "$IMAGE_REF" \
    --bootc-default-fs ext4 \
    raw

echo "$DISK_IMAGE_PATH"

if [ ! -f "$DISK_IMAGE_PATH" ]; then
    echo "Error: image was not created: $DISK_IMAGE_PATH" >&2
    exit 1
fi

#
# Attach the raw image and locate the ESP
#

echo "Attaching image: $DISK_IMAGE_PATH"

LOOPDEV="$(sudo losetup --find --show --partscan "$DISK_IMAGE_PATH")"

sudo udevadm settle

echo
echo "Partitions and filesystems detected in $DISK_IMAGE_PATH:"
sudo lsblk -o NAME,PATH,SIZE,FSTYPE,LABEL,UUID,PARTUUID,MOUNTPOINTS "$LOOPDEV"

echo
echo "Partition table:"
sudo fdisk -l "$LOOPDEV" || true

# Find the first vfat partition
VFAT_PARTITION="$(
    sudo lsblk -nrpo NAME,FSTYPE "$LOOPDEV" |
        awk '$2 == "vfat" { print $1; exit }'
)"

if [ -z "$VFAT_PARTITION" ]; then
    echo "Error: could not find a VFAT partition" >&2
    sudo lsblk -f "$LOOPDEV"
    exit 1
fi

echo "Mounting VFAT partition: $VFAT_PARTITION..."
#
# Copy the extracted boot files to the VFAT partition
#
sudo mount "$VFAT_PARTITION" "$VFAT_MOUNTPOINT"

echo "Copying Raspberry Pi boot files ($BOOT_FILES_SOURCE) to the VFAT partition..."

sudo cp -aL \
    "$BOOT_FILES_SOURCE"/. \
    "$VFAT_MOUNTPOINT"/

sync

echo "Contents of the VFAT partition:"
sudo find "$VFAT_MOUNTPOINT" -maxdepth 2 -printf '%M %p\n' | sort

echo "Image updated successfully: $DISK_IMAGE_PATH"

#
# Compress the image
#
NUM=1

while [ -f "${IMAGE_OUTPUT_DIR}/image-${NUM}.xz" ]; do
    NUM=$((NUM + 1))
done

xz -v -0 -T0 -c "$DISK_IMAGE_PATH" \
    > "${IMAGE_OUTPUT_DIR}/image-${NUM}.xz"

echo "Compressed image saved as: ${IMAGE_OUTPUT_DIR}/image-${NUM}.xz"
