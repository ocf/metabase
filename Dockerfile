ARG metabase_version=latest
FROM metabase/metabase:${metabase_version}

RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

COPY run /opt/

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

CMD ["/opt/run"]
