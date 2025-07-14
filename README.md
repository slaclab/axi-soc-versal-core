# axi-soc-versal-core

<!--- ######################################################## -->

### Versal Adaptive SoC Register Reference (AM012)

https://docs.amd.com/r/en-US/am012-versal-register-reference

<!--- ######################################################## -->

### How to format SD card for SD boot

https://xilinx-wiki.atlassian.net/wiki/x/EYMfAQ

1) Copy For the boot images, simply copy the files to the FAT partition.
This typically will include BOOT.BIN, image.ub, and boot.scr

```bash
sudo mkdir -p boot
sudo mount /dev/sdd1 boot
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/system.bit boot/.
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/BOOT.BIN   boot/.
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/image.ub   boot/.
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/boot.scr   boot/.
sudo umount boot
sudo rm -rf boot
```

2) For the root file system, the process will depend on the format of your root file system image.

`roofts.ext4 -  This is an uncompressed ext4 file system image. To copy the contents to the root partition, you can use the following command: `

```bash
sudo dd if=<PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/rootfs.ext4 of=/dev/<DEV_NAME>
```

<!--- ######################################################## -->
