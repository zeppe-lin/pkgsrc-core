README hdparm

---


NOTES
=====

It is possible to make the ext3 filesystem reliable across power
failures for some hard disk types.  To do this, add the `barrier=1`
mount option to the appropriate entry in `/etc/fstab`.  To check if
the disk drive supports this option, run hdparm on the applicable disk
drive.  For example, if the following command returns non-empty
output, the option is supported:

    hdparm -I /dev/sda | grep NCQ

**IMPORTANT:**
The Logical Volume Management (LVM) based partitions cannot use the
barrier option.


---

End of file.
