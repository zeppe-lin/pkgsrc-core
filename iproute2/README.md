README iproute2

---


KERNEL MODULES
==============

Add the following lines to `/etc/rc.modules` to autoload modules needed by
`/etc/rc.d/bridge`:

```sh
# Universal TUN/TAP device drivers.
/sbin/modprobe tun
/sbin/modprobe tap

# Host kernel accelerator for virtio.
/sbin/modprobe vhost
```


ONLINE DOCUMENTATION
====================

* Task-centered iproute2 user guide:
  https://baturin.org/docs/iproute2/


---

End of file.
