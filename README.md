# pwn.college helper environment for kernel development and exploitation

Building the kernel, busybox, and demo modules entirely using Docker:

```
$ ./build.sh
```

Running the kernel:

```
$ ./launch.sh
```

All modules will be in `/`, ready to be `insmod`ed, and the `$HOME/pwnkernel/` will be mounted as `/home/ctf` in the guest.
