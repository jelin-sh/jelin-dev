FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
COPY ./sources.list /etc/apt/sources.list

# Install packages
RUN set -eux \
    && apt-get update \
    && apt-get -yq upgrade \
    && apt-get -yq install \
        aptitude apt-rdepends bash build-essential ccache clang clang-tidy cppcheck curl doxygen diffstat gawk gdb git gnupg gperf iputils-ping \
        linux-tools-generic nano nasm ninja-build openssh-server openssl pkg-config python3 python-is-python3 spawn-fcgi net-tools iproute2 \
        sudo tini unzip valgrind wget zip texinfo gcc-multilib chrpath socat cpio xz-utils debianutils \
        patch perl tar rsync bc xterm whois software-properties-common apt-transport-https ca-certificates\
        dh-autoreconf apt-transport-https g++ graphviz xdot mesa-utils \
    && exit 0

# Install cmake
RUN set -eux \
    && wget https://github.com/Kitware/CMake/releases/download/v3.28.5/cmake-3.28.5-linux-x86_64.sh -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /opt/cmake-3.28.5 \
    && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.28.5 \
    && rm /tmp/cmake-install.sh \
    && ln -s /opt/cmake-3.28.5/bin/* /usr/local/bin \
    && cmake --version \
    && exit 0

# Install arm compiler
RUN set -eux \
    && apt-get update \
    && apt-get -yq install \
        gcc-arm-none-eabi \
        g++-arm-linux-gnueabi gcc-arm-linux-gnueabi \
        g++-arm-linux-gnueabihf gcc-arm-linux-gnueabihf \
        g++-aarch64-linux-gnu gcc-aarch64-linux-gnu \
    && exit 0

# Install python pip
RUN set -eux \
    && python3 --version \
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py \
    && rm get-pip.py \
    && python3 -m pip install -U pip \
    && pip3 --version \
    && pip3 install --upgrade pip setuptools wheel \
    && pip3 --version \
    && exit 0

# Install python packages
RUN set -eux \
    && pip3 --version \
    && pip3 install --upgrade pip setuptools wheel \
    && pip3 --version \
    && pip3 install --upgrade autoenv autopep8 cmake-format clang-format conan meson \
    && pip3 install --upgrade cppclean flawfinder lizard pygments pybind11 GitPython pexpect subunit Jinja2 pylint CLinters \
    && exit 0

# Install libraries
RUN set -eux \
    && apt-get install -yq \
        libgl-dev libgl1-mesa-dev libclang-dev\
        libx11-xcb-dev libfontenc-dev libice-dev libsm-dev libxaw7-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxext-dev \
        libxfixes-dev libxi-dev libxinerama-dev libxkbfile-dev libxmu-dev libxmuu-dev libxpm-dev libxrandr-dev libxrender-dev libxres-dev \
        libxss-dev libxt-dev libxtst-dev libxv-dev libxxf86vm-dev libxcb-glx0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-xkb-dev \
        libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-shape0-dev libxcb-sync-dev libxcb-xfixes0-dev \
        libxcb-xinerama0-dev libxcb-dri3-dev uuid-dev libxcb-cursor-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev \
        libxcb-composite0-dev libxcb-ewmh-dev libxcb-res0-dev libxcb-util-dev libxcb-util0-dev\
    && apt-get -yq autoremove \
    && apt-get -yq autoclean  \
    && apt-get -yq clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && exit 0

# Setup ssh
RUN set -eux \
    && mkdir -p /var/run/sshd \
    && mkdir -p /root/.ssh \
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && echo 'root:root' | chpasswd \
    && exit 0

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/usr/sbin/sshd","-D","-e"]
