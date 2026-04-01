# walnut/justfile

sdk_path := "duo-buildroot-sdk-v2"
target := "milkv-duo256m-glibc-arm64-sd"
docker_image := "milkvtech/milkv-duo@sha256:63d71ea6fb2c2fb23ee34b68892ace67ed8a0c66954ed47b5cb793443fead679"
abs_sdk_path := justfile_directory() / sdk_path

setup:
    @echo "🚀 Syncing SDK submodule..."
    git submodule update --init --recursive --depth 1

build: setup
    @echo "🔨 Building for Milk-V Duo {{ target }}..."
    set -o pipefail && \
        docker run --rm -it \
        --user root \
        -v "{{ abs_sdk_path }}:/home/work" \
        -w /home/work \
        {{ docker_image }} \
        /bin/bash -c "set -euo pipefail && cat /etc/issue && export FORCE_UNSAFE_CONFIGURE=1 && ./build.sh {{ target }}" | tee build.log

menuconfig:
    cd "{{ sdk_path }}/buildroot/output/{{ target }}" && make manuconfig
