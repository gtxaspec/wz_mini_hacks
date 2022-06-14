# build

two environments:

## atomcam tools (first)

`git clone https://github.com/mnakada/atomcam_tools`

`cd atomcam_tools`

`make`

then wait a long time for the development environment to compile and complete.

After its complete, run `docker-compose up -d` to start the docker instance.  

To resume the instance, get the container ID from `docker ps`, and use `docker exec -it <container_Id> /bin/bash`

the following is translated from: [https://github.com/mnakada/atomcam_tools/blob/71a1214f83a92704221cedcf5101e12ba40f2f38/build.md?plain=1#L200](https://github.com/mnakada/atomcam_tools/blob/71a1214f83a92704221cedcf5101e12ba40f2f38/build.md?plain=1#L200)



###  Docker environment
In the Docker environment, / src is mapped to atomcam_tools /.

Below, basically the commands in Docker are executed from the following Directory.

```
root@ac0375635c01: / atomtools # cd / atomtools / build / buildroot -2016.02
```

rootfs uses gcc in Docker in a glibc environment.
Gcc is also generated during build.
gcc prefix is
** / atomtools / build / buildroot-2016.02 / output / host / usr / bin / mipsel-ingenic-linux-gnu-**
is.

ATOM Cam's original system camera app iCamera_app is built in the uClibc environment.

Therefore, uClibc environment is required to build libcallback.so for hack of iCamera_app, so it is cloned separately.
** / atomtools / build / mips-gcc472-glibc216-64bit / bin / mips-linux-uclibc-gnu-**
using.



###  How to build when making various changes

When changing the config of initramfs and kernel

```
root @ ac0375635c01: / atomtools # make linux-rebuild
root@ac0375635c01: / atomtools # cp output / images / uImage.lzma /src
```

Will be built with and copied to atomcam_tools /.

---


If you modify the files in rootfs or the menuconfig of busybox
```
root@ac0375635c01: / atomtools # make
root@ac0375635c01: / atomtools # cp output / images / rootfs.ext2 /src
```

Will be built with and copied to atomcam_tools /.


Copy it to the SD Card with the names factory_t31_ZMC6tiIDQN and rootfs_hack.ext2 respectively.

---

If you change the package included in rootfs

```
root @ ac0375635c01: / atomtools # make menuconfig
root @ ac0375635c01: / atomtools # make
```

Will build rootfs.

---

For individual package rebuilds

```
root @ ac0375635c01: / atomtools # make < package > -rebuild
```

---

When changing settings such as busybox commands

```
root @ ac0375635c01: / atomtools # make busybox-menuconfig
root @ ac0375635c01: / atomtools # make
```

Will build rootfs.


---

When changing kernel settings

```
root @ ac0375635c01: / atomtools # make linux-menuconfig
root @ ac0375635c01: / atomtools # make linux-rebuild
```

Will generate uImage.lzma.

----

## buildroot (second)

download `https://buildroot.org/downloads/buildroot-2022.05.tar.xz`

run `make menuconfig`

options should be:

- Target Options:
   - Target Architecture
     - MIPS (little endian)
   - Target Architecture Variant
     - Generic MIPS32R2
   - FP Mode
     - 32

- Build Options:
  - Strip Target Binaries [*]
  - Libraries
    - static only ( you can do dynamic if you like, just remember you have to copy ALL the program's required libararies to the device! )



- Toolchain
  - C library:
    - musl (you can also use uClibc-ng if you prefer)
    - Kernel Headers
      - Manually Specified Linux Version
        - 3.10.98
    - Custom Kernel Headers Series
        - 3.10.x
     - Binutils Version
        - 2.36.1
     - GCC Compiler Version
        - gcc 9.x
     - Enable C++ Support [*]
     - Enable compiler link-time-optimization support [*]
   
 - Target packages
   - Whatever packages you want!

Then select exit, save changes, and then run `make` and your compiled programs should be in `output/target/usr/`


