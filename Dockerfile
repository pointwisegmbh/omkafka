FROM buildpack-deps:jessie

RUN apt-get update && apt-get install -y \
              git \
              libtool \
              libz-dev \
              libjson0-dev \
              libgcrypt-dev \
              libestr-dev \
              flex \
              bison \
              python-docutils \
         && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/edenhill/librdkafka /tmp/librdkafka
RUN cd /tmp/librdkafka && ./configure --libdir=/usr/lib \
                                      --includedir=/usr/include \
                       && make \
                       && make install

RUN git clone https://github.com/rsyslog/rsyslog /tmp/rsyslog

# read https://github.com/rsyslog/rsyslog/blob/master/configure.ac for more flags
env VERSION="v8.24.0"

RUN cd /tmp/rsyslog && git checkout -b ${VERSION} refs/tags/${VERSION} \

RUN apt-get install -y \
	python-docutils \
	flex \
	bison

RUN cd /tmp/rsyslog && git checkout -b v8.24.0 refs/tags/v8.24.0 \
                    && ./autogen.sh --enable-omkafka \
                                 --enable-imfile \
                                 --enable-imptcp \
                                 --enable-regexp \
                                 --enable-inet \
                                 --enable-pgsql \
                                 --enable-snmp \
                                 --enable-elasticsearch \
                                 --enable-ommongodb \
                                 --enable-omrabbitmq \
                                 --enable-omhiredis \
                                 --enable-mmgrok \
                                 --enable-mmsequence \
                                 --enable-mmfields \
                                 --enable-mmnormalize \
                                 --enable-mmjsonparse \
                                 --enable-mmaudit \
                                 --enable-pmlastmsg \
                                 --enable-pmcisconames \
                                 --enable-mail \
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
