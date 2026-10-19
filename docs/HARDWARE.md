# Image Hardware Support Overview

The following table lists the hardware tested with this image and provides links to additional information below.
For more information about the hardware, read the [official website](https://wiki.seeedstudio.com/reterminal-dm/).

This image was made specifically for the reTerminal-DM without a camera or other modules, so those features were not
tested.

Support status:

- **Yes** - Supported and tested
- **Partial** - Partially supported or has known limitations
- **No** - Disabled or removed from the image
- **Untested** - May work, but has not been tested

| Hardware              | Supported | Notes                                           |
|-----------------------|-----------|-------------------------------------------------|
| Display               | Yes       | [Display](#display)                             |
| Touchscreen           | Yes       | [Touchscreen](#touchscreen)                     |
| Digital I/O           | Yes       | [Digital I/O](#digital-io)                      |
| RS-232                | Yes       | [Serial interfaces](#rs232)                     |
| Light sensor          | Yes       | [Light sensor](#light-sensor)                   |
| User LED              | Yes       | [User LED](#user-led)                           |
| Buzzer                | Yes       | [Buzzer](#buzzer)                               |
| Ethernet              | Yes       | [Ethernet](#ethernet)                           |
| USB                   | Yes       | [USB](#usb)                                     |
| HDMI output           | Yes       | [HDMI output](#hdmi-output)                     |
| Audio and microphones | Untested  | [Audio and microphones](#audio-and-microphones) |
| Real-time clock       | Untested  | [Real-time clock](#real-time-clock)             |
| RS-485                | Untested  |                                                 |
| Accelerometer         | Untested  |                                                 |
| CAN bus               | Untested  |                                                 |

## Notes

### Compute Module

- System-on-module: Raspberry Pi Compute Module 4
- Processor: Broadcom BCM2711
- Architecture: arm64 (aarch64)

### Display

- Type: 10.1-inch IPS LCD
- Interface: MIPI DSI
- Resolution: 1280x800 native landscape
- Brightness: ~400 nits
- Driver: ili9881 ([ili9881d](../image/drivers/ili9881d)) modified version
  of [mainline panel-ilitek-ili9881c](https://github.com/torvalds/linux/blob/master/drivers/gpu/drm/panel/panel-ilitek-ili9881c.c)
- Note: May not always start on soft reboot. (Should be fixed
  with [reterminal-dm-rebind-dsi.service](../image/filetree/etc/systemd/system/reterminal-dm-rebind-dsi.service))

### Touchscreen

- Controller: Goodix GT9271
- Linux driver: `Goodix-TS` (built in)
- Device: `/dev/input/event*`
- Notes:
    - Requires udev rule for correct calibration
    - Requires i2c to be enabled in config.txt

### Digital I/O

- GPIO Expander: NXP PCA9535
- Interface: I2C1
- Address: `0x21`
- Function: Provides additional GPIO lines for onboard peripherals
- Note: In the upstream dts, an interrupt set for GPIO 6 (connected to PCA9535 INT pin). This has been removed due to
  incompatibility when using GPIO 6 as output (DO4)

| Name | CM4 Signal |
|------|------------|
| DI1  | GPIO 16    | 
| DI2  | GPIO 17    | 
| DI3  | GPIO 22    | 
| DI4  | GPIO 23    |
| DO1  | GPIO 24    | 
| DO2  | GPIO 25    | 
| DO3  | GPIO 26    | 
| DO4  | GPIO 6     |

### RS232

- Driver: cdc_amc (built in, as opposed
  to [WCH CH34x](https://github.com/Seeed-Studio/seeed-linux-dtoverlays/blob/master/modules/ch34x/ch343.h) or the
  upstream [WCH CH343](https://github.com/WCHSoftGroup/ch343ser_linux) driver)
- Linux device: `/dev/ttyACM0`
- Device naming may change depending on connected USB devices

### Light Sensor

The ambient light level is available through the IIO interface:

```bash
cat /sys/bus/iio/devices/iio:device0/in_illuminance_input
```

### User LED

The user LED can be controlled with:

```bash
echo 1 > /sys/class/leds/usr-led/brightness
echo 0 > /sys/class/leds/usr-led/brightness
```

### Buzzer

The onboard buzzer can be controlled with:

```bash
echo 1 > /sys/class/leds/usr-buzzer/brightness
sleep 0.2
echo 0 > /sys/class/leds/usr-buzzer/brightness
```

### Ethernet

- Interface: Gigabit Ethernet
- Connector: RJ45

### USB

- Standard ports: USB Type-A
- Interface: USB 2.0
- Note: In order for the keyboard to be available in U-Boot/Grub `dtoverlay=dwc2,dr_mode=host` needs to be added to the
  config.txt instead of `otg_mode=1`.

### HDMI Output

- Interface: HDMI 2.0
- Notes:
    - HDMI is enabled with hotplugging for troubleshooting.
    - The DSI Display is not available during U-Boot or Grub, HDMI is the only way to access U-Boot or Grub.
    - When HDMI is connected the DSI display may rotate.

### Audio and Microphones

- HDMI audio works, Audio Jack / Microphone untested

### Real-Time Clock

- RTC: NXP PCF8563W
- Function: Maintains wall-clock time when the system is powered off
- Note: Still prone to drift, device should use NTP as main source of truth

Change hardware clock to system clock

```bash
sudo hwclock --systohc
```

Change system clock to hardware clock

```bash
sudo hwclock --hctosys
```

View current hardware clock

```bash
sudo hwclock -r
```