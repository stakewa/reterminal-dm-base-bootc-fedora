# Creating your own image

This repository publishes a Fedora bootc base image for the reTerminal-DM.
It is meant to be used as a starting point for a custom image which will work on the reTerminal-DM.

**You do not need to fork this repository.** Simply create your own image based on our published base image.

## Prerequisites

Before you begin, make sure you have:

- **Podman** installed on your system
- **Basic knowledge of bootc/Containerfiles**
- **An empty directory** to work in (for your custom image)

## Quick Start

### Step 1: Create a Containerfile

In your empty directory, create a file named `Containerfile` with the following content:

```dockerfile
FROM ghcr.io/stakewa/reterminal-dm-base-bootc-fedora:latest

# Your customizations go here

RUN bootc container lint
```

### Step 2: Add your customizations

Modify the Containerfile to add your custom changes between the `FROM` statement and `RUN bootc container lint`.

**Examples of customizations:**

- Adding users (note: no user is created by default)
- Installing SSH keys
- Installing additional packages
- Configuring services

### Step 3: Build your image

Run the following command in the directory containing your Containerfile:

```bash
# Replace <image-reference> with your desired image name
# Example: podman build -t ghcr.io/stakewa/my-custom-image:latest .
podman build -t <image-reference> .
```

**Done!** You've successfully built your custom container image.

> **Note:** It is recommended to build your custom image with the same image reference/tag that you plan to use
> long-term. The image
> reference is embedded into the disk image and used for over-the-air updates.

---

## Optional: Creating a disk image

If you need to deploy your custom image to the reTerminal-DM hardware, you'll need to create a disk image with the
proper boot files for the Raspberry Pi.

The Raspberry Pi requires specific boot files in the VFAT boot partition that are not automatically included in the VFAT
partition. We provide a script to handle this automatically.

> **Note:** This isn't the only way to create a disk image for the device, a few other options are also mentioned at the
> bottom [provisioning](./PROVISIONING.md) document.

### How to create a disk image

1. Locate the build script: `building/scripts/build-disk-image.sh` (in this repository)
2. Copy this script to your working directory
3. Run the script with your custom image reference

```bash
./build-disk-image.sh --tag <image-reference>
```

This will create a disk image
using [image-builder](https://osbuild.org/docs/developer-guide/projects/image-builder/usage/#bootc) with the Raspberry
Pi boot files automatically placed in the correct location.

4. Flash the created disk image to your reTerminal-DM using a flashing tool you prefer, for
   example [Raspberry Pi Imager](https://www.raspberrypi.org/software/).

---

## Optional: Setting up over-the-air (OTA) updates

To enable your reTerminal-DM to update automatically or on-demand, you need to configure the OTA update mechanism.

### What you need to know

- Your custom image must be pushed to a remote container registry (such as GitHub Container Registry, Docker Hub, etc.)
- The image reference used when building the Containerfile is the one that will be used for updates
- For more information, refer to the [bootc upgrade documentation](https://bootc.dev/bootc/bootc-upgrades.7.html)
- By default, OTA updates are enabled. But you will likely want to modify when they are
  run. [Fedora Bootc Auto-Updates](https://docs.fedoraproject.org/en-US/bootc/auto-updates/)

### Workflow for OTA updates

1. Build your image with a registry reference: `podman build -t ghcr.io/your-username/my-custom-image:latest .`
2. Push to your registry: `podman push ghcr.io/your-username/my-custom-image:latest`
3. Deploy the disk image created from this reference
4. Your reTerminal-DM can now update by pulling new versions from the registry

### Boot partition updates

Files in the boot partition aren’t updated automatically by OTA image updates. If you need to update the boot files on
your
reTerminal-DM, you can use the [update-boot-efi.sh](../image/filetree/usr/libexec/reTerminal-DM/update-boot-efi.sh)
script included in the base image. Use this script with care: a power outage during the update may leave the device
unable to boot.
> **Note:** Please read the script carefully before using it. as it can be dangerous if not used correctly.

---

## Image tag reference

### `ghcr.io/stakewa/reterminal-dm-base-bootc-fedora:latest`

- This is the recommended image for normal use on a physical device.
- It is the latest stable and tested image.
- Releases may be slower because the image is tested on actual hardware before it is published.

### `ghcr.io/stakewa/reterminal-dm-base-bootc-fedora:unstable`

- This image is generated automatically every week or whenever there are changes to the base image on the `master`
  branch.
- It is untested and not recommended for normal device use.
- Use this tag only if you want to follow the latest image changes quickly, and you are comfortable with breakage.

## Choosing between the two tags

| Tag         | Intended use                                       | Stability         |
|-------------|----------------------------------------------------|-------------------|
| `:latest`   | Normal device use, staging, and tested deployments | Stable and tested |
| `:unstable` | Early validation, not recommended for normal use   | Untested          |

## Testing images

### `ghcr.io/stakewa/reterminal-dm-base-bootc-fedora-testing:latest`

- This image is generated automatically whenever a new `reterminal-dm-base-bootc-fedora:unstable` image gets created.
- It is intended to test new images and changes before they are included in the stable release.
- Generated for testing purposes only.

## Notes

- Avoid upgrading the kernel in your image, as this might/will break the drivers. Running dnf upgrade without excluding
  the kernel package (s) will have this effect.
