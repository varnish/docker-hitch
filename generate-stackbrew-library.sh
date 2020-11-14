#!/bin/bash
cat <<- EOF
# this file was generated using https://github.com/varnish/docker-hitch/blob/`git rev-parse HEAD`/generate-stackbrew-library.sh
Maintainers: Thijs Feryn <thijs@varni.sh> (@thijsferyn),
             Guillaume Quintard <guillaume@varni.sh> (@gquintard)
GitRepo: https://github.com/varnish/docker-hitch.git

Tags: 1, 1.6, 1.6.1, 1.6.1-1, latest
Architectures: amd64
GitCommit: `git rev-parse HEAD`
EOF
