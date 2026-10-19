# Testing image

The testing image is meant to make interactive hardware checks easier.
It is intended to complement the device-specific notes in [HARDWARE.md](HARDWARE.md).

The current testing image logs in as `root` automatically and provides an interactive test script in the /scripts
directory of the
system called `interactive-testing.sh`.

## Prerequisites

- A reTerminal-DM
- A keyboard
- A modified terminal block

The terminal connector block needs to be wired in a specific way to self-test a few of the components.

[//]: # (TODO wiring diagram/image)

## Usage

1. Flash the testing image, or switch to it with bootc switch if you already have a bootc installation.
2. Boot the device.
3. Run `/bin/bash /scripts/interactive-testing.sh` from the shell.

## Notes

- The interactive script is still a work in progress.
- Keep the wiring documented above in sync with the test script once it is implemented.
