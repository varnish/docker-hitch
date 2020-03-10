#!/usr/bin/env bash

latest_version=1.5.0-1
other_tags="1, 1.5, 1.5.0"
populate_dockerfiles() {
	cat > Dockerfile << EOF
FROM debian:buster-slim

ENV FRONTEND_PORT 443
ENV FRONTEND_HOST *
ENV BACKEND_PORT 8443
ENV BACKEND_HOST localhost
ENV PROXY_PROTOCOL --write-proxy-v2

RUN apt-get update; \\
	apt-get install -y --no-install-recommends openssl hitch=$latest_version; \\
	rm -rf /var/lib/apt/lists/*; \\
	mkdir /etc/hitch/certs

WORKDIR /etc/hitch

COPY example.com /etc/hitch/certs
COPY hitch.conf /etc/hitch
COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD hitch --config=/etc/hitch/hitch.conf --frontend="[\$FRONTEND_HOST]:\$FRONTEND_PORT" --backend="[\$BACKEND_HOST]:\$BACKEND_PORT" \$PROXY_PROTOCOL
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
