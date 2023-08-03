FROM library/debian:12-slim

ARG version=4.1.7

COPY --chown=root:root config /config/

RUN apt-get update \
 && apt-get install --assume-yes --no-install-recommends \
      ca-certificates \
      curl \
      nginx-full \
      php-fpm \
      php-mbstring \
      rtorrent \
      s6 \
 && rm -rf /var/lib/apt/lists/* \
# /dev/pts for stdout/stderr is writable by tty group, so add our user to that
 && useradd -d /nonexistent -G tty -M -U -s /usr/sbin/nologin -u 10000 rutorrent \
 && install -d -g root -o root -m 0755 /var/www/rutorrent \
 && curl -sSL "https://github.com/Novik/ruTorrent/archive/refs/tags/v${version}.tar.gz" \
      | tar -xz -C /var/www/rutorrent --no-same-owner --no-same-permissions --strip-components 1 \
 && sed -i \
      -e '/$scgi_port =/c\$scgi_port = 0;' \
      -e '/$scgi_host =/c\$scgi_host = "unix:///run/rtorrent/scgi.sock";' \
      -e '/$profilePath =/c\$profilePath = "/data";' \
      -e '/$profileMask =/c\$profileMask = 0700;' \
      /var/www/rutorrent/conf/config.php \
# Ensure config permissions are correct, until COPY supports this kind of chmod
 && chmod 0755 /config /config/* \
 && chmod 0644 /config/*/*

COPY --chmod=0755 --chown=root:root docker-entrypoint.sh /
COPY --chmod=0755 --chown=root:root s6 /etc/s6

CMD [ "/usr/bin/s6-svscan", "/run/s6"  ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]
USER rutorrent
VOLUME [ "/run" ]
