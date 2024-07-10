TARGETS ?= armv7l aarch64
QT_VERSION ?= 6.5.3
QT_SERIAL ?= 6.5

JELIN_DEV_IMAGE ?= jelin-dev/ubuntu22.04:latest

# Get the directory of the Makefile
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Check if Docker image exists
DEV_IMG_EXISTS := $(shell docker images -q $(JELIN_DEV_IMAGE) 2>/dev/null)

# Check if qt source exists
QT_SOURCE_EXISTS := $(shell [ -f $(MAKEFILE_DIR)qt-source/qt-everywhere-src-$(QT_VERSION).tar.xz ] && echo 1 || echo 0)

# Transform TARGETS into SYSROOT_TARGETS with qt-sysroot- prefix
SYSROOT_TARGETS := $(addprefix qt-sysroot-,$(TARGETS))

APPEND_STR := ""

all: init build-dev download-qt build-sysroot Dockerfile build-qt

init:
	@echo "Initializing ..."
	@docker run --rm --privileged multiarch/qemu-user-static --reset -p yes -c yes
	@echo "Initialization completed!"

build-dev:
	@if [ "$(DEV_IMG_EXISTS)" ]; then \
		echo "$(JELIN_DEV_IMAGE) image exists."; \
	else \
		echo "$(JELIN_DEV_IMAGE) image does not exist."; \
		echo "Building $(JELIN_DEV_IMAGE) image"; \
		docker build -t $(JELIN_DEV_IMAGE) -f ../Dockerfile . || { \
			echo "Image build failed!"; \
			exit 1; \
		}; \
	fi

download-qt:
	@if [ "$(QT_SOURCE_EXISTS)" = "1" ]; then \
		echo "Qt source already exists!"; \
	else \
		echo "Qt source does not exist!"; \
		echo "Downloading Qt source for $(QT_VERSION) ..."; \
		mkdir -p ./qt-source; \
		wget https://download.qt.io/official_releases/qt/$(QT_SERIAL)/$(QT_VERSION)/single/qt-everywhere-src-$(QT_VERSION).tar.xz \
			-O $(MAKEFILE_DIR)qt-source/qt-everywhere-src-$(QT_VERSION).tar.xz; \
		echo "Download completed!"; \
	fi

build-sysroot: $(SYSROOT_TARGETS)
	@echo "Sysroot build completed for all targets!"

$(SYSROOT_TARGETS):
	@echo "Building $@ ..."
	@$(MAKE) -C $(MAKEFILE_DIR)sysroot $@
	@if [ $$? -ne 0 ]; then \
		echo "Sysroot build failed for $@!"; \
		exit 1; \
	fi
	@echo "Sysroot build completed for $@!"

dockerfile.common:
	@echo "Creating Dockerfile ..."
	@sed -e 's|template_qt_version|$(QT_VERSION)|' \
		-e 's|template_qt_src_path|qt-source/qt-everywhere-src-$(QT_VERSION).tar.xz|' \
	    $(MAKEFILE_DIR)qt-build/Dockerfile.template > $(MAKEFILE_DIR)qt-build/Dockerfile

$(TARGETS):
	@echo "Creating Dockerfile.$@ ..."
	@sed -e 's|template_qt_arch|$@|g' \
		-e 's|template_qt_sysroot_path|sysroot/qt-sysroot-$@.tar.gz|g' \
		-e 's|template_qt_toochain_file_path|toolchains/$@.toolchain.cmake|g' \
		-e 's|template_qt_toochain_file_name|$@.toolchain|g' \
	    $(MAKEFILE_DIR)qt-build/CrossCompile.template >> $(MAKEFILE_DIR)qt-build/Dockerfile

Dockerfile: dockerfile.common $(TARGETS)

build-qt:
	@echo "Building Dockerfile ..."
	@docker buildx build -t jelin-dev/qt-builder:$(QT_VERSION) -f $(MAKEFILE_DIR)qt-build/Dockerfile $(MAKEFILE_DIR)
	@if [ $$? -ne 0 ]; then \
		echo "Dockerfile build failed!"; \
		exit 1; \
	fi

clean:
	@echo "Cleaning up"

.PHONY: all init build-dev download-qt build-sysroot $(SYSROOT_TARGETS) $(DOCKERFILE_TARGETS) Dockerfile build-qt clean