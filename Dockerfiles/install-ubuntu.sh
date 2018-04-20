#!/bin/bash
set -e

# parse command line arguments

shared=false
cuda=false

orig=$@
for key in "$@"; do
    key="$1"
    case $key in
        --shared)
        shared=true
        shift
        ;;
        --cuda)
        cuda=true
        shift
        ;;
    esac
done

# add repository with recent versions of compilers
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get -y clean

# install requirements
apt-get -y update
apt-get -y install \
  build-essential \
  curl \
  git \
  cmake \
  unzip \
  autoconf \
  autogen \
  libtool \
  mlocate \
  zlib1g-dev \
  g++-6 \
  python \
  python3-numpy \
  python3-dev \
  python3-pip \
  python3-wheel \
  wget

if $shared; then
    # install bazel for the shared library version
    apt-get -y update \
    && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    bash-completion \
    g++ \
    zlib1g-dev \
    && curl -LO "https://github.com/bazelbuild/bazel/releases/download/0.11.1/bazel_0.11.1-linux-x86_64.deb" \
    && dpkg -i bazel_*.deb
fi
if $cuda; then
    # install libcupti
    apt-get -y install cuda-command-line-tools-9-1
fi

apt-get -y clean

# when building TF with Intel MKL support, `locate` database needs to exist
updatedb

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$orig"
