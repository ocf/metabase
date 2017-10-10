ARG metabase_version=latest
FROM metabase/metabase:${metabase_version}

COPY run /opt/

ENTRYPOINT ["/opt/run"]
