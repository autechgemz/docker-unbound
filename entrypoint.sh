#!/bin/sh

TRUST_ANCHOR=/usr/share/dnssec-root/trusted-key.key

if [ -e $TRUST_ANCHOR ]; then
  /usr/sbin/unbound-anchor -v
fi

/usr/sbin/rsyslogd && exec /usr/sbin/unbound -d
