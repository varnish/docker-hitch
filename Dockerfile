FROM debian:stretch-slim

ENV FRONTEND_PORT 443
ENV FRONTEND_HOST *
ENV BACKEND_PORT 8443
ENV BACKEND_HOST localhost

RUN apt-get update; \
	apt-get install -y --no-install-recommends openssl hitch curl; \
	rm -rf /var/lib/apt/lists/*; \
	mkdir /etc/hitch/certs

WORKDIR /etc/hitch

COPY example.com /etc/hitch/certs
COPY hitch.conf /etc/hitch
COPY docker-hitch-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-hitch-entrypoint"]

EXPOSE 443

CMD hitch --config=/etc/hitch/hitch.conf --frontend="[$FRONTEND_HOST]:$FRONTEND_PORT" --backend="[$BACKEND_HOST]:$BACKEND_PORT"
