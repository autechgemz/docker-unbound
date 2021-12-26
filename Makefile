all: image
image:
	docker build -t autechgemz/unbound .
full:
	docker build --no-cache -t autechgemz/unbound .
push:
	docker push autechgemz/unbound
clean:
	docker-compose down
	docker rm -v unbound
distclean:
	docker-compose down -v
	docker rmi autechgemz/unbound
