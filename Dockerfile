FROM debian:buster-slim

ENV HITCH_VERSION 1.6.1-1~buster

RUN set -ex; \
	fetchDeps=" \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates $fetchDeps; \
	key=E35824BB706997D9184818E715A7ECE02FE19401; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys $key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/hitch.gpg; \
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

CMD []
