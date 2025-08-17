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


install_packages() {
    sudo dnf install -y cmake clang python3-devel alsa-lib-devel freetype-devel mesa-libGL-devel libcurl-devel webkit2gtk4.0-devel gtk+-devel pipewire-jack-audio-connection-kit-devel libusb1-devel
}

_mv_cmake_cache_file() {
    local cmakecache=$1
    test ! -n "${cmakecache}" && echo "Error: path must be specified" && return 2
    test -f "${cmakecache}" && \
        mv "${cmakecache}" "${cmakecache}.bkp-$(date -Is).txt"
}

__THIS=$0
print_usage() {
    echo "${__THIS} -- Build Bespokesynth"
    echo ""
    echo " -h,--help,help   Print help"
    echo " -v,--verbose     set -x -v"
    echo ""
    echo " --install, install    Install packages necessary to build"
    echo " --install-only        Only install packages necessary to build and then exit"
    echo " --install-kernel-args update kernel args (with grubby and rpmostree)"
    echo " --clone, clone        Clone BespokeSynth"
    echo " --mv-cmake-cache      mv cmake build cache dirs   " # TODO: clean
    echo " --build, build        Build BespokeSynth"
    echo " all, --all            Run all tasks"
    echo ""
    echo " --allow-build-as-root Run git clone and make build as root"
}

main() {
    if [ -z "${*}" ]; then
        print_usage
    fi
    for arg in "${@}"; do
        case "$arg" in
            -h|--help|help)
                print_usage
                exit 0
                ;;
            -v|--verbose)
                set -x -v
                ;;
            --install|install)
                export DO_INSTALL=1
                ;;
            --install-kernel-args|install-kernel-args|install-kargs)
                export DO_INSTALL_KERNEL_ARGS=1
                ;;
            --install-only|install-only)
                export DO_INSTALL_ONLY=1
                ;;
            --clone|clone)
                export DO_GIT_CLONE=1
                ;;
            --mv-cmake-cache)
                export DO_MV_CMAKE_CACHE_FILE=1
                ;;
            --build|build)
                export DO_BUILD=1
                ;;
            --allow-build-as-root)
                export DO_ALL_AS_ROOT=1
                ;;
            all|--all)
                export DO_ALL=1
                export DO_INSTALL_KERNEL_ARGS=1
                export DO_INSTALL=1
                export DO_INSTALL_ONLY=0
                export DO_GIT_CLONE=1
                export DO_MV_CMAKE_CACHE_FILE=1
                export DO_BUILD=1
                ;;
        esac
    done

    export GIT_REPO_URL="${GIT_REPO_URL:-"https://github.com/BespokeSynth/BespokeSynth"}"
    export GIT_REPO_BRANCH="${GIT_REPO_BRANCH:-""}"


    if [ "$(id -u)" -eq 0 ]; then
        if [ -n "${DO_ALL}" ]; then
            if [ -z "${DO_ALL_AS_ROOT}" ]; then
                echo "INFO: --allow-build-as-root was not specified. Not building as root."
                export DO_INSTALL_KERNEL_ARGS=1
                export DO_INSTALL_ONLY=1
            else
                echo "INFO: DO_ALL_AS_ROOT=1"
            fi
        fi
    fi

    if [ "$(id -u)" -eq 0 ]; then
        if [ -n "${DO_INSTALL_KERNEL_ARGS}" ]; then
            echo "INFO: update kernel args with grubby and rpmostree"
            update_grubby_and_rpmostree
        fi

        if  [ -n "${DO_INSTALL_ONLY}" ] || [ -n "${DO_INSTALL}" ]; then
            echo "INFO: update kernel args with grubby and rpmostree"
            install_packages
        fi
    fi

    if [ -n "${DO_GIT_CLONE}" ] && [ ! -d "bespokesynth/" ] ; then
        (git clone "${GIT_REPO_URL}" ${GIT_REPO_BRANCH:+"-b"} "${GIT_REPO_BRANCH:+"${GIT_REPO_BRANCH}"}" && \
            cd bespokesynth/ && \
            git submodule update --init --recursive)
    fi


    if [ -n "${DO_BUILD}" ] || [ -n "${DO_MV_CMAKE_CACHE_FILE}" ]; then
        (cd bespokesynth/;
        _mv_cmake_cache_file "BespokeSynth/ignore/build/CMakeCache.txt"; 
        _mv_cmake_cache_file "BespokeSynth/ignore/build/JUCE/tools/CMakeCache.txt";)
    fi

  

    if [ -n "${DO_BUILD}" ];  then
        (cd bespokesynth/;
        cmake -Bignore/build -DCMAKE_BUILD_TYPE=Release;
        cmake --build ignore/build --parallel 4 --config Release;)
    fi
}

main "${@}"
