#!/usr/bin/env sh

ROOT_DIR=/chroot

if grep '^[[:space:]]*control-enable:[[:space:]]*yes' ${ROOT_DIR}/etc/unbound/unbound.conf > /dev/null 2>&1 ; then
  if [ $(find ${ROOT_DIR}/etc/unbound/ -type f -name *.key -or -name *.pem -maxdepth 1| wc -l) -eq 0 ] ; then
     ${ROOT_DIR}/sbin/unbound-control-setup 2> /dev/null
  fi
fi

if grep '^[[:space:]]*auto-trust-anchor-file:' \
	${ROOT_DIR}/etc/unbound/unbound.conf > /dev/null 2>&1; then
  ${ROOT_DIR}/sbin/unbound-anchor -v -a ${ROOT_DIR}/var/unbound/root.key 2> /dev/null \
	  || chown unbound.unbound ${ROOT_DIR}/var/unbound/root.key
fi

exec ${ROOT_DIR}/sbin/unbound -d -p
