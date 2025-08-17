

default: help

help:
	cat ./Makefile

PODMAN=podman
PODMAN_CMD=/bin/bash --login
PODMAN_ROOTLESS_OPTS=--security-opt=label=disable --userns=keep-id
PODMAN_OPTS=-e HOME=/workspace
PODMAN_RM=--rm
PODMAN_VOLUMES=-v "${HOME}/-wrk/-ve311/arts:/workspace" -v "${HOME}/-wrk/arts:${HOME}/-wrk/arts"
PODMAN_ARGS=

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
		${PODMAN_ARGS} \
		${PODMAN_RM} \
		-it westurner/bespokesynthsrc \
		${PODMAN_CMD}

podman-run-run:
	$(MAKE) podman-run PODMAN_CMD="/BespokeSynth/ignore/build/Source/BespokeSynth_artefacts/Release/BespokeSynth"


PODMAN_BUILD_USER=appuser


BS_REPO_URL=https://github.com/westurner/bespokesynth
BS_REPO_BRANCH=main

podman-run-buildbespoke:
	$(MAKE) podman-run PODMAN_ARGS='--user=root' PODMAN_CMD="sh -c 'sudo -u '$(PODMAN_BUILD_USER)' GIT_REPO_URL='$(BS_REPO_URL)' GIT_REPO_BRANCH='$(BS_REPO_BRANCH)' sh ./build_bespoke.sh -v all'"

