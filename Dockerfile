FROM alpine:latest

ENV TZ Asia/Tokyo

RUN apk upgrade --update --available && \
    apk add --no-cache \
    tzdata \
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && apk add --no-cache \
    tzdata \
    python \
    tini \
    rsyslog \
    unbound \
    py-unbound \
    drill \
 && rm -rf /var/cache/apk/*

COPY rsyslog.conf /etc/rsyslog.conf
COPY unbound.conf /etc/unbound/unbound.conf
COPY acl.conf /etc/unbound/acl.conf
COPY local_data.conf /etc/unbound/local_data.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
