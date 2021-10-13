FROM debian:buster-slim

ARG SRCVER=1.7.0
ARG PKGVER=1
ARG DISTVER=buster
ARG PKGCOMMIT=8f683fe849ac391cd025539ce3df5c5a821b11bb
ARG SHASUM=683fb7986d97c2288512261448e4478472e58809ead8e1ffd63741ab7b67b8c44900dc81dc1e054597b3fed4f9bcbfe6194904939e30761d61e7f3584dc793f3

RUN set -ex; \
    BASE_PKGS="apt-utils curl dirmngr dpkg-dev debhelper devscripts equivs fakeroot git gnupg pkg-config"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    tmpdir="$(mktemp -d)"; \
    cd "$tmpdir"; \
    apt-get update; \
    apt-get install -y $BASE_PKGS; \
    git clone https://github.com/gquintard/pkg-hitch.git; \
    cd pkg-hitch; \
    git checkout ${PKGCOMMIT}; \
    git checkout tweaks; \
    rm -rf .git; \
    curl -Lf https://github.com/varnish/hitch/archive/refs/tags/${SRCVER}.tar.gz -o $tmpdir/orig.tgz; \
    echo "${SHASUM}  $tmpdir/orig.tgz" | sha512sum -c -; \
    tar xavf $tmpdir/orig.tgz --strip 1; \
    sed -i 's/python-docutils/python-docutils | python3-docutils/' debian/control; \
    sed -i \
        -e "s/@SRCVER@/${SRCVER}/g" \
        -e "s/@PKGVER@/${PKGVER:-1}/g" \
        -e "s/@DISTVER@/$DISTVER/g" debian/changelog; \
    mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --yes" debian/control; \
    sed -i '' debian/hitch*; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y install ../*.deb; \
    apt-get -y purge --auto-remove hitch-build-deps $BASE_PKGS; \
    sed -i 's/daemon = on/daemon = off/' /etc/hitch/hitch.conf; \
    rm -rf /var/lib/apt/lists/* "$tmpdir"

WORKDIR /etc/hitch

COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD []
