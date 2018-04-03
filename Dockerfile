FROM alpine:latest

LABEL maintainer "Kenji Tsumaki <autechgemz@gmail.com>"

RUN apk upgrade --update --available && \
    apk add --no-cache \
    python \
    runit \
    rsyslog \
    unbound \
    py-unbound \
    drill

COPY rsyslog.conf /etc/rsyslog.conf
COPY unbound.conf /etc/unbound/unbound.conf
COPY acl.conf /etc/unbound/acl.conf
COPY local_data.conf /etc/unbound/local_data.conf

COPY service /service
RUN chmod 755 /service/*/run

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["runsvdir", "-P", "/service/"]
