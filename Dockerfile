FROM debian:bullseye-slim

ARG SRCVER=1.7.3
ARG PKGVER=1
ARG DISTVER=bullseye
ARG PKGCOMMIT=f12ab7958bc4885f3f00311cbca5103d9e6ba794
ARG SHASUM=88de82e639e7f9b7873bb7226fcbcbc4cd5779c75a5bd21fca8e1ca927a2a3ae9eb455d73d1f42d4dc45546118c718d1b58396836ed9c8acac281d487c9fe8fd

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
