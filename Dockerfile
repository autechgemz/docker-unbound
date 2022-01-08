FROM alpine:latest

ENV TZ="Asia/Tokyo"

ARG UNBOUND_VERSION="1.14.0"
ARG UNBOUND_ROOT=/chroot
ARG UNBOUND_CONFDIR=/etc/unbound
ARG UNBOUND_DATADIR=/var/unbound
ARG UNBOUND_USER=unbound

ENV PATH="${UNBOUND_ROOT}/sbin:${UNBOUND_ROOT}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${UNBOUND_ROOT}/lib"

RUN apk update \
 && apk upgrade --update --available \
 && apk add --no-cache \
    build-base \
    linux-headers \
    automake \
    autoconf \
    libtool \
    tar \
    curl \
    tini \
    tzdata \
    drill \
    libevent-dev \
    expat-dev \
    openssl \
    openssl-dev \
    libgcc \
    nghttp2-dev \
    dnssec-root \
 && addgroup -S $UNBOUND_USER \
 && adduser -S -D -H -h $UNBOUND_ROOT -s /sbin/nologin -G $UNBOUND_USER $UNBOUND_USER \
 && mkdir -p $UNBOUND_ROOT \
 && curl https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz -o ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION}.tar.gz \
 && cd ${UNBOUND_ROOT} \
 && tar zxvf unbound-${UNBOUND_VERSION}.tar.gz \
 && cd ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION} \
 && ./configure \
    --prefix=${UNBOUND_ROOT} \
    --with-username=${UNBOUND_USER} \
    --with-run-dir="" \
    --with-pidfile="" \
    --localstatedir=/var \
    --with-rootkey-file=/usr/share/dnssec-root/trusted-key.key \
    --with-libevent \
    --with-pthreads \
    --disable-static \
    --disable-rpath \
    --with-ssl \
    --without-pythonmodule \
    --without-pyunbound \
    --disable-systemd \
    --with-libnghttp2 \
 && make \
 && make install \
 && make dohclient \
 && mkdir -p ${UNBOUND_ROOT}/bin \
 && cp -fp ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION}/dohclient ${UNBOUND_ROOT}/bin/dohclient \
 && chmod 0755 ${UNBOUND_ROOT}/bin/dohclient \
 && chown root.root ${UNBOUND_ROOT}/bin/dohclient \
 && rm -rf ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION} \
 && rm -f ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION}.tar.gz \
 && rm -rf ${UNBOUND_ROOT}/share \
 && apk del --no-cache --purge \
    build-base \
    linux-headers \
    automake \
    autoconf \
    libtool \
    tar \
    curl \
 && mkdir -p ${UNBOUND_ROOT}/dev \
 && mknod ${UNBOUND_ROOT}/dev/random c 1 8 \
 && mknod ${UNBOUND_ROOT}/dev/null c 1 3 \
 && mkdir -p ${UNBOUND_ROOT}/var/unbound \
 && chown ${UNBOUND_USER}.${UNBOUND_USER} ${UNBOUND_ROOT}/var/unbound \
 && cp -fp /usr/share/dnssec-root/trusted-key.key ${UNBOUND_ROOT}/var/unbound/root.key \
 && chown ${UNBOUND_USER}.${UNBOUND_USER} ${UNBOUND_ROOT}/var/unbound/root.key

COPY files${UNBOUND_CONFDIR} ${UNBOUND_ROOT}${UNBOUND_CONFDIR}/
COPY files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["${UNBOUND_ROOT}/${UNBOUND_CONFDIR}", "${UNBOUND_ROOT}/${UNBOUND_DATADIR}"]

EXPOSE 53/tcp 53/udp 443/tcp

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
