FROM alpine:latest

ARG LOCALTIME="Asia/Tokyo"

ARG UNBOUND_VERSION="1.14.0"
ARG UNBOUND_ROOT=/chroot
ARG UNBOUND_CONFDIR=/etc/unbound
ARG UNBOUND_DATADIR=/var/unbound
ARG UNBOUND_USER=unbound

ENV GOPATH="${UNBOUND_ROOT}"
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
    git \
    tar \
    go \
    curl \
    tzdata \
    runit \
    su-exec \
    drill \
    libevent-dev \
    fstrm-dev \
    protobuf-c-dev \
    openssl-dev \
    expat-dev \
    ldns-dev \
    libxml2-dev \
    libgcc \
    openssl \
    nghttp2-dev \
    swig \
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
    --enable-dnstap \
    --with-libnghttp2 \
 && make \
 && make install \
 && make dohclient \
 && mkdir -p ${UNBOUND_ROOT}/bin \
 && cp -fp ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION}/dohclient ${UNBOUND_ROOT}/bin/dohclient \
 && chmod 0755 ${UNBOUND_ROOT}/bin/dohclient \
 && chown root.root ${UNBOUND_ROOT}/bin/dohclient \
 && cd ${UNBOUND_ROOT} \
 && go get -u -v github.com/dnstap/golang-dnstap \
 && go get -u -v github.com/dnstap/golang-dnstap/dnstap \
 && go get -u -v github.com/farsightsec/golang-framestream \
 && cd / \
 && rm -rf ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION} \
 && rm -f ${UNBOUND_ROOT}/unbound-${UNBOUND_VERSION}.tar.gz \
 && rm -rf ${UNBOUND_ROOT}/src \
 && rm -rf ${UNBOUND_ROOT}/pkg \
 && rm -rf ${UNBOUND_ROOT}/share \
 && apk del --no-cache --purge \
    build-base \
    linux-headers \
    automake \
    autoconf \
    libtool \
    git \
    tar \
    go \
    curl \
    swig \
    protobuf-c-compiler \
 && mkdir -p ${UNBOUND_ROOT}/dev \
 && mknod ${UNBOUND_ROOT}/dev/random c 1 8 \
 && mknod ${UNBOUND_ROOT}/dev/null c 1 3 \
 && mkdir -p ${UNBOUND_ROOT}/var/run \
 && chown ${UNBOUND_USER}.${UNBOUND_USER} ${UNBOUND_ROOT}/var/run \
 && mkdir -p ${UNBOUND_ROOT}/var/unbound \
 && chown ${UNBOUND_USER}.${UNBOUND_USER} ${UNBOUND_ROOT}/var/unbound \
 && cp -fp /usr/share/dnssec-root/trusted-key.key ${UNBOUND_ROOT}/var/unbound/root.key \
 && chown ${UNBOUND_USER}.${UNBOUND_USER} ${UNBOUND_ROOT}/var/unbound/root.key \
 && ln -sf /usr/share/zoneinfo/${LOCALTIME} /etc/localtime

COPY files${UNBOUND_CONFDIR} ${UNBOUND_ROOT}${UNBOUND_CONFDIR}/
COPY files/services /services
RUN chmod +x /services/*/run

VOLUME ["${UNBOUND_ROOT}/${UNBOUND_CONFDIR}", "${UNBOUND_ROOT}/${UNBOUND_DATADIR}"]

EXPOSE 53/tcp 53/udp 443/tcp

ENTRYPOINT ["/sbin/runsvdir", "-P", "/services/"]
