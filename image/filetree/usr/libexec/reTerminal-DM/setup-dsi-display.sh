#!/bin/bash
#
# Copyright (C) 2026 Daaf Wassenaar <contact@daaf.dev>
# License: MIT
#
# Some devices fail to initialize the display after a soft-reboot, this script forces a rebind.

set -e

# Start udevd in daemon mode
udevd -d

# Trigger udev subsystems and devices
udevadm trigger --type=subsystems --action=add
udevadm trigger --type=devices --action=add

# Wait for udev to settle
udevadm settle --timeout=30

# Re-enable the vc4 module
modprobe -r vc4
modprobe vc4
