
## build_bespoke Makefile for building BespokeSynth

.PHONY: default help \
	build podman-build \
	_podman-run podman-run podman-run-run \
	podman-run-buildbespoke podman-run-buildbespoke-westurner \
	nvidia-ctk-cdi-generate

default: help

help:
	cat ./Makefile

###

build:
	sh ./build_bespoke.sh --build

###

PODMAN=podman
PODMAN_CMD=/bin/bash --login
PODMAN_ROOTLESS_OPTS=--security-opt=label=disable \
					 --userns=keep-id --user=appuser \
					 --group-add keep-groups

PODMAN_AUDIO_OPTS=--device /dev/snd \
	-v /run/user/$(shell id -u)/pipewire-0:/tmp/pipewire-0 \
	-e XDG_RUNTIME_DIR=/tmp

PODMAN_OPTS=-e HOME=/workspace \
                --net=host \
                --ipc=host \
                --device nvidia.com/gpu=all \
                --device /dev/dri/card0 \
                --device /dev/dri/renderD129 \
                --device /dev/dri/card1 \
                --device /dev/dri/renderD128 \
				-v ${XAUTHORITY}:/root/.Xauthority:ro \
				-v ${XAUTHORITY}:/home/appuser/.Xauthority:ro \
				-v ${XAUTHORITY}:${XAUTHORITY}:ro \
                -e DISPLAY \
				-e HOME="/home/appuser" \
                -v /tmp/.X11-unix:/tmp/.X11-unix:rw


PODMAN_RM=--rm

PODMAN_VOLUMES_BUILD=
#PODMAN_VOLUMES_BUILD=-v ${PWD}/BespokeSynth:/home/appuser/BespokeSynth

# NOTE: this doesn't work: 
# PODMAN_ARGS_BUILD=--userns=keep-id --security-opt=label=disable 

PODMAN_VOLUMES_EXTRA=
PODMAN_VOLUMES=-v "${HOME}/-wrk/-ve311/arts:/workspace" -v "${HOME}/-wrk/arts:${HOME}/-wrk/arts" $(PODMAN_VOLUMES_EXTRA)
PODMAN_ARGS=

CONTAINER_NAME=westurner/bespokesynthsrc
CONTAINER_NAME=westurner/bespokesynthsrc:43


podman-build:
	${PODMAN} build -t ${CONTAINER_NAME} -f "Dockerfile.bespoke" ${PODMAN_VOLUMES_BUILD} # ${PODMAN_ARGS_BUILD}

_podman-run:
	${PODMAN} run --rm -it ${CONTAINER_NAME}


PODMAN_CMD?=${PODMAN_CMD}
podman-run:
	$(PODMAN) run \
		${PODMAN_ROOTLESS_OPTS} \
		${PODMAN_VOLUMES} \
		${PODMAN_OPTS} \
		${PODMAN_AUDIO_OPTS} \
		${PODMAN_ARGS} \
		${PODMAN_RM} \
		-it ${CONTAINER_NAME} \
		${PODMAN_CMD}

BS_ARGS=
BS_FILE=
BS_BIN_PATH=/workspace/src/arts/build_bespoke/BespokeSynth/ignore/build/Source/BespokeSynth_artefacts/Release/BespokeSynth
podman-run-run:
	$(MAKE) podman-run \
		PODMAN_CMD="sh -c 'set -x; pwd; \
sleep 5; \
ln -s /workspace/src/arts/bespoke/savestate /home/appuser/Documents/BespokeSynth/savestate; \
ls -al /workspace/src/arts/bespoke/savestate /home/appuser /home/appuser/Documents/BespokeSynth/savestate; \
${BS_BIN_PATH} ${BS_ARGS} ${BS_FILE}'"


PODMAN_BUILD_USER=appuser


BS_REPO_URL_origin=https://github.com/bespokesynth/bespokesynth
BS_REPO_URL_westurner=https://github.com/westurner/bespokesynth

BS_REPO_URL=${BS_REPO_URL_origin}
BS_REPO_BRANCH=main

podman-run-buildbespoke:
	$(MAKE) podman-run \
		PODMAN_VOLUMES_EXTRA='-v $(PWD)/BespokeSynth:/home/appuser/BespokeSynth' \
		PODMAN_ARGS='--user=root' \
		PODMAN_CMD="sh -c 'sudo -u '$(PODMAN_BUILD_USER)' \
			GIT_REPO_URL='$(BS_REPO_URL)' \
			GIT_REPO_BRANCH='$(BS_REPO_BRANCH)' \
			sh ./build_bespoke.sh -v all'"

podman-run-buildbespoke-westurner:
	$(MAKE) podman-run \
		PODMAN_VOLUMES_EXTRA='-v $(PWD)/BespokeSynth:/home/appuser/BespokeSynth' \
		PODMAN_ARGS='--user=root' \
		PODMAN_CMD="sh -c 'sudo -u '$(PODMAN_BUILD_USER)' \
			GIT_REPO_URL='$(BS_REPO_URL_westurner)' \
			GIT_REPO_BRANCH='$(BS_REPO_BRANCH)' \
			sh ./build_bespoke.sh -v all'"

nvidia-ctk-cdi-generate:
	@echo "# Build /etc/cdi/nvidia.yaml so that `--device nvidia.com/gpu=all` works"
	sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
	#sudo nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
