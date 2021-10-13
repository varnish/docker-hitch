FROM debian:bullseye-slim

ARG SRCVER=1.7.0
ARG PKGVER=1
ARG DISTVER=bullseye
ARG PKGCOMMIT=f12ab7958bc4885f3f00311cbca5103d9e6ba794
ARG SHASUM=d82d2cb5d0be39dcd40ffd969d0a1c25d4d253c21078f8b2b1fca7a4e93acc84c15a53590966917b6382faffc24abdc7928b713460b1f28a321ac5b8fafd8313

RUN set -ex; \
    BASE_PKGS="apt-utils curl dirmngr dpkg-dev debhelper devscripts equivs fakeroot git gnupg pkg-config"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    tmpdir="$(mktemp -d)"; \
    cd "$tmpdir"; \
    apt-get update; \
    apt-get install -y $BASE_PKGS; \
    git clone https://github.com/varnish/pkg-hitch.git; \
    cd pkg-hitch; \
    git checkout ${PKGCOMMIT}; \
    rm -rf .git; \
    curl -Lf https://hitch-tls.org/source/hitch-${SRCVER}.tar.gz -o $tmpdir/orig.tgz; \
    echo "${SHASUM}  $tmpdir/orig.tgz" | sha512sum -c -; \
    tar xavf $tmpdir/orig.tgz --strip 1; \
    sed -i \
        -e "s/@SRCVER@/${SRCVER}/g" \
        -e "s/@PKGVER@/${PKGVER:-1}/g" \
        -e "s/@DISTVER@/$DISTVER/g" debian/changelog; \
    mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --yes" debian/control; \
    sed -i '' debian/hitch*; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y purge --auto-remove hitch-build-deps $BASE_PKGS; \
    apt-get -y install ../*.deb; \
    sed -i 's/daemon = on/daemon = off/' /etc/hitch/hitch.conf; \
    rm -rf /var/lib/apt/lists/* "$tmpdir"

WORKDIR /etc/hitch

COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD []
