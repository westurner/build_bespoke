

default: help

help:
	cat ./Makefile

PODMAN=podman
PODMAN_CMD=/bin/bash --login
PODMAN_ROOTLESS_OPTS=--security-opt=label=disable --userns=keep-id
PODMAN_OPTS=-e HOME=/workspace
PODMAN_RM=--rm
PODMAN_VOLUMES=-v "${HOME}/-wrk/-ve311/arts:/workspace" -v "${HOME}/-wrk/arts:${HOME}/-wrk/arts"


podman-build:
	${PODMAN} build -t westurner/bespokesynthsrc -f "Dockerfile.bespoke"

_podman-run:
	${PODMAN} run --rm -it westurner/bespokesynthsrc


PODMAN_CMD?=${PODMAN_CMD}
podman-run:
	$(PODMAN) run \
		${PODMAN_ROOTLESS_OPTS} \
		${PODMAN_VOLUMES} \
		${PODMAN_OPTS} \
		${PODMAN_RM} \
		-it westurner/bespokesynthsrc \
		${PODMAN_CMD}


podman-run-run:
	$(MAKE) podman-run PODMAN_CMD="/BespokeSynth/ignore/build/Source/BespokeSynth_artefacts/Release/BespokeSynth"
