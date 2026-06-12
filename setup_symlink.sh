#!/bin/sh

set -x
musicpath=/workspace/src/arts/bespoke/savestate
container_home=/home/appuser
container_savestate=/home/appuser/Documents/BespokeSynth/savestate

ln -s "${musicpath}" "${container_savestate}"
