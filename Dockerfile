FROM debian:buster-slim

ENV HITCH_VERSION 1.6.1-1~buster

ENV FRONTEND_PORT 443
ENV FRONTEND_HOST *
ENV BACKEND_PORT 8443
ENV BACKEND_HOST localhost
ENV CERTIFICATE /etc/hitch/testcert.pem
ENV PROXY_PROTOCOL --write-proxy-v2
ENV PROTOCOLS --tls
ENV CIPHERS ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
ENV OCSPDIR /var/lib/hitch-ocsp

RUN set -ex; \
	fetchDeps=" \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates $fetchDeps; \
	key=E35824BB706997D9184818E715A7ECE02FE19401; \
	export GNUPGHOME="$(mktemp -d)"; \
echo getting key; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys $key; \
echo got key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/hitch.gpg; \
echo exported key; \
	gpgconf --kill all; \
	rm -rf $GNUPGHOME; \
	echo deb https://packagecloud.io/varnishcache/hitch/debian/ buster main > /etc/apt/sources.list.d/hitch.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends hitch=$HITCH_VERSION; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/hitch

COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD hitch --user=hitch \
	--group=hitch \
	--frontend="[${FRONTEND_HOST}]:${FRONTEND_PORT}+${CERTIFICATE}" \
	--backend="[${BACKEND_HOST}]:${BACKEND_PORT}" \
	${PROTOCOLS} \
	--ciphers=${CIPHERS} \
	--ocsp-dir=${OCSPDIR} \
	${PROXY_PROTOCOL}
