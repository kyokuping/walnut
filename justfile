# walnut/justfile

sdk_path := "duo-buildroot-sdk-v2"
target := "milkv-duo256m-glibc-arm64-sd"
docker_image := "milkvtech/milkv-duo@sha256:63d71ea6fb2c2fb23ee34b68892ace67ed8a0c66954ed47b5cb793443fead679"
abs_sdk_path := justfile_directory() / sdk_path
config_dir := justfile_directory() / "configs/nut"

setup:
    @echo "🚀 Syncing SDK submodule..."
    @if git submodule status --recursive | grep -q '^-'; then \
        echo "⚠️ SDK submodule is out of date, updating..."; \
        git submodule update --init --recursive --depth 1; \
    else \
        echo "✅ SDK submodule is up to date."; \
    fi

    @echo "📦 Preparing Docker environment {{ docker_image }}..."
    @if [ -d "{{ sdk_path }}" ]; then chmod +x {{ sdk_path }}/*.sh; fi
    docker pull {{ docker_image }}

repair-sdk:
    @echo "🔧 Repairing SDK..."
    git submodule deinit -f {{ sdk_path }}
    git submodule update --init --recursive --depth 1

init-overlay: setup
    @echo "📂 Creating NUT overlay for Milk-V Duo {{ target }}..."
    mkdir -p {{ abs_sdk_path }}/board/overlay/etc/nut

    @if [ -d "{{ config_dir }}" ]; then \
            cp -v {{ config_dir }}/*.conf {{ abs_sdk_path }}/board/common/overlay/etc/nut/ 2>/dev/null || true; \
            cp -v {{ config_dir }}/*.users {{ abs_sdk_path }}/board/common/overlay/etc/nut/ 2>/dev/null || true; \
    fi

    chmod 640 {{ abs_sdk_path }}/board/overlay/etc/nut/*.conf 2>/dev/null || true
    @echo "✅ NUT overlay initialized for Milk-V Duo {{ target }}."

menuconfig: setup
    @echo "⚙️ Opening menuconfig for Milk-V Duo {{ target }}..."
    @if [ ! -f "{{ sdk_path }}/build.sh" ]; then \
        echo "❌ build.sh not found in SDK, 'just setup' first"; \
        exit 1; \
    fi
    docker run --rm -it \
        --user root \
        -v "{{ abs_sdk_path }}:/home/work" \
        -w /home/work/buildroot \
        {{ docker_image }} \
        /bin/bash -c "make {{ target }}_defconfig && make menuconfig && make savedefconfig"

build: setup init-overlay
    @if [ ! -f "{{ sdk_path }}/build.sh" ]; then \
        echo "❌ build.sh not found in SDK, 'just setup' first"; \
        exit 1; \
    fi
    @echo "🔨 Building for Milk-V Duo {{ target }}..."
    set -o pipefail && \
        docker run --rm -it \
        --user root \
        -v "{{ abs_sdk_path }}:/home/work" \
        -w /home/work \
        {{ docker_image }} \
        /bin/bash -c "set -euo pipefail && cat /etc/issue && export FORCE_UNSAFE_CONFIGURE=1 && ./build.sh {{ target }}" | tee build.log
