#!/usr/bin/env bash

latest_version=1.7.0-1
other_tags="1, 1.7, 1.7.0"

populate_library() {
	cat > library.hitch <<- EOF
# this file was generated using https://github.com/varnish/docker-hitch/blob/`git rev-parse HEAD`/populate.sh
Maintainers: Thijs Feryn <thijs@varni.sh> (@thijsferyn),
             Guillaume Quintard <guillaume@varni.sh> (@gquintard)
GitRepo: https://github.com/varnish/docker-hitch.git	

Tags: $other_tags, $latest_version, latest
Architectures: amd64
GitCommit: `git log -n1 --pretty=oneline $workdir | cut -f1 -d" "`
EOF
}

populate_library
