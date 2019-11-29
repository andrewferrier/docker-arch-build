FROM archlinux/base

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

RUN curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=6&use_mirror_status=on" && sed -i 's/^#//' /etc/pacman.d/mirrorlist

RUN pacman-key --refresh-keys && \
  pacman --sync --refresh --noconfirm && \
  pacman --sync --noconfirm archlinux-keyring openssl pacman && \
  pacman-db-upgrade && \
  pacman --sync --sysupgrade --noconfirm && \
  pacman --sync --noconfirm base-devel git namcap wget yajl

RUN useradd --create-home --comment "Arch Build User" build
ENV HOME /home/build

RUN mkdir /deps
RUN chown build /deps
WORKDIR /deps
USER build

RUN gpg --recv-keys 1EB2638FF56C0C53

ENV PATH "$PATH:/usr/bin/core_perl"

USER root
RUN pacman -S --noconfirm jq
RUN pacman -S --noconfirm expac
RUN pacman -S --noconfirm meson
RUN pacman -S --noconfirm gtest
RUN pacman -S --noconfirm gmock
USER build

RUN mkdir /deps/auracle-git
WORKDIR /deps/auracle-git
RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/auracle-git.tar.gz
RUN tar xzvf auracle-git.tar.gz
WORKDIR /deps/auracle-git/auracle-git
RUN makepkg --force

USER root
RUN pacman -U --noconfirm /deps/auracle-git/auracle-git/auracle-git*.pkg.tar.xz
USER build

RUN mkdir /deps/pacaur
WORKDIR /deps/pacaur
RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz
RUN tar xzvf pacaur.tar.gz
WORKDIR /deps/pacaur/pacaur
RUN makepkg --force

USER root
RUN pacman -U --noconfirm /deps/pacaur/pacaur/pacaur-*.pkg.tar.xz
USER build

USER root
RUN mkdir /package
RUN chown build /package
WORKDIR /package
USER build

CMD ["makepkg", "--force", "--skipinteg"]
