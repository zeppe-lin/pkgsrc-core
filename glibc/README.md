README for glibc

---

LOCALES
=======

`glibc` does not contain locales (except `C.UTF-8`), thus you'll have
to generate the locales you need/use.  The following example is a
typical setup:

```sh
# as root
localedef -i en_US -f UTF-8 en_US.UTF-8
```

After that, add `export LANG=en_US.UTF-8` to `/etc/profile`.

---

End of file.
