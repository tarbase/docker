FROM debian:buster-slim

LABEL \
  maintainer="Tarbase <hello@tarbase.com>" \
  vendor="Tarbase" \
  cmd="docker container run --detach --publish 2375:2375/tcp --privileged tarbase/docker" \
  params=""

EXPOSE \
  2375/tcp

ENV LANG=C.UTF-8

COPY files/ /root/

RUN \
# copy scripts
  install --owner=root --group=root --mode=0755 --target-directory=/usr/bin /root/scripts/* && \
# copy tests
  install --owner=root --group=root --mode=0755 --target-directory=/usr/bin /root/tests/* && \
# dependencies
  apt-get -qq update && \
  apt-get -qq -y --no-install-recommends install \
    apt-transport-https \
    ca-certificates \
    > /dev/null 2>&1 && \
  dpkg-query --show -f='${Package}\n' > /tmp/dependencies.pre && \
  apt-get -qq -y --no-install-recommends install \
    curl \
    dirmngr \
    gpg \
    gpg-agent \
    software-properties-common \
    > /dev/null 2>&1 && \
  dpkg-query --show -f='${Package}\n' > /tmp/dependencies.post && \
# repos
  echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' \
    > /etc/apt/sources.list.d/docker.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com --receive-keys --recv 0x8d81803c0ebfcd88 && \
  apt-get -qq update && \
# docker-compose
  compose_version="$(curl --silent --location --retry 3 'https://api.github.com/repos/docker/compose/releases/latest' | sed -E -n -e '/tag_name/ s/.*"(.*)",/\1/p')" && \
  curl --silent --location --retry 3 "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname -s)-$(uname -m)" --output "/usr/bin/docker-compose" && \
  chmod 0755 "/usr/bin/docker-compose" && \
# dependencies cleanup
  apt-get -qq -y purge \
    $(diff --changed-group-format='%>' --unchanged-group-format='' /tmp/dependencies.pre /tmp/dependencies.post | xargs) \
    > /dev/null 2>&1 && \
# docker
  apt-get -qq -y --no-install-recommends install \
    containerd.io \
    docker-ce \
    docker-ce-cli \
    > /dev/null 2>&1 && \
# system settings
  install --directory --owner=root --group=root --mode=0755 /build/run/systemd && \
  echo 'docker' > /build/run/systemd/container && \
# system cleanup
  apt-get clean && \
  rm -rf /usr/share/info/* && \
  rm -rf /usr/share/locale/* && \
  rm -rf /usr/share/man/* && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/log/* && \
  rm -rf /root/.??* && \
  rm -rf /tmp/.??* /tmp/* && \
  find /usr/share/doc -mindepth 1 -not -type d -not -name 'copyright' -delete && \
  find /usr/share/doc -mindepth 1 -type d -empty -delete && \
  find /var/cache -type f -delete

ENTRYPOINT ["/usr/bin/entrypoint"]
