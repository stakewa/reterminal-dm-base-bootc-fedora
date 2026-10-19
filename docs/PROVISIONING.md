# Base image provisioning

The base image is not intended to be flashed to a device directly for provisioning, you can however easily create your
own provisioning image for it, which can be flashed and is then switched to the final image (for example using bootc
switch). However, You don't need this image specifically for this, as you likely won't need much of the hardware anyway
during provisioning.

## Example provisioning flow

1. Create a simple bootc provisioning image with a systemd services which bootc switches to your final bootc image.
2. Build and flash this provisioning image.
3. Reboot the device (should now be booted into your final bootc image).
4. Apply changes required (e.g. such as adding secrets).

This lets you provision many devices from the same base image while keeping the final image and any secrets under your
own control.

## Notes

- The example above is one way of provisioning the device, there are many other ways, such as
  using [Anaconda](https://anaconda-installer.readthedocs.io/en/latest/index.html), [image-builder](https://osbuild.org/docs/developer-guide/projects/image-builder/usage/#bootc)
  or [bootc install + scripting](https://bootc.dev/bootc/bootc-installation.7.html).
- The repository switch is not currently automated in the base image itself.
