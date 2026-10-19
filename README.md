# Fedora Bootc reTerminal-DM base image

This repository contains the Fedora bootc base image used by StaKeWa for the reTerminal-DM.
It bundles the kernel drivers and device-tree overlays required.

The resulting image contains all the files required for the hardware of the reTerminal-DM and can be used as the starting point for a custom image.

> **Note**: This repository targets the base reTerminal-DM without a camera or other add-on modules installed.
> If you use additional modules, check the [hardware documentation](docs/HARDWARE.md) for compatibility notes.

## Documentation

| Topic                           | Document                                     |
|---------------------------------|----------------------------------------------|
| Usage/Building your own image   | [docs/USAGE.md](docs/USAGE.md)               |
| Hardware support and interfaces | [docs/HARDWARE.md](docs/HARDWARE.md)         |
| Provisioning devices            | [docs/PROVISIONING.md](docs/PROVISIONING.md) |
| Testing the hardware            | [docs/TESTING.md](docs/TESTING.md)           |
| Contributing                    | [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) |

## Repository layout

The repository is split so that each part of the bootc image lifecycle stays in a predictable place:

- `image/` contains all the files for the base image.
- `building/` contains the scripts required to build a disk image.
- `testing/` contains the separate testing-image build for interactive hardware validation.
- `docs/` documentation.

## Image layout and boot files

The build flow keeps the boot files that the reTerminal-DM needs inside the image source tree and copies them to the EFI
partition after the disk image build process. The build scripts therefore act as the bridge between the boot files stored
inside the container image and the boot partition on the generated disk image.

> **Note**: An image builder doesn't know about these files, as such have to manually copy these files into the disks
> VFAT partition, as is done in [build-disk-image.sh](./building/scripts/build-disk-image.sh)

## Notes/TODOs

- Updating the EEPROM is recommended, and can be done using [RPIBOOT Recovery](https://github.com/raspberrypi/usbboot/blob/master/recovery/README.md).
- The testing scripts aren't fully complete.
