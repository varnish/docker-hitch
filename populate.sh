#!/usr/bin/env bash
cat > library.hitch <<- EOF
# this file was generated using https://github.com/varnish/docker-hitch/blob/`git rev-parse HEAD`/populate.sh
Maintainers: Thijs Feryn <thijs@varni.sh> (@thijsferyn)
GitRepo: https://github.com/varnish/docker-hitch.git	

Tags: 1, 1.5, 1.5.0, 1.5.0-1 latest
Architectures: amd64
GitCommit: `git log -n1 --pretty=oneline $workdir | cut -f1 -d" "`
EOF
