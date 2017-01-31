FROM buildpack-deps:xenial


RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:adiscon/v8-stable

env BUILD_PACKAGES="git build-essential pkg-config libestr-dev libfastjson-dev zlib1g-dev uuid-dev libgcrypt20-dev liblogging-stdlog-dev libhiredis-dev flex bison"

RUN apt-get update && apt-get install -y ${BUILD_PACKAGES}
RUN git clone https://github.com/edenhill/librdkafka /tmp/librdkafka
RUN cd /tmp/librdkafka && ./configure --libdir=/usr/lib \
                                      --includedir=/usr/include \
                       && make \
                       && make install

RUN git clone https://github.com/rsyslog/rsyslog /tmp/rsyslog

RUN apt-get install -y \
	python-docutils \
	flex \
	bison

RUN cd /tmp/rsyslog && git checkout -b v8.24.0 refs/tags/v8.24.0 \
                    && ./autogen.sh --enable-omkafka \
                                 --disable-uuid \
                                 --disable-liblogging_stdlog \
                                 --disable-generate-man-pages \
                                 --prefix=/usr \
                    && make \
                    && make install

RUN rm -rf /tmp/* 
RUN apt-get remove --purge -y \
			git \
			python-software-properties \
			build-essential \
                        pkg-config \
			flex \
   && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/spool/rsyslog

EXPOSE 514

ENTRYPOINT ["rsyslogd"]
