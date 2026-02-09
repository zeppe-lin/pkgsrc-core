#!/bin/sh
URL=https://raw.githubusercontent.com/NetBSD/src/refs/heads/trunk/usr.bin
curl -LO $URL/c89/c89.1
curl -LO $URL/c89/c89.sh
sed -i 's/\(compile errors are prefixed by\) "cc:"\./\1\n.Dq cc: ./' c89.1
