all: image config
image:
	packer build baseimage.json
config:
	packer build container.json
push:
	docker push autechgemz/unbound
clean:
	docker-compose down
	docker rm -v unbound
distclean:
	docker-compose down -v
	docker rmi autechgemz/unbound-baseimage
	docker rmi autechgemz/unbound
