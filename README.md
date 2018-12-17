# Unbound
 This Docker images is an Unbound DNS server container. The Unbound is a validating, recursive, and caching DNS resolver.  Please refer to the link for more detail about the Unbound: https://www.unbound.net/
# How to use
1. clone the repo
2. update local_data.hosts and convert local_data.conf, if you need it  
```
$ vi local_data.hosts
$ ./local_data.py  
```
3. image build
```
$ docker build -t autechgemz/unbound .
```
4. start unbound container
```
$ docker run -d --name unbound -p 53:53/tcp -p 53:53/udp autechgemz/unbound
```

