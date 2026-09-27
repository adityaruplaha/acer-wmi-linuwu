# acer-wmi with Linuwu-Sense extensions

A drop-in replacement for the kernel's `acer-wmi` driver, packaged for DKMS. It is the upstream driver from the platform-drivers-x86 `for-next` branch, extended with the NitroSense and PredatorSense settings reverse engineered by [Linuwu-Sense](https://github.com/0x7375646F/Linuwu-Sense) and [Div-Linuwu-Sense](https://github.com/PXDiv/Div-Linuwu-Sense), rewritten to follow the kernel's coding conventions.

The module is built under the same name as the in-tree driver, `acer_wmi`, and DKMS installs it where it takes precedence over the in-tree copy. Nothing needs blacklisting, and everything the upstream driver does (hotkeys, rfkill, platform profiles, hwmon sensors and fan control) keeps working as before.

> **Use at your own risk.** The NitroSense and PredatorSense settings drive undocumented firmware methods, found by reverse engineering Acer's Windows utilities. What is known to work on each model comes from its owners' reports against Linuwu-Sense and its forks, cited in the table below. This rewrite has been build-tested against kernels 7.2 and 6.18, and tested on hardware only on a Nitro AN515-57 (BIOS V1.14), where the platform profiles, hwmon, rfkill and every NitroSense setting work apart from `lcd_override`. Battery calibration was not exercised.

## What it adds to the upstream driver

**NitroSense and PredatorSense settings**, in `/sys/devices/platform/acer-wmi/nitro_sense/` or `/sys/devices/platform/acer-wmi/predator_sense/`:

| Attribute | Values |
|---|---|
| `fan_speed` | CPU and GPU fan speed as percentages, `cpu,gpu`; `0` is automatic, `100,100` is maximum |
| `battery_limiter` | `1` limits charging to 80% |
| `battery_calibration` | `1` starts calibration, `0` stops it; keep the laptop on AC throughout |
| `usb_charging` | power-off USB charging until the battery drops to `10`, `20` or `30`%, or `0` for off |
| `backlight_timeout` | `1` turns the keyboard backlight off after 30 seconds idle |
| `lcd_override` | `1` enables LCD overdrive (Predator, and Nitro models listed as v4) |
| `boot_animation_sound` | `1` enables the boot animation and sound (Predator, and Nitro v4) |
| `version` | the version of this package, read by DAMX |

**Four-zone RGB keyboards**, in `/sys/devices/platform/acer-wmi/four_zoned_kb/`:

| Attribute | Format |
|---|---|
| `four_zone_mode` | `mode,speed,brightness,direction,red,green,blue`, where mode is 0 static, 1 breathing, 2 neon, 3 wave, 4 shifting, 5 zoom, 6 meteor or 7 twinkling, and direction is 1 right to left or 2 left to right |
| `per_zone_mode` | `RRGGBB,RRGGBB,RRGGBB,RRGGBB,brightness`, zones from left to right |

Per-key RGB keyboards are not supported. The full description of every attribute is in [`Documentation/ABI/testing/sysfs-platform-acer-wmi`](Documentation/ABI/testing/sysfs-platform-acer-wmi).

**The Nitro mode key.** On Nitro laptops the NitroSense key cycles the platform profile, as it does on Predator laptops.

**More models.** See the table below.

For example:

```sh
echo 50,70 | sudo tee /sys/devices/platform/acer-wmi/nitro_sense/fan_speed
echo 1 | sudo tee /sys/devices/platform/acer-wmi/nitro_sense/battery_limiter
echo 4287f5,ff5733,33ff57,ff33a6,100 | sudo tee /sys/devices/platform/acer-wmi/four_zoned_kb/per_zone_mode
```

The thermal profile is the kernel's standard platform profile interface, in `/sys/firmware/acpi/platform_profile` and `platform_profile_choices`, which power-profiles-daemon and desktop environments already use.

## Supported models

