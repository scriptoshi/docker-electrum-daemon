FROM python:3.9.12-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION


LABEL maintainer="scriptoshi.com@gmail.com" \
	org.label-schema.vendor="Boroda Group" \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.name="Electrum wallet (RPC enabled)" \
	org.label-schema.description="Electrum wallet with JSON-RPC enabled (daemon mode)" \
	org.label-schema.version=$VERSION \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/scriptoshi/docker-electrum-daemon" \
	org.label-schema.usage="https://github.com/scriptoshi/docker-electrum-daemon#getting-started" \
	org.label-schema.license="MIT" \
	org.label-schema.url="https://electrum.org" \
	org.label-schema.docker.cmd='docker run -d --name electrum-daemon --publish 127.0.0.1:7000:7000 --volume /srv/electrum:/data scriptoshi/electrum-daemon' \
	org.label-schema.schema-version="1.0"

ENV ELECTRUM_VERSION $VERSION
ENV ELECTRUM_USER electrum
ENV ELECTRUM_PASSWORD electrumz
ENV ELECTRUM_HOME /home/$ELECTRUM_USER
ENV ELECTRUM_NETWORK mainnet

RUN  echo -e "ELECTRUM_VERSION: $VERSION "


RUN mkdir -p /data ${ELECTRUM_HOME} && \
	ln -sf /data ${ELECTRUM_HOME}/.electrum


RUN adduser -D $ELECTRUM_USER 
RUN apk update &&\
    apk --no-cache add --upgrade libsecp256k1
#RUN apk --no-cache add --virtual build-dependencies gpg dirmngr gpg-agent gcc musl-dev libsecp256k1 libsecp256k1-dev libressl-dev jpeg-dev zlib-dev libffi-dev cairo-dev pango-dev gdk-pixbuf-dev  && \
RUN apk update &&\
    apk --no-cache add --upgrade --virtual build-dependencies gpg dirmngr gpg-agent gcc musl-dev libressl-dev  libffi-dev  && \
    wget https://download.electrum.org/${ELECTRUM_VERSION}/Electrum-${ELECTRUM_VERSION}.tar.gz && \
    wget https://download.electrum.org/${ELECTRUM_VERSION}/Electrum-${ELECTRUM_VERSION}.tar.gz.asc && \
    gpg --keyserver keys.gnupg.net --recv-keys 6694D8DE7BE8EE5631BED9502BD5824B7F9470E6 && \
    gpg --keyserver keys.gnupg.net --recv-keys 0EEDCFD5CAFB459067349B23CA9EEEC43DF911DC && \
    gpg --keyserver keys.gnupg.net --recv-keys 637DB1E23370F84AFF88CCE03152347D07DA627C && \
    gpg --verify Electrum-${ELECTRUM_VERSION}.tar.gz.asc Electrum-${ELECTRUM_VERSION}.tar.gz && \
    pip3 install cryptography pycryptodomex Electrum-${ELECTRUM_VERSION}.tar.gz && \
    rm -f Electrum-${ELECTRUM_VERSION}.tar.gz && \
    apk del build-dependencies 
RUN cp /usr/lib/libsecp256k1.so.0 /usr/local/lib/python3.9/site-packages/electrum
RUN mkdir -p /data \
	    ${ELECTRUM_HOME}/.electrum/wallets/ \
	    ${ELECTRUM_HOME}/.electrum/testnet/wallets/ \
	    ${ELECTRUM_HOME}/.electrum/regtest/wallets/ \
	    ${ELECTRUM_HOME}/.electrum/simnet/wallets/ && \
    ln -sf ${ELECTRUM_HOME}/.electrum/ /data && \
	chown -R ${ELECTRUM_USER} ${ELECTRUM_HOME}/.electrum /data

USER $ELECTRUM_USER
WORKDIR $ELECTRUM_HOME
VOLUME /data
EXPOSE 7000

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["electrum"]
