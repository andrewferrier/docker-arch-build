FROM base/devel

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

RUN mkdir /deps/package-query
WORKDIR /deps/package-query
RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
RUN tar xzvf package-query.tar.gz
WORKDIR /deps/package-query/package-query
RUN makepkg --force

USER root
RUN pacman -U --noconfirm /deps/package-query/package-query/package-query-*.pkg.tar.xz
USER build

RUN mkdir /deps/yaourt
WORKDIR /deps/yaourt
RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
RUN tar xzvf yaourt.tar.gz
WORKDIR /deps/yaourt/yaourt
RUN makepkg --force

USER root
RUN pacman -U --noconfirm /deps/yaourt/yaourt/yaourt-*.pkg.tar.xz
USER build

USER root
RUN mkdir /package
RUN chown build /package
WORKDIR /package
USER build

CMD ["makepkg", "--force"]
