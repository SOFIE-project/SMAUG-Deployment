all: build

build:
	docker-compose build

test:

clean:
	docker-compose rm -f

.PHONY: all build test clean
