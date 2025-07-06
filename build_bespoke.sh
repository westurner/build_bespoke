#!/bin/sh

# Build bespokesynth from source on Fedora
#
# Authors:
# - @westurner

# Usage:
#
#  build_bespoke.sh
#
#  DO_GIT_CLONE=1 build_bespoke.sh
#  DO_GIT_CLONE=1 SOURCE_URL=${SOURCE_URL_westurner} build_bespoke.sh

# DO_GIT_CLONE: whether to git clone if a BespokeSynth/ dir doesn't exist
export DO_GIT_CLONE=${DO_GIT_CLONE}

# SOURCE_URL: replace this with your fork if you forked
export SOURCE_URL="https://github.com/BespokeSynth/BespokeSynth"
export SOURCE_URL_westurner="https://github.com/westurner/BespokeSynth"

update_grubby_and_rpmostree() {
    type -a grubby && sudo grubby --args="preempt=full" --update-kernel=ALL
    type -a rpm-ostree && sudo rpm-ostree kargs --append=
    exit
}


if [ "$(id -u)" -eq 0 ]; then
    sudo dnf install -y cmake clang python3-devel alsa-lib-devel freetype-devel mesa-libGL-devel libcurl-devel webkit2gtk4.0-devel gtk+-devel pipewire-jack-audio-connection-kit-devel
else
    echo "Skipping dnf install because running as non-root"
fi


if [ ! -d "BespokeSynth" ] && [ ! -z "${DO_GIT_CLONE}" ]; then
    git clone https://github.com/BespokeSynth/BespokeSynth && \
        cd BespokeSynth && \
        git submodule update --init --recursive
fi


_mv_cmake_cache_file() {
    local cmakecache=$1
    test ! -n "${cmakecache}" && echo "Error: path must be specified" && return 2
    test -f "${cmakecache}" && \
        mv "${cmakecache}" "${cmakecache}.bkp-$(date -Is).txt"
}

_mv_cmake_cache_file "BespokeSynth/ignore/build/CMakeCache.txt"
_mv_cmake_cache_file "BespokeSynth/ignore/build/JUCE/tools/CMakeCache.txt"


cd BespokeSynth/
cmake -Bignore/build -DCMAKE_BUILD_TYPE=Release
cmake --build ignore/build --parallel 4 --config Release
