# from https://github.com/metabase/metabase/blob/v0.32.1/Dockerfile
###################
# STAGE 1: builder
###################

FROM openjdk:8-jdk-alpine as builder

WORKDIR /app/source

ENV FC_LANG en-US
ENV LC_CTYPE en_US.UTF-8

# bash:    various shell scripts
# wget:    installing lein
# git:     ./bin/version
# yarn:  frontend building
# make:    backend building
# gettext: translations

RUN apk add --update bash yarn git wget make gettext

# lein:    backend dependencies and building
ADD https://raw.github.com/technomancy/leiningen/stable/bin/lein /usr/local/bin/lein
RUN chmod 744 /usr/local/bin/lein
RUN lein upgrade

RUN git clone --branch v0.32.1 https://github.com/metabase/metabase .
ADD patches/ldap.patch .
RUN git apply ldap.patch

# install dependencies
RUN lein deps
RUN yarn

# build the app
RUN bin/build no-translations

# install updated cacerts to /etc/ssl/certs/java/cacerts
RUN apk add --update java-cacerts

# import AWS RDS cert into /etc/ssl/certs/java/cacerts
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem .
RUN keytool -noprompt -import -trustcacerts -alias aws-rds \
  -file rds-combined-ca-bundle.pem \
  -keystore /etc/ssl/certs/java/cacerts \
  -keypass changeit -storepass changeit

# ###################
# # STAGE 2: runner
# ###################

FROM openjdk:8-jre-alpine as runner

WORKDIR /app

ENV FC_LANG en-US
ENV LC_CTYPE en_US.UTF-8

# dependencies
RUN apk add --update bash ttf-dejavu fontconfig

# add fixed cacerts
COPY --from=builder /etc/ssl/certs/java/cacerts /usr/lib/jvm/default-jvm/jre/lib/security/cacerts

# add Metabase script and uberjar
RUN mkdir -p bin target/uberjar
COPY --from=builder /app/source/target/uberjar/metabase.jar /app/target/uberjar/
COPY --from=builder /app/source/bin/start /app/bin/

# create the plugins directory, with writable permissions
RUN mkdir -p /plugins
RUN chmod a+rwx /plugins

# expose our default runtime port
EXPOSE 3000

# run it
ENTRYPOINT ["/app/bin/start"]

