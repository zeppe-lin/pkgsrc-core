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

To auto-load these, create a file such as:

```
/etc/modules-load.d/network.conf
```

with the needed module names.  This package does not install a default
config, since requirements vary by machine.

---

REFERENCES
==========

* Task-centered `iproute2` user guide:
  https://baturin.org/docs/iproute2/

---

End of file.