| Model | Platform profile | Sensors | `fan_speed` | hwmon pwm | Turbo key | Sense settings | Four-zone RGB | Reported in |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---|
| Nitro AN515-55 | ❌ | ✅ | ✅ | ❌ | ❌ | NitroSense | ❌ | [LS#40](https://github.com/0x7375646F/Linuwu-Sense/issues/40) |
| Nitro AN515-47 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense | ❌ | [DAMX#44](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/44) |
| Nitro ANV15-41 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense | ❌ | Linuwu-Sense |
| Nitro ANV15-51 | ✅ | ✅ | ✅ | ✅ | ❌ | NitroSense | ❌ | Linuwu-Sense, upstream [patch](https://patchwork.kernel.org/project/platform-driver-x86/patch/20260920053918.1888-1-justinyvar@gmail.com/) |
| Nitro ANV15-52 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense | ❌ | [LS#117](https://github.com/0x7375646F/Linuwu-Sense/issues/117), [DLS#14](https://github.com/PXDiv/Div-Linuwu-Sense/issues/14) |
| Nitro AN17-41, AN17-42 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense | ✅ | [DAMX#99](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/99), [DAMX#64](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/64) |
| Nitro AN515-46 | ✅ | ✅ | ✅ | ✅ | ❌ | NitroSense | ✅ | [DLS#4](https://github.com/PXDiv/Div-Linuwu-Sense/issues/4) |
| Nitro AN515-58 | ✅ | ✅ | ✅ | ✅ | ❌ | NitroSense | ✅ | upstream, Linuwu-Sense |
| Nitro AN515-44 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ❌ | [DAMX compatibility list](https://github.com/PXDiv/Div-Acer-Manager-Max/blob/main/Compatibility.md) |
| Nitro AN515-57 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ❌ | [notalhanz/Linuwu-Sense](https://github.com/notalhanz/Linuwu-Sense/commit/c63f98e0a445a9387fc28c569df71f719edb1a8f) |
| Nitro ANV16-41 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ❌ | [LS#37](https://github.com/0x7375646F/Linuwu-Sense/issues/37) |
| Nitro ANV16-42 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ❌ | [DAMX#174](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/174) |
| Nitro ANV16-71 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ❌ | [LS#64](https://github.com/0x7375646F/Linuwu-Sense/issues/64), [DAMX#128](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/128) |
| Nitro ANV16S-41 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ❌ | [LS#61](https://github.com/0x7375646F/Linuwu-Sense/issues/61) |
| Nitro AN16-41, AN16-43 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ✅ | [LS#17](https://github.com/0x7375646F/Linuwu-Sense/issues/17) |
| Nitro AN16-42 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ✅ | [LS#85](https://github.com/0x7375646F/Linuwu-Sense/issues/85) |
| Nitro AN515-45 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ✅ | [LS#92](https://github.com/0x7375646F/Linuwu-Sense/issues/92), [DLS#12](https://github.com/PXDiv/Div-Linuwu-Sense/issues/12) |
| Nitro AN517-54 | ✅ | ✅ | ✅ | ❌ | ❌ | NitroSense v4 | ✅ | [DLS#5](https://github.com/PXDiv/Div-Linuwu-Sense/issues/5) |
| Predator PH16-71, PH18-71 | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ❌ | upstream, Linuwu-Sense |
| Predator PH18-73 | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ❌ | [LS#123](https://github.com/0x7375646F/Linuwu-Sense/issues/123) |
| Predator PHN16-73 | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ❌ | [LS#126](https://github.com/0x7375646F/Linuwu-Sense/issues/126) |
| Predator PHN18-72 | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ❌ | [DAMX#123](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/123) |
| Predator PTX17-71 | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ❌ | [LS#83](https://github.com/0x7375646F/Linuwu-Sense/issues/83) |
| Predator PHN16-71 | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ✅ | upstream, Linuwu-Sense |
| Predator PT316-51s | ✅ | ✅ | ✅ | ❌ | ❌ | PredatorSense | ✅ | [DLS#17](https://github.com/PXDiv/Div-Linuwu-Sense/issues/17) |
| Predator PHN16-72 | ✅ | ✅ | ✅ | ✅ | ✅ | PredatorSense | ✅ | upstream, Linuwu-Sense |
| Predator PH315-53 | ❌ | ✅ | ✅ | ❌ | ✅ | PredatorSense | ✅ | upstream, [LS#98](https://github.com/0x7375646F/Linuwu-Sense/issues/98), [LS#121](https://github.com/0x7375646F/Linuwu-Sense/issues/121) |
| Predator PH315-52 | ❌ | ✅ | ✅ | ❌ | ✅ | PredatorSense | ✅ | [LS#119](https://github.com/0x7375646F/Linuwu-Sense/issues/119), turbo key only |
| Predator PH16-72, PT14-51 | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | upstream |
| Predator PHN16S-71 | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | [LS#101](https://github.com/0x7375646F/Linuwu-Sense/issues/101), [DAMX#270](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/270) |
| Aspire A315-58G | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | upstream |

"NitroSense v4" means a Nitro whose firmware offers the full PredatorSense set of settings. The directory is still called `nitro_sense`.

"Upstream" means the model is supported by the kernel's own driver, and the features added here come from the reports alongside it. For the PH315-52 only the turbo key has been reported working; it is given the PH315-53's settings as the closest model, which is untested. LS, DLS and DAMX are the issue trackers of [Linuwu-Sense](https://github.com/0x7375646F/Linuwu-Sense), [Div-Linuwu-Sense](https://github.com/PXDiv/Div-Linuwu-Sense) and [DAMX](https://github.com/PXDiv/Div-Acer-Manager-Max); the driver's DMI table cites the same reports.

### Known issues

- **ANV15-51**: the firmware rejects the performance profile with an I/O error, although it is offered, as in the upstream driver ([patch](https://patchwork.kernel.org/project/platform-driver-x86/patch/20260920053918.1888-1-justinyvar@gmail.com/)).
- **ANV15-51 and ANV15-52**: the NitroSense key is an ordinary keyboard scancode, `0xf5`, rather than a WMI event, so this driver never sees it. systemd's hwdb maps it to `prog1` on the ANV15-51 ([systemd#38415](https://github.com/systemd/systemd/pull/38415)); bind that key in userspace to cycle profiles ([LS#117](https://github.com/0x7375646F/Linuwu-Sense/issues/117)).
- **AN515-58**: on BIOS V2.18 the static keyboard effect turns the lights off, even with valid parameters ([LS#99](https://github.com/0x7375646F/Linuwu-Sense/issues/99)), and on BIOS V2.19 the battery limiter is accepted but has no effect ([DAMX#184](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/184)). Both are firmware behaviour.
- **PHN16S-71**: the fans read 0 RPM and do not respond to control ([DAMX#270](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/270)), so only the platform profile and temperatures are enabled.
- **PHN16S-71 and PHN18-72**: the keyboard lighting does not respond to the WMI methods ([LS#101](https://github.com/0x7375646F/Linuwu-Sense/issues/101), [DAMX#123](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/123)), so four-zone control is not enabled on them. Nor is it enabled on the PHN16-73 and ANV16S-41, for which no report says it works.
- **Per-key RGB keyboards**, such as the Helios 16's, are not supported; the four-zone methods have no effect on them ([DAMX#237](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/237)).
- **AN515-57**: writes to `lcd_override` are accepted but the value does not change, so the model may lack LCD overdrive; this is being investigated before the setting is removed for it.
- **AN515-47**: LCD overdrive has no effect, so it gets the NitroSense settings without it ([DAMX#44](https://github.com/PXDiv/Div-Acer-Manager-Max/issues/44)).

A model not in the table can try the `nitro_v4=1` or `predator_v4=1` module parameter, which enables the corresponding set of features regardless of the model:

```sh
sudo modprobe -r acer_wmi
sudo modprobe acer_wmi nitro_v4=1
```

If that works, please open an issue with the output of `cat /sys/class/dmi/id/product_name` and which features work, so that the model can be added.

## Installation

Install the headers for every kernel you use and DKMS. On Arch Linux:

```sh
sudo pacman -S --needed dkms linux-headers
```

Then, from a clone of this repository:

```sh
sudo dkms add .
sudo dkms install acer-wmi-linuwu/7.3.0.1
```

`dkms add` copies the repository to `/usr/src/acer-wmi-linuwu-7.3.0.1`, and `dkms install` builds and installs it for the running kernel; add `-k <version>` to install it for another installed kernel. DKMS then builds it automatically for every new kernel. After pulling a new version, remove the old one as described below and add the new one.

To load it without rebooting:

```sh
sudo modprobe -r acer_wmi
sudo modprobe acer_wmi
```

Check that the new module is the one in use; the path should be under `updates/dkms`:

```sh
modinfo -n acer_wmi
```

To uninstall, which returns the system to the in-tree driver:

```sh
sudo dkms remove acer-wmi-linuwu/7.3.0.1 --all
```

The kernel must be 6.14 or newer.

### Secure Boot

With Secure Boot enabled, the module must be signed with a key the firmware trusts. DKMS signs modules automatically once a machine owner key is set up; see the `mok_signing_key` and `mok_certificate` options in `/etc/dkms/framework.conf`, and enrol the certificate with `mokutil --import`.

### Migrating from Linuwu-Sense

Linuwu-Sense blacklisted `acer_wmi` and loaded its own `linuwu_sense` module, which conflicts with this package. Remove it first, either with `make uninstall` from the Linuwu-Sense checkout or by hand:

```sh
sudo rm /etc/modprobe.d/blacklist-acer_wmi.conf /etc/modules-load.d/linuwu_sense.conf
sudo systemctl disable --now linuwu_sense.service
sudo rm /etc/systemd/system/linuwu_sense.service
sudo rm /usr/lib/modules/*/kernel/drivers/platform/x86/linuwu_sense.ko
sudo depmod -a
```

Linuwu-Sense also kept its settings in `/etc/predator_state` and `/etc/four_zone_kb_state`. This driver does not read or write files, which kernel code must not do, so those files can be deleted. Any setting the firmware does not retain across a reboot has to be restored from userspace.

Two other behaviours of Linuwu-Sense are deliberately not carried over, since they are policy and belong in userspace:

- remembering a separate profile and fan speed for AC and battery, and switching between them on plugging in or out;
- refusing the performance and quiet profiles on battery, and resetting the fans when quiet or eco is selected.

The platform profile offers all five profiles on every supported model, as the upstream driver does, since the firmware's own list of supported profiles is unreliable.

### DAMX

[DAMX](https://github.com/PXDiv/Div-Acer-Manager-Max) looks for its settings under `/sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/`, which exists only when the module is called `linuwu_sense`. With this driver the same directories are at `/sys/devices/platform/acer-wmi/`, and DAMX needs that path changed to find them. The attributes themselves are the same.

## Building without DKMS

```sh
make                        # for the running kernel
make KVER=6.18.54-1-lts     # for another installed kernel
make compile_commands.json  # for clangd or other editor tooling
make clean
```

The module is `src/acer-wmi.ko`. Load it for testing with `sudo modprobe -r acer_wmi && sudo insmod src/acer-wmi.ko`.

## Layout

| Path | Contents |
|---|---|
| `src/acer-wmi.c` | the driver |
| `src/Kbuild` | the kernel build rules |
| `dkms.conf` | the DKMS package definition, which holds the version |
| `Makefile` | convenience targets for building outside DKMS |
| `Documentation/ABI/` | the sysfs interface, in the kernel's ABI format |

The version is the upstream kernel release the driver is based on, followed by a revision of this package. The driver currently tracks `drivers/platform/x86/acer-wmi.c` as of platform-drivers-x86 `for-next` commit [`3bd07ec2893b`](https://git.kernel.org/pub/scm/linux/kernel/git/pdx86/platform-drivers-x86.git/commit/?id=3bd07ec2893bef0220cd63589c19e5be354fe835) ("platform/x86: acer-wmi: enable hwmon on Aspire A315-58G"); `git diff --no-index` against that file shows everything this package adds.

## How this version was written

This version was written by Claude (Anthropic's Claude Opus 5.5, working in Claude Code) at the direction of Adityarup Laha. The reverse engineering of the firmware interface is not Claude's: it is the work of the Linuwu-Sense and Div-Linuwu-Sense authors and of the users who tested their models. What Claude did:

- merged the Linuwu-Sense and Div-Linuwu-Sense features onto the current upstream `acer-wmi.c`, rewriting them in the kernel's style on top of the upstream driver's own WMI helpers, and decoding their magic numbers into named fields where the pattern was clear;
- dropped what the kernel does not allow or leaves to userspace, such as writing state files to `/etc`;
- gathered the model reports cited above and added the models they support;
- wrote the DKMS packaging, this README and the ABI documentation, and checked the result with `checkpatch.pl --strict` and warning-free builds against kernels 7.2 and 6.18.

## Credits

- The upstream `acer-wmi` driver, by Carlos Corbacho and the kernel's platform-drivers-x86 maintainers and contributors.
- [Linuwu-Sense](https://github.com/0x7375646F/Linuwu-Sense) by 0x7375646F, which reverse engineered the NitroSense and PredatorSense methods, and its contributors.
- [Div-Linuwu-Sense](https://github.com/PXDiv/Div-Linuwu-Sense) by Div Sharp (PXDiv), the author of DAMX.
- [acer-predator-turbo-and-rgb-keyboard-linux-module](https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module), which inspired Linuwu-Sense.

## Licence

GPL-2.0-or-later, as the upstream driver is. The full text of version 2 is in [`LICENSE`](LICENSE).
