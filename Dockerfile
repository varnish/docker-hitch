FROM debian:buster-slim

ENV HITCH_VERSION 1.7.0-1~buster

RUN set -ex; \
	fetchDeps=" \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates $fetchDeps; \
	curl -L https://packagecloud.io/varnishcache/hitch/gpgkey | apt-key add - ; \
	echo deb https://packagecloud.io/varnishcache/hitch/debian/ buster main > /etc/apt/sources.list.d/hitch.list; \
	apt-get update; \
	adduser --quiet --system --no-create-home --uid 443 --group hitch; \
	groupmod -g 443 hitch; \
	case "$(dpkg --print-architecture)" in \
		amd64) apt-get install -y --no-install-recommends hitch=$HITCH_VERSION;; \
		arm64) apt-get install -y --no-install-recommends hitch;; \
	esac && \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	if [ "$(dpkg --print-architecture)" = amd64 ]; then \
		mkdir /etc/hitch/certs/ /var/lib/hitch/; \
		cp /etc/hitch/testcert.pem /etc/hitch/certs/default; \
		sed -i 's/daemon = on/daemon = off/' /etc/hitch/hitch.conf; \
	fi

WORKDIR /etc/hitch

COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD []
