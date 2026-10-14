# TWRP device tree for the Samsung Galaxy A13 (SM-A137F, `a13ve`)

| | |
|---|---|
| SoC | MediaTek Helio G80 (MT6768), Mali-G52 |
| Stock firmware this tree targets | A137FXXSCEZB1 (Android 14 / One UI 6.1, Feb 2026, bootloader binary C) |
| Recovery | dedicated 32 MiB `recovery` partition, non-A/B, boot header v2 |
| Partitions | dynamic (`super`: system, system_ext, vendor, product, odm), metadata on `md_udc` |
| Kernel | prebuilt, own build of Samsung's 4.19.191 source (`prebuilt/Image.gz`) |
| TWRP branch | `twrp-12.1` |

The tree was generated with twrpdtgen 3.0.0 from the stock A137FXXSCEZB1
recovery image and then rebuilt on top of the configuration SavedByLight
maintains in [TeamWin/android_device_samsung_a13ve](https://github.com/TeamWin/android_device_samsung_a13ve).

## Build

```bash
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags
git clone <this repo> device/samsung/a13ve
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_a13ve-eng
mka recoveryimage
```

Output: `out/target/product/a13ve/recovery.img` and `recovery.tar` for Odin
(AP slot). The image carries the `SEANDROIDENFORCE` footer Samsung's
bootloader expects. The bootloader must be unlocked.

## Kernel

The build does not compile a kernel. Drop a gzip-compressed `Image.gz` into
`prebuilt/` and keep `prebuilt/dtb/a13ve.dtb` (stock dtb, also found in the stock
boot image; the build assembles `dtb.img` from that directory). A recovery kernel for this device needs:

- `CONFIG_CMDLINE_FROM_BOOTLOADER=y` (no `CMDLINE_FORCE`): SELinux is set
  permissive through `androidboot.selinux=permissive` in the recovery image
  header, not in the kernel.
- `CONFIG_SECURITY_SELINUX_DEVELOP=y`, f2fs with encryption, inline crypto,
  USB configfs (adb, MTP), overlayfs. Samsung's `a13ve_defconfig` has them.
- `CONFIG_IKCONFIG_PROC=y` is handy: `zcat /proc/config.gz` works in TWRP.

Verify a new kernel booted the right way from TWRP:

```bash
adb shell 'cat /proc/cmdline; getenforce; cat /proc/version'
```

## Notes

- Size budget is tight: the ramdisk is LZMA-compressed and NTFS, extra
  languages, tzdata, nano, Python and SuperSU are excluded.
- The touchscreen stops responding after the panel was off once;
  `recovery/root/sbin/tsp_touch_fix.sh` resets the controller on power-key
  release.
- `/data` decryption (FBE v2 with metadata encryption) is not implemented.
  `TW_INCLUDE_CRYPTO` is unset; the fstab flags are kept for reference.
- Official TWRP page: <https://twrp.me/samsung/A13ve.html>.

## Credits

- [SavedByLight](https://github.com/SavedByLight) (Jamie Falconer): the
  TeamWin a13ve tree this configuration is ported from, the touch workaround.
- [physwizz](https://github.com/physwizz): the first custom kernels and
  recoveries for this device.
- [SebaUbuntu](https://github.com/SebaUbuntu/TWRP-device-tree-generator):
  twrpdtgen.
