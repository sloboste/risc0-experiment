# syntax=docker/dockerfile:1

FROM docker.io/library/archlinux:latest
SHELL ["/usr/bin/bash", "-c"]

COPY configs/.inputrc /root/.inputrc
COPY configs/.bashrc /root/.bashrc

RUN pacman -Syu --noconfirm \
    binutils \
    fakeroot \
    gcc \
    git \
    neovim \
    openssl \
    pkg-config \
    rustup \
    sudo \
    tree
RUN rustup install stable
ENV PATH="${PATH}:/root/.cargo/bin"

# Can't run makepkg as root so add a build user
RUN useradd build -m && passwd -d build && echo 'build ALL=(ALL) ALL' >> /etc/sudoers

RUN pushd /tmp && \
    sudo -u build bash -c \
        'git clone https://aur.archlinux.org/nvm.git && \
        pushd nvm && \
        makepkg -s --noconfirm' && \
        pushd nvm && \
        pacman -U --noconfirm nvm-*.tar.zst && \
        popd && \
    popd

RUN rustup target add wasm32-unknown-unknown && cargo install trunk
RUN source /usr/share/nvm/init-nvm.sh && \
    nvm install node && \
    nvm use node && \
    npm install -g near-cli
RUN git clone https://github.com/risc0/battleship-example.git && \
    pushd battleship-example && \
    git submodule update --init --recursive #&&
RUN pushd battleship-example && cargo build --bin battleship-web-server --release
RUN pushd battleship-example/web/client && trunk build
EXPOSE 8080
COPY configs/start-apps.bash /root/start-apps.bash

CMD /root/start-apps.bash
