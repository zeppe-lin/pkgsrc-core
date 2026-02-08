README for iproute2

---

REQUIREMENTS
============

Kernel Module
-------------

Some rc.d scripts (e.g., `/etc/rc.d/bridge`) may require additional
modules depending on your setup:

```sh
# Universal TUN/TAP device driver
tun

# TAP device driver
tap

# Host kernel accelerator for virtio
vhost
```

To auto-load these on boot:

- Declarative: add needed modules to
  `/etc/modules-load.d/network.conf`
- Imperative: add `/sbin/modprobe <module>` to `/etc/rc.modules` for
  each required module

---

REFERENCES
==========

* Task-centered `iproute2` user guide:
  https://baturin.org/docs/iproute2/

---

End of file.
