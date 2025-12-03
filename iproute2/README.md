README iproute2

---


KERNEL MODULES
==============

To autoload modules required by `/etc/rc.d/bridge`, add these lines to
`/etc/rc.modules`:

    # Universal TUN/TAP device drivers
    /sbin/modprobe tun
    /sbin/modprobe tap

    # Host kernel accelerator for virtio
    /sbin/modprobe vhost


REFERENCES
==========

* Task-centered `iproute2` user guide:
  https://baturin.org/docs/iproute2/


---

End of file.
