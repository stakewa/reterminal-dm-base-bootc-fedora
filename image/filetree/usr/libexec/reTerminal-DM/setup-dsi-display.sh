#!/bin/bash
#
# Copyright (C) 2026 Daaf Wassenaar <contact@daaf.dev>
# License: MIT
#
# Some devices fail to initialize the display after a soft-reboot, this script forces a rebind.

set -euo pipefail

dsi_connected() {
    local status
    shopt -s nullglob
    for status in /sys/class/drm/card*-DSI-1/status; do
        if grep -qx 'connected' "$status"; then
            return 0
        fi
    done
    return 1
}

if dsi_connected; then
    echo "DSI display connected, skipping vc4-drm rebind."
else
    echo "DSI display not connected, re-binding vc4-drm."
    driver=/sys/bus/platform/drivers/vc4-drm

    if [[ ! -e "$driver/gpu" ]]; then
        echo "Expected device $driver/gpu not found" >&2
        exit 1
    fi

    echo gpu > "$driver/unbind"
    sleep 1
    echo gpu > "$driver/bind"
    udevadm settle --timeout=30
fi
