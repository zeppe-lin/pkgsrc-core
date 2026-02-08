README for iproute2

---

REQUIREMENTS
============

Kernel Module
-------------

`/etc/rc.d/bridge` may require additional modules, depending on your
setup:

```sh
# Universal TUN/TAP device driver
tun

# TAP device driver
tap

# Host kernel accelerator for virtio
vhost
```

To auto-load required modules on boot:
- Add module names to `/etc/modules-load.d/*.conf` (one per line), or
- Add `/sbin/modprobe <module>` lines to `/etc/rc.modules`.

This package does not install a default config; administrators should
add modules as needed by their hardware or usage.

---

REFERENCES
==========

* Task-centered `iproute2` user guide:
  https://baturin.org/docs/iproute2/

---

End of file.
