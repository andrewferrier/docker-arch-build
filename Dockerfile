FROM base/devel

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

RUN curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=6&use_mirror_status=on" && sed -i 's/^#//' /etc/pacman.d/mirrorlist

RUN pacman-key --refresh-keys && \
  pacman --sync --refresh --noconfirm --noprogressbar && \
  pacman --sync --noconfirm --noprogressbar archlinux-keyring openssl pacman && \
  pacman-db-upgrade && \
  pacman --sync --sysupgrade --noconfirm --noprogressbar && \
  pacman --sync --noconfirm --noprogressbar base-devel git namcap

RUN useradd --create-home --comment "Arch Build User" build
ENV HOME /home/build

RUN mkdir /package
RUN chown build /package
WORKDIR /package

USER build

CMD ["makepkg", "--force"]
