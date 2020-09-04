#!/usr/bin/env bash

latest_version=1.6.1-1
other_tags="1, 1.6, 1.6.1"
populate_dockerfiles() {
	cat > Dockerfile << EOF
FROM debian:buster-slim

ENV FRONTEND_PORT 443
ENV FRONTEND_HOST *
ENV BACKEND_PORT 8443
ENV BACKEND_HOST localhost
ENV CERTIFICATE /etc/hitch/testcert.pem
ENV PROXY_PROTOCOL --write-proxy-v2
ENV PROTOCOLS --tls
ENV CIPHERS ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
ENV OCSPDIR /var/lib/hitch-ocsp

RUN set -ex; \\
	apt-get update; \\
	apt-get install -y curl; \\
    curl -s https://packagecloud.io/install/repositories/varnishcache/hitch/script.deb.sh | bash; \\
	apt-get install -y --no-install-recommends openssl hitch=1.6.1-1~buster; \\
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/hitch

COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD hitch --user=hitch --group=hitch \\
--frontend="[\${FRONTEND_HOST}]:\${FRONTEND_PORT}+\${CERTIFICATE}" \\ 
--backend="[\${BACKEND_HOST}]:\${BACKEND_PORT}" \\
\${PROTOCOLS} \\
--ciphers=\${CIPHERS} \\
--ocsp-dir=\${OCSPDIR} \\
\${PROXY_PROTOCOL}
EOF
}
populate_library() {
	cat > library.hitch <<- EOF
# this file was generated using https://github.com/varnish/docker-hitch/blob/`git rev-parse HEAD`/populate.sh
Maintainers: Thijs Feryn <thijs@varni.sh> (@thijsferyn)
GitRepo: https://github.com/varnish/docker-hitch.git	

Tags: $other_tags, $latest_version latest
Architectures: amd64
GitCommit: `git log -n1 --pretty=oneline $workdir | cut -f1 -d" "`
EOF
}

case "$1" in
	dockerfile)
		populate_dockerfiles
		;;
	library)
		populate_library
		;;
	*)
		echo invalid choice
		exit 1
		;;
esac