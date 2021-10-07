# Unbound
 This Docker images is an Unbound DNS server container. The Unbound is a validating, recursive, and caching DNS resolver.  Please refer to the link for more detail about the Unbound: https://www.unbound.net/

# Requirements

- docker
- packer
- make

# How to use

1. image build
```
$ make 
```
2. start unbound container
```
$ docker run -d --name unbound -p 53:53/tcp -p 53:53/udp autechgemz/unbound
```

