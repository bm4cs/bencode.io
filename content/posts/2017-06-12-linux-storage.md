---
layout: post
draft: false
title: "Linux Storage and File Systems"
date: "2017-06-12 20:59:20"
lastmod: "2017-06-12 20:59:20"
comments: false
categories:
    - linux
tags:
    - linux
---

# Partitioning

Two popular partition schemes are used in the wild, MBR and GPT.

### MBR

MBR, or Master Boot Record, often associated with BIOS, was introduced in 1983 with IBM PC DOS 2.0, is a special boot sector located at the beginning of a drive. This sector contains a boot loader (e.g GRUB), and details about the logical partitions. MBR supports drives upto 2TiB, and up to 4 primary partitions.

    # fdisk /dev/vda
    Welcome to fdisk (util-linux 2.23.2).

    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.

    Device does not contain a recognized partition table
    Building a new DOS disklabel with disk identifier 0x9228f9b7.

    Command (m for help): m
    Command action
       a   toggle a bootable flag
       b   edit bsd disklabel
       c   toggle the dos compatibility flag
       d   delete a partition
       g   create a new empty GPT partition table
       G   create an IRIX (SGI) partition table
       l   list known partition types
       m   print this menu
       n   add a new partition
       o   create a new empty DOS partition table
       p   print the partition table
       q   quit without saving changes
       s   create a new empty Sun disklabel
       t   change a partition's system id
       u   change display/entry units
       v   verify the partition table
       w   write table to disk and exit
       x   extra functionality (experts only)

    Command (m for help): n
    Partition type:
       p   primary (0 primary, 0 extended, 4 free)
       e   extended
    Select (default p):
    Using default response p
    Partition number (1-4, default 1):
    First sector (2048-2097151, default 2048):
    Using default value 2048
    Last sector, +sectors or +size{K,M,G} (2048-2097151, default 2097151): +500M
    Partition 1 of type Linux and of size 500 MiB is set

    Command (m for help): l
     0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris
     1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
     2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
     3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
     4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx
     5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data
     6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
     7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility
     8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt
     9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access
     a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O
     b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor
     c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs
     e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT
     f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
    10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
    11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor
    12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor
    14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary
    16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS
    17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE
    18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
    1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep
    1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT
    1e  Hidden W95 FAT1 80  Old Minix

    Command (m for help): t
    Selected partition 1
    Hex code (type L to list all codes): 83
    Changed type of partition 'Linux' to 'Linux'

    Command (m for help): w
    The partition table has been altered!
    Calling ioctl() to re-read partition table.
    Syncing disks.

The partition is now available as a block device, below we now see `/dev/vda1`:

    # ls /dev/vda*
    /dev/vda  /dev/vda1

Let's create a second 500G partition, on the 1GB drive `/dev/vda`.

    # fdisk /dev/vda
    Welcome to fdisk (util-linux 2.23.2).

    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.

    Command (m for help): n
    Partition type:
       p   primary (1 primary, 0 extended, 3 free)
       e   extended
    Select (default p):
    Using default response p
    Partition number (2-4, default 2):
    First sector (1026048-2097151, default 1026048):
    Using default value 1026048
    Last sector, +sectors or +size{K,M,G} (1026048-2097151, default 2097151): +500M
    Partition 2 of type Linux and of size 500 MiB is set

    Command (m for help): w
    The partition table has been altered!
    Calling ioctl() to re-read partition table.
    Syncing disks.

Done.

    # ls /dev/vda*
    /dev/vda  /dev/vda1  /dev/vda2

