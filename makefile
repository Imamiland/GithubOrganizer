SHELL:=/bin/bash
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: dependencies

venv:
	if [ ! -d $(ROOT_DIR)/env ]; then python3 -m venv $(ROOT_DIR)/env; fi

dependencies: venv
	source $(ROOT_DIR)/env/bin/activate; pip install --upgrade pip; python -m pip install wheel; yes w | python -m pip install -e .

upgrade_dependencies: venv
	source $(ROOT_DIR)/env/bin/activate; ./bin/upgrade_dependencies.sh $(ROOT_DIR)/requirements.txt

clean:
	rm -Rf $(ROOT_DIR)/env

cleanenv:
	docker-compose down

testenv: cleanenv
	docker-compose up --build

container_build:
	docker build --no-cache -f docker/dockerfile.worker -t tedivm/github_organizer_worker:latest .
	docker build --no-cache -f docker/dockerfile.www -t tedivm/github_organizer_www:latest .

container_push: container_build
	docker push tedivm/github_organizer_worker:latest
	docker push tedivm/github_organizer_www:latest