Now to apply a file system. RHEL 7 by default uses [xfs](https://en.wikipedia.org/wiki/XFS).

    # mkfs -t xfs /dev/vda1
    meta-data=/dev/vda1              isize=256    agcount=4, agsize=32000 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=0        finobt=0
    data     =                       bsize=4096   blocks=128000, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
    log      =internal log           bsize=4096   blocks=853, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0

What file systems are currently mounted?

    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    devtmpfs                         482M     0  482M   0% /dev
    tmpfs                            497M  156K  497M   1% /dev/shm
    tmpfs                            497M  7.1M  490M   2% /run
    tmpfs                            497M     0  497M   0% /sys/fs/cgroup
    /dev/mapper/centos_server1-home  953M   54M  899M   6% /home
    /dev/vdb1                        473M  156M  317M  33% /boot
    tmpfs                            100M  4.0K  100M   1% /run/user/42
    tmpfs                            100M   20K  100M   1% /run/user/1000
    tmpfs                            100M     0  100M   0% /run/user/0

Nothing using the new xfs `/dev/vda1` partition. What block storage devices exist (regardless if actively mounted)?

    # blkid
    /dev/vda1: UUID="5e7ca7ad-d515-4820-b35b-ac14dffc03e4" TYPE="xfs"
    /dev/vdb1: LABEL="boot" UUID="4302f187-5824-4799-980b-c816ae5b24e0" TYPE="xfs"
    /dev/vdb2: UUID="OCxtoT-4gVL-DPtV-Yfdp-uMXQ-JsRE-7fjFQ4" TYPE="LVM2_member"
    /dev/mapper/centos_server1-root: LABEL="root" UUID="632a6441-ba6f-4825-8a1c-c6fc14e05a9a" TYPE="xfs"
    /dev/mapper/centos_server1-swap: UUID="af7fbf4b-4efc-40fc-b5de-4af06539d215" TYPE="swap"
    /dev/mapper/centos_server1-home: UUID="fc985c0e-3239-47b4-bdc0-85e195f7c0fd" TYPE="xfs"

Mount `/dev/vda1`:

    # mkdir /mnt/foomount
    # mount /dev/vda1 /mnt/foomount
    # cd foomount/

    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    devtmpfs                         482M     0  482M   0% /dev
    tmpfs                            497M  156K  497M   1% /dev/shm
    tmpfs                            497M  7.1M  490M   2% /run
    tmpfs                            497M     0  497M   0% /sys/fs/cgroup
    /dev/mapper/centos_server1-home  953M   54M  899M   6% /home
    /dev/vdb1                        473M  156M  317M  33% /boot
    tmpfs                            100M  4.0K  100M   1% /run/user/42
    tmpfs                            100M   20K  100M   1% /run/user/1000
    tmpfs                            100M     0  100M   0% /run/user/0
    /dev/vda1                        497M   26M  472M   6% /mnt/foomount

    # touch {file1,file2}
    # umount /mnt/foomount/

    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    devtmpfs                         482M     0  482M   0% /dev
    tmpfs                            497M  156K  497M   1% /dev/shm
    tmpfs                            497M  7.1M  490M   2% /run
    tmpfs                            497M     0  497M   0% /sys/fs/cgroup
    /dev/mapper/centos_server1-home  953M   54M  899M   6% /home
    /dev/vdb1                        473M  156M  317M  33% /boot
    tmpfs                            100M  4.0K  100M   1% /run/user/42
    tmpfs                            100M   20K  100M   1% /run/user/1000
    tmpfs                            100M     0  100M   0% /run/user/0

Delete a partition.

    # fdisk vda
    Welcome to fdisk (util-linux 2.23.2).

    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.

    Command (m for help): p

    Disk vda: 1073 MB, 1073741824 bytes, 2097152 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk label type: dos
    Disk identifier: 0x9228f9b7

    Device Boot      Start         End      Blocks   Id  System
      vda1            2048     1026047      512000   83  Linux
      vda2         1026048     2050047      512000   83  Linux

    Command (m for help): d
    Partition number (1,2, default 2):
    Partition 2 is deleted

    Command (m for help): w
    The partition table has been altered!

    Calling ioctl() to re-read partition table.
    Syncing disks.

Its always good practice after modifying partition tables, to reread partition data with `partprobe`.

Mounting with the drive UUID, improves consistency, as dev id's such as `/dev/vda1` are not guaranteed, and is influenced by the sequence in which hardware is initialised. To mount by UUID is simple:

    # blkid
    /dev/vda1: UUID="5e7ca7ad-d515-4820-b35b-ac14dffc03e4" TYPE="xfs"
    /dev/vdb1: LABEL="boot" UUID="4302f187-5824-4799-980b-c816ae5b24e0" TYPE="xfs"
    /dev/vdb2: UUID="OCxtoT-4gVL-DPtV-Yfdp-uMXQ-JsRE-7fjFQ4" TYPE="LVM2_member"
    /dev/mapper/centos_server1-root: LABEL="root" UUID="632a6441-ba6f-4825-8a1c-c6fc14e05a9a" TYPE="xfs"
    /dev/mapper/centos_server1-swap: UUID="af7fbf4b-4efc-40fc-b5de-4af06539d215" TYPE="swap"
    /dev/mapper/centos_server1-home: UUID="fc985c0e-3239-47b4-bdc0-85e195f7c0fd" TYPE="xfs"

    # mount -U 5e7ca7ad-d515-4820-b35b-ac14dffc03e4 /mnt/foomount
    # ls /mnt/foomount
    file1  file2

### GPT

GPT, or GUID Partition Table, often associated with UEFI, assigns a unique identifier (GUID) to each partition. GPT overcomes many of MBT's limitationsm, and offers some nice resiliance features, such as storing multiple copies of the boot and partitioning data across the drive, and storing CRC for detecting possible data integrity issues. Thanks to its 64 bit addressing can support disk sizes up to 8ZiB and 128 primary partitions.

    # gdisk /dev/vda
    GPT fdisk (gdisk) version 0.8.6

    Command (? for help): n
    Partition number (1-128, default 1):
    First sector (34-2097118, default = 2048) or {+-}size{KMGTP}:
    Last sector (2048-2097118, default = 2097118) or {+-}size{KMGTP}: +500M
    Current type is 'Linux filesystem'
    Hex code or GUID (L to show codes, Enter = 8300):
    Changed type of partition to 'Linux filesystem'

    Command (? for help): w

    Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
    PARTITIONS!!

    Do you want to proceed? (Y/N): Y
    OK; writing new GUID partition table (GPT) to /dev/vda.
    The operation has completed successfully.

The new partition is now a device (i.e. available in `/dev`):

    # ls /dev/vda*
    /dev/vda  /dev/vda1

Apply a file system to the partition.

    # mkfs -t xfs -f /dev/vda1
    meta-data=/dev/vda1              isize=256    agcount=4, agsize=32000 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=0        finobt=0
    data     =                       bsize=4096   blocks=128000, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
    log      =internal log           bsize=4096   blocks=853, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0

Mount it:

    # mount /dev/vda1 -t xfs /sillymount

Once mounted `df` will report it:

    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    /dev/vdb1                        473M  156M  317M  33% /boot
    /dev/mapper/centos_server1-home  953M   54M  899M   6% /home
    /dev/vda1                        497M   26M  472M   6% /mnt/sillymount

It's better to use the UUID of the partition to mount it:

Unmount:

    # umount sillymount

List device UUID's:

    # blkid
    /dev/vdb1: LABEL="boot" UUID="4302f187-5824-4799-980b-c816ae5b24e0" TYPE="xfs"
    /dev/vdb2: UUID="OCxtoT-4gVL-DPtV-Yfdp-uMXQ-JsRE-7fjFQ4" TYPE="LVM2_member"
    /dev/mapper/centos_server1-root: LABEL="root" UUID="632a6441-ba6f-4825-8a1c-c6fc14e05a9a" TYPE="xfs"
    /dev/mapper/centos_server1-swap: UUID="af7fbf4b-4efc-40fc-b5de-4af06539d215" TYPE="swap"
    /dev/mapper/centos_server1-home: UUID="fc985c0e-3239-47b4-bdc0-85e195f7c0fd" TYPE="xfs"
    /dev/vda1: UUID="6d2da03c-eea0-4630-b19b-c067ca790cf1" TYPE="xfs" PARTLABEL="Linux filesystem" PARTUUID="2f6035f7-d4c0-4f06-becb-6cd2afc7ceed"

Mount using UUID with `-U` switch:

    # mount -U 6d2da03c-eea0-4630-b19b-c067ca790cf1 -t xfs /mnt/sillymount

# Logical Volume Management

### Attach Block Devices

To experiment with LVM (logical volume manager), using a KVM machine, attach a few 1GB storage devices.

    virsh # vol-list default
     Name                 Path
    ------------------------------------------------------------------------------
     server1.example.com.qcow2 /var/lib/libvirt/images/server1.example.com.qcow2
     silly-volume-1.qcow2 /var/lib/libvirt/images/silly-volume-1.qcow2
     silly-volume-2.qcow2 /var/lib/libvirt/images/silly-volume-2.qcow2
     silly-volume-3.qcow2 /var/lib/libvirt/images/silly-volume-3.qcow2

    virsh # domblklist server1.example.com
    Target     Source
    ------------------------------------------------
    vda        /var/lib/libvirt/images/server1.example.com.qcow2
    vdb        /var/lib/libvirt/images/silly-volume-1.qcow2
    vdc        /var/lib/libvirt/images/silly-volume-2.qcow2
    vdd        /var/lib/libvirt/images/silly-volume-3.qcow2
    hda        -

### Partitions

For each block device, we need to add a (GPT) partition of type **Linux LVM**. Rinse and repeat with `gdisk`, for example, given block device `/dev/vdd`:

    # gdisk vdd
    GPT fdisk (gdisk) version 0.8.6

    Partition table scan:
      MBR: not present
      BSD: not present
      APM: not present
      GPT: not present

    Creating new GPT entries.

    Command (? for help): n
    Partition number (1-128, default 1):
    First sector (34-2097118, default = 2048) or {+-}size{KMGTP}:
    Last sector (2048-2097118, default = 2097118) or {+-}size{KMGTP}:
    Current type is 'Linux filesystem'
    Hex code or GUID (L to show codes, Enter = 8300): 8e00
    Changed type of partition to 'Linux LVM'

    Command (? for help): w

    Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
    PARTITIONS!!

    Do you want to proceed? (Y/N): Y
    OK; writing new GUID partition table (GPT) to vdd.
    The operation has completed successfully.

### Physical Volume

Register the desired partitions as LVM physical volumes, using `pvcreate`.

    # pvcreate /dev/vdc1 /dev/vdd1
    Physical volume "/dev/vdc1" successfully created
    Physical volume "/dev/vdd1" successfully created

And, confirm physical volume creation with `pvdisplay`:

    # pvdisplay
    --- Physical volume ---
    PV Name               /dev/vdb2
    VG Name               centos_server1
    PV Size               11.21 GiB / not usable 4.00 MiB
    Allocatable           yes
    PE Size               4.00 MiB
    Total PE              2870
    Free PE               3
    Allocated PE          2867
    PV UUID               OCxtoT-4gVL-DPtV-Yfdp-uMXQ-JsRE-7fjFQ4

    "/dev/vdc1" is a new physical volume of "1022.98 MiB"
    --- NEW Physical volume ---
    PV Name               /dev/vdc1
    VG Name
    PV Size               1022.98 MiB
    Allocatable           NO
    PE Size               0
    Total PE              0
    Free PE               0
    Allocated PE          0
    PV UUID               U3tvfK-0Bfe-Gc6a-EHUU-YlAr-FV99-ZdO8Hc

    "/dev/vdd1" is a new physical volume of "1022.98 MiB"
    --- NEW Physical volume ---
    PV Name               /dev/vdd1
    VG Name
    PV Size               1022.98 MiB
    Allocatable           NO
    PE Size               0
    Total PE              0
    Free PE               0
    Allocated PE          0
    PV UUID               4sR7Qv-G58b-b6HG-N2rZ-SjSu-fGS3-nPIr10

### Volume Group

Enlist previously registered _physical volumes_ into what is known as a _volume group_. Note `vgcreate` takes an alias (cylon in the example).

# vgcreate cylon /dev/vdc1 /dev/vdd1

Volume group "cylon" successfully created

Confirming desired result with `vgdisplay`:

# vgdisplay

--- Volume group ---
VG Name cylon
System ID  
 Format lvm2
Metadata Areas 2
Metadata Sequence No 1
VG Access read/write
VG Status resizable
MAX LV 0
Cur LV 0
Open LV 0
Max PV 0
Cur PV 2
Act PV 2
VG Size 1.99 GiB
PE Size 4.00 MiB
Total PE 510
Alloc PE / Size 0 / 0  
 Free PE / Size 510 / 1.99 GiB
VG UUID iC4m8Z-7c4K-n1H4-MVB4-RaIY-nV9q-zYdJ6S

### Logical Volumes

Finally, we can create the logical volumes that will manifest themselves as block devices to operating system, which in turn can have file systems applied to them and so on. Lets create two logical volumes, a 1GB called "starbuck", and a 500M called "boomer":

    # lvcreate -n starbuck -L 1G cylon
      Logical volume "starbuck" created.

    # lvcreate -n boomer -L 500M cylon
      Logical volume "boomer" created.

Verify logical volumes with `lvdisplay`:

    # lvdisplay
      --- Logical volume ---
      LV Path                /dev/cylon/starbuck
      LV Name                starbuck
      VG Name                cylon
      LV UUID                UlhcnB-HuPX-OXDV-IL1U-uCGv-Hnfs-fFkGIs
      LV Write Access        read/write
      LV Creation host, time server1.example.com, 2017-07-08 08:44:32 -0400
      LV Status              available
      # open                 0
      LV Size                1.00 GiB
      Current LE             256
      Segments               2
      Allocation             inherit
      Read ahead sectors     auto
      - currently set to     8192
      Block device           253:3

      --- Logical volume ---
      LV Path                /dev/cylon/boomer
      LV Name                boomer
      VG Name                cylon
      LV UUID                qik2FG-cM1F-JXY7-yoaW-U5ve-qfjM-iO6bwK
      LV Write Access        read/write
      LV Creation host, time server1.example.com, 2017-07-08 08:47:32 -0400
      LV Status              available
      # open                 0
      LV Size                500.00 MiB
      Current LE             125
      Segments               1
      Allocation             inherit
      Read ahead sectors     auto
      - currently set to     8192
      Block device           253:4

You can see both are sitting on the _volume group_ named **cylon**. Speaking of cylon, how much capacity does it have?

    # vgdisplay
      --- Volume group ---
      VG Name               cylon
      System ID
      Format                lvm2
      Metadata Areas        2
      Metadata Sequence No  3
      VG Access             read/write
      VG Status             resizable
      MAX LV                0
      Cur LV                2
      Open LV               0
      Max PV                0
      Cur PV                2
      Act PV                2
      VG Size               1.99 GiB
      PE Size               4.00 MiB
      Total PE              510
      Alloc PE / Size       381 / 1.49 GiB
      Free  PE / Size       129 / 516.00 MiB
      VG UUID               iC4m8Z-7c4K-n1H4-MVB4-RaIY-nV9q-zYdJ6S

Can see its got 516 MiB free, nice.

### Apply File System

LVM logical volumes get mapped into the `/dev` tree under their volume group name, i.e. `/dev/vg-name/lv-name`, for example:

    # cd /dev/cylon
    # ls
    boomer  starbuck

They can be treated as a normal block device.

    # mkfs -t xfs boomer
    meta-data=boomer                 isize=256    agcount=4, agsize=32000 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=0        finobt=0
    data     =                       bsize=4096   blocks=128000, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
    log      =internal log           bsize=4096   blocks=853, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0

Mount the freshly minted `xfs` LVM logical volume:

    # mkdir /mnt/boomer && mount /dev/cylon/boomer /mnt/boomer
    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    /dev/mapper/cylon-boomer         497M   26M  472M   6% /mnt/boomer

### Removal of LVM artefacts

Lets teardown everything in reverse order, starting with logical volumes:

    # lvremove /dev/cylon/boomer
    Do you really want to remove active logical volume boomer? [y/n]: y
      Logical volume "boomer" successfully removed

    # lvremove /dev/cylon/starbuck
    Do you really want to remove active logical volume starbuck? [y/n]: y
      Logical volume "starbuck" successfully removed

Then the volume group:

    # vgremove cylon
      Volume group "cylon" successfully removed

Finally the physical volumes:

    # pvremove /dev/vdc1
      Labels on physical volume "/dev/vdc1" successfully wiped

    # pvremove /dev/vdd1
      Labels on physical volume "/dev/vdd1" successfully wiped

### Extending Logical Volumes

Growing LVM volumes just works.

    vgextend cylon /dev/vda4
    lgextend -L +20G /dev/cylon/toaster

Increasing the recognised storage increase to active mounts, it a matter of getting the specific file system involved, in this XFS:

    xfs_growfs /mnt/toaster

# Mount File Systems at Boot

For the demonstration, lets apply two different flavours of file system to a couple of block devices, [xfs](https://en.wikipedia.org/wiki/XFS) and [ext4](https://en.wikipedia.org/wiki/Ext4).

First ensure block devices have been partitioned, example:

    # gdisk /dev/vdd
    GPT fdisk (gdisk) version 0.8.6

    Command (? for help): n
    Partition number (1-128, default 1):
    First sector (34-2097118, default = 2048) or {+-}size{KMGTP}:
    Last sector (2048-2097118, default = 2097118) or {+-}size{KMGTP}:
    Current type is 'Linux filesystem'
    Hex code or GUID (L to show codes, Enter = 8300):
    Changed type of partition to 'Linux filesystem'

    Command (? for help): w

    Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
    PARTITIONS!!

    Do you want to proceed? (Y/N): Y
    OK; writing new GUID partition table (GPT) to /dev/vdd.
    The operation has completed successfully.

Make one of the partitions `xfs`:

    mkfs -t xfs -f /dev/vdd

And the other `ext4`:

    mkfs -t ext4 /dev/vdc

Lets verify the situation with `blkid`:

    # blkid
    /dev/vdb1: LABEL="boot" UUID="4302f187-5824-4799-980b-c816ae5b24e0" TYPE="xfs"
    /dev/vdc: UUID="1b7fe6d4-66f6-4fda-b971-489be9c68b36" TYPE="ext4"
    /dev/vdd: UUID="86c6cfe6-4cf4-4bb6-bec1-13a72d588896" TYPE="xfs"

### Labelling File Systems

_XFS_

Labelling is a file system specific capability. For example for `xfs` based systems, to write a label:

    # xfs_admin -L master-chief /dev/vdd
    writing all SBs
    new label = "master-chief"

To read label:

    # xfs_admin -l /dev/vdd
    label = "master-chief"

_Ext4_

For Ext4, to write a label:

    # tune2fs -L cortana /dev/vdc
    tune2fs 1.42.9 (28-Dec-2013)

To read label:

    # tune2fs -l /dev/vdc
    tune2fs 1.42.9 (28-Dec-2013)
    Filesystem volume name:   cortana

Finally `blkid` will attempt to query labels too:

    $blkid
    /dev/vdc: LABEL="cortana" UUID="1b7fe6d4-66f6-4fda-b971-489be9c68b36" TYPE="ext4"
    /dev/vdd: LABEL="master-chief" UUID="86c6cfe6-4cf4-4bb6-bec1-13a72d588896" TYPE="xfs"

# Auto Mounting

The file `/etc/fstab` contains descriptive information about the filesystems the system can mount. Each filesystem is described on a separate line. Fields on each line are separated by tabs or spaces. Lines starting with '#' are comments. Blank lines are ignored.

The following is a typical example of an fstab entry:

    LABEL=t-home2   /home      ext4    defaults,auto_da_alloc      0  2

Checkout `fstab(5)` and `mount(8)`. The fourth field **defaults** sets the following options:

-   `rw` read-write
-   `suid` allow suid or sgid bits to take effect
-   `dev` interpret character or block special devices on the filesystem
-   `exec` permit execution of binaries
-   `auto` can be mounted with the -a option
-   `nouser` forbid an ordinary (non-root) user to mount the filesystem
-   `async` all I/O should be done asynchonously

There are lots of other interesting options, such as:

> (lazytime) Only update times (atime, mtime, ctime) on the in-memory version of the file inode. This mount option significantly reduces writes to the inode table for workloads that perform frequent random writes to preallocated files.

The fifth field is known as the _dump field_, to flag which filesystems need to be dumped.

The sixth field, the _check disk field_, is used by `fsch(8)`, to determine the order in which filesystem checks are done at boot time. The root FS should be **1** and others to **2**. Default is to not check (0).

First up register the XFS block device `/dev/vdd` by its UUID. To find the UUID use `blkid`:

    # blkid
    /dev/vdb1: LABEL="boot" UUID="4302f187-5824-4799-980b-c816ae5b24e0" TYPE="xfs"
    /dev/vdb2: UUID="OCxtoT-4gVL-DPtV-Yfdp-uMXQ-JsRE-7fjFQ4" TYPE="LVM2_member"
    /dev/vdc: LABEL="cortana" UUID="1b7fe6d4-66f6-4fda-b971-489be9c68b36" TYPE="ext4"
    /dev/vdd: LABEL="master-chief" UUID="86c6cfe6-4cf4-4bb6-bec1-13a72d588896" TYPE="xfs"

We can see `/dev/vdd` UUID. Time to edit the `/etc/fstab`, by adding the following:

    UUID=86c6cfe6-4cf4-4bb6-bec1-13a72d588896 /mnt/master-chief   xfs defaults 0 0

Save, and ask `mount` to reparse `fstab` (using the `-a` switch) to take care of any new devices.

    # mount -a
    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    /dev/vdd                        1014M   33M  982M   4% /mnt/master-chief

`vdd` is now mounted at `/mnt/master-chief`. Boom!

Finally, let mount the Ext4 block device `/dev/vdc` by its label _cortana_:

    # blkid
    /dev/vdc: LABEL="cortana" UUID="1b7fe6d4-66f6-4fda-b971-489be9c68b36" TYPE="ext4"

Edit `/etc/fstab` again, adding the following:

    LABEL=cortana /mnt/cortana   ext4 defaults 0 0

Refresh:

    # mount -a
    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    /dev/vdd                        1014M   33M  982M   4% /mnt/master-chief
    /dev/vdc                         976M  2.6M  907M   1% /mnt/cortana

# Swap space

Swap space, or virtual memory, is fake memory the kernel provides when memory pressure is experienced, by buffering the most stale parts of memory out to swap disk (a block device). `free` shows current memory utilisation including swap.

    # free -m
                  total        used        free      shared  buff/cache   available
    Mem:            992         462         121           8         408         361
    Swap:           975           0         975

Some other useful ways to get current swap details:

    # swapon -s
    Filename        Type       Size    Used  Priority
    /dev/dm-1       partition  999420  0     -1
    /dev/vda1       partition  1047528 0     -2

Or:

    # cat /proc/swaps
    Filename        Type       Size    Used  Priority
    /dev/dm-1       partition  999420  0     -1
    /dev/vda1       partition  1047528 0     -2

One common rule of thumb for swap sizing, is double the amount of memory.

## Method 1 LVM

Chuck an LVM partition on your block device. I'm using `/dev/vda`, a 1GB block device I just attached to my VM.

    # gdisk /dev/vda
    GPT fdisk (gdisk) version 0.8.6

    Command (? for help): n
    Partition number (1-128, default 1):
    First sector (34-2097118, default = 2048) or {+-}size{KMGTP}:
    Last sector (2048-2097118, default = 2097118) or {+-}size{KMGTP}:
    Current type is 'Linux filesystem'
    Hex code or GUID (L to show codes, Enter = 8300): 8e00

    Command (? for help): w

    Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
    PARTITIONS!!

    Do you want to proceed? (Y/N): Y
    OK; writing new GUID partition table (GPT) to /dev/vda.
    The operation has completed successfully.

Now the LVM tango, create a physical volume (PV), a volume group (VG) and logical volume (LV).

    # pvcreate /dev/vda1
      Physical volume "/dev/vda1" successfully created
    # vgcreate quake /dev/vda1
      Volume group "quake" successfully created
    # lvcreate -n quake-swap -L 500M quake
      Logical volume "quake-swap" created.

`/dev/quake/quake-swap` has been born! Format it as swap:

    # mkswap /dev/quake/quake-swap
    Setting up swapspace version 1, size = 511996 KiB
    no label, UUID=af9378e2-3e60-4c3e-ba8c-1ae9a885b0a1

Before automounting it, verify it works by sparking it up with `swapon`:

    # swapon /dev/quake/quake-swap
    # free -m
                  total        used        free      shared  buff/cache   available
    Mem:            992         481          98           8         413         342
    Swap:          1475           0        1475

Notice swap just increased 500MB.

    # swapoff /dev/quake/quake-swap

Auto mount with `/etc/fstab`, by adding a similar entry. This could be device based, label based or UUID based, as demonstrated earlier.

    /dev/quake/quake-swap swap    swap defaults 0 0

To refresh auto mounting swap:

    # swapon -a

## Method 2 Block device

Partition the block device, this time as a _Linux swap_ partition.

    # gdisk /dev/vda
    GPT fdisk (gdisk) version 0.8.6

    Command (? for help): n
    Partition number (1-128, default 1):
    First sector (34-2097118, default = 2048) or {+-}size{KMGTP}:
    Last sector (2048-2097118, default = 2097118) or {+-}size{KMGTP}:
    Current type is 'Linux filesystem'
    Hex code or GUID (L to show codes, Enter = 8300): 8200
    Changed type of partition to 'Linux swap'

    Command (? for help): w

    Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
    PARTITIONS!!

    Do you want to proceed? (Y/N): Y
    OK; writing new GUID partition table (GPT) to /dev/vda.
    The operation has completed successfully.

Format time:

    # mkswap /dev/vda1
    Setting up swapspace version 1, size = 1047528 KiB
    no label, UUID=d5fb1252-f823-43ac-a8ea-bdd641e397b9

Test it:

    # swapon /dev/vda1
    # free -m
                  total        used        free      shared  buff/cache   available
    Mem:            992         501          92           8         398         309
    Swap:          1998           0        1998

Register it to automount. First locate the UUID of the block device:

    # blkid
    ....
    /dev/vda1: UUID="d5fb1252-f823-43ac-a8ea-bdd641e397b9" TYPE="swap" PARTLABEL="Linux swap" PARTUUID="1dfffa52-1454-493f-95ce-e84671ae161c"

And register it in `/etc/fstab`:

    UUID=d5fb1252-f823-43ac-a8ea-bdd641e397b9 swap    swap defaults 0 0

And do a full swap refresh:

    # swapoff -a
    # swapon -a
    # swapon -s
    Filename				Type		Size	Used	Priority
    /dev/dm-1                              	partition	999420	0	-1
    /dev/vda1                              	partition	1047528	0	-2

`umount -a` will unmount everything in `fstab`.

# File Systems (VFAT, EXT4 and XFS)

## VFAT

As an evolution to the earlier FAT (File Allocation Table), provides support for longer file names. It is backwards compatible with FAT, and is arguably the most ubiquitous file systems on the planet, supported by most operating systems, making it a good fit for interoperability between computers. To apply vfat to a block device:

    # mkfs.vfat /dev/vda1
    mkfs.fat 3.0.20 (12 Jun 2013)

Temporary mount:

    # mount /dev/vda1 /mnt/vfat
    # df -h
    Filesystem                       Size  Used Avail Use% Mounted on
    /dev/mapper/centos_server1-root  9.4G  6.7G  2.7G  72% /
    /dev/vda1                       1021M  4.0K 1021M   1% /mnt/vfat

Persistent mount (`/etc/fstab`):

    /dev/vda1 /mnt/vfat         vfat  defaults  0 0

To run a filesystem check (must be unmounted):

    fsck.vfat /dev/vda1

## EXT4

Born in 2008 the _fourth extended file system_ bought a number of performance and enhancements (such as greater storaeg limits) to predecessor _ext3_. The _ext_ family of filesystems are commonly managed using the [e2fsprogs](https://en.wikipedia.org/wiki/E2fsprogs) utilities. Some examples.

To create a new ext4 filesystem:

    # mkfs.ext4 /dev/vdb1
    mke2fs 1.42.9 (28-Dec-2013)
    Filesystem label=
    ...

To run an integrity (must be unmounted):

    fsck /dev/vdb1

`dumpe2fs` is useful for gathering information:

    # dumpe2fs /dev/vda2
    dumpe2fs 1.42.9 (28-Dec-2013)
    Filesystem volume name:   <none>
    Last mounted on:          <not available>
    Filesystem UUID:          10487788-2839-47be-a8fe-03573fba245c
    Filesystem magic number:  0xEF53
    Filesystem revision #:    1 (dynamic)
    Filesystem features:      has_journal ext_attr resize_inode dir_index filetype extent 64bit flex_bg sparse_super large_    file huge_file uninit_bg dir_nlink extra_isize
    Filesystem flags:         signed_directory_hash
    Default mount options:    user_xattr acl
    Filesystem state:         clean
    Errors behavior:          Continue
    Filesystem OS type:       Linux
    Inode count:              65536
    Block count:              261883
    Reserved block count:     13094
    Free blocks:              253024
    Free inodes:              65525
    First block:              0
    Block size:               4096
    Fragment size:            4096
    Group descriptor size:    64
    Reserved GDT blocks:      127
    Blocks per group:         32768
    Fragments per group:      32768
    Inodes per group:         8192
    Inode blocks per group:   512
    Flex block group size:    16
    Filesystem created:       Sun Nov 12 05:48:52 2017
    Last mount time:          n/a
    Last write time:          Sun Nov 12 05:48:52 2017
    Mount count:              0
    Maximum mount count:      -1
    Last checked:             Sun Nov 12 05:48:52 2017
    Check interval:           0 (<none>)
    Lifetime writes:          17 MB
    Reserved blocks uid:      0 (user root)
    Reserved blocks gid:      0 (group root)
    First inode:              11
    Inode size:               256
    Required extra isize:     28
    Desired extra isize:      28
    Journal inode:            8
    Default directory hash:   half_md4
    Directory Hash Seed:      8126fa63-b9e0-43e3-81d9-d8d7eb0c1986
    Journal backup:           inode blocks
    Journal features:         (none)
    Journal size:             16M
    Journal length:           4096
    Journal sequence:         0x00000001
    Journal start:            0


    Group 0: (Blocks 0-32767)
      Checksum 0xaa72, unused inodes 8181
      Primary superblock at 0, Group descriptors at 1-1
      Reserved GDT blocks at 2-128
      Block bitmap at 129 (+129), Inode bitmap at 145 (+145)
      Inode table at 161-672 (+161)
      28521 free blocks, 8181 free inodes, 2 directories, 8181 unused inodes
      Free blocks: 142-144, 153-160, 4258-32767
      Free inodes: 12-8192
    Group 1: (Blocks 32768-65535) [INODE_UNINIT]
      Checksum 0x4d1e, unused inodes 8192
      Backup superblock at 32768, Group descriptors at 32769-32769
      Reserved GDT blocks at 32770-32896
      Block bitmap at 130 (bg #0 + 130), Inode bitmap at 146 (bg #0 + 146)
      Inode table at 673-1184 (bg #0 + 673)
      32639 free blocks, 8192 free inodes, 0 directories, 8192 unused inodes
      Free blocks: 32897-65535
      Free inodes: 8193-16384
    Group 2: (Blocks 65536-98303) [INODE_UNINIT]
      Checksum 0x71c7, unused inodes 8192
      Block bitmap at 131 (bg #0 + 131), Inode bitmap at 147 (bg #0 + 147)
      Inode table at 1185-1696 (bg #0 + 1185)
      28672 free blocks, 8192 free inodes, 0 directories, 8192 unused inodes
      Free blocks: 69632-98303
      Free inodes: 16385-24576
    ...

`tune2fs` allows us to modify parameters, here we apply a label:

    # tune2fs -L darthvader /dev/vda2
    tune2fs 1.42.9 (28-Dec-2013)

## XFS

Born back in 1993 by Silicon Graphics, is a high performance (thanks to its parallel I/O design based on allocation groups) 64-bit journaling file system. It was ported to the Linux kernel in 2001. To create a new XFS filesystem:

    # mkfs.xfs -f /dev/vda1
    meta-data=/dev/vda1              isize=256    agcount=4, agsize=65471 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=0        finobt=0
    data     =                       bsize=4096   blocks=261883, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
    log      =internal log           bsize=4096   blocks=853, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0

Unlike _ext4_ which leans on the excellent `e2fsprogs` utils, XFS has its own variations of these which include: `xfs_admin`, `xfs_bmap`, `xfs_copy`, `xfs_db`, `xfs_estimate`, `xfs_freeze`, `xfs_fsr`, `xfs_growfs`, `xfs_info`, `xfs_io`, `xfs_logprint`, `xfs_mdrestore`, `xfs_metadump`, `xfs_mkfile`, `xfs_ncheck`, `xfs_quota`, `xfs_repair`, `xfs_rtcp`, `xfsdump`, `xfsinvutil`, `xfsrestore`

`xfs_info` for example provides information about a specific XFS filesystem:

    # xfs_info /dev/vda1
    meta-data=/dev/vda1              isize=256    agcount=4, agsize=65471 blks
             =                       sectsz=512   attr=2, projid32bit=1
             =                       crc=0        finobt=0
    data     =                       bsize=4096   blocks=261883, imaxpct=25
             =                       sunit=0      swidth=0 blks
    naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
    log      =internal               bsize=4096   blocks=853, version=2
             =                       sectsz=512   sunit=0 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0

To apply a label:

    # xfs_admin -L obiwan /dev/vda1
    xfs_admin: /dev/vda1 contains a mounted filesystem

    fatal error -- couldn't initialize XFS library

Oops, XFS must be unmounted in order to label it:

    # umount /mnt/xfs
    # xfs_admin -L obiwan /dev/vda1
    writing all SBs
    new label = "obiwan"

To run an XFS integrity check (must be unmounted):

    # xfs_repair /dev/vda1
    Phase 1 - find and verify superblock...
    Phase 2 - using internal log
            - zero log...
            - scan filesystem freespace and inode maps...
            - found root inode chunk
    Phase 3 - for each AG...
            - scan and clear agi unlinked lists...
            - process known inodes and perform inode discovery...
            - agno = 0
            - agno = 1
            - agno = 2
            - agno = 3
            - process newly discovered inodes...
    Phase 4 - check for duplicate blocks...
            - setting up duplicate extent list...
            - check for inodes claiming duplicate blocks...
            - agno = 0
            - agno = 1
            - agno = 2
            - agno = 3
    Phase 5 - rebuild AG headers and trees...
            - reset superblock...
    Phase 6 - check inode connectivity...
            - resetting contents of realtime bitmap and summary inodes
            - traversing filesystem ...
            - traversal finished ...
            - moving disconnected inodes to lost+found ...
    Phase 7 - verify and correct link counts...
    done
