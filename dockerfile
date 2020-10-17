# Errbot - the pluggable chatbot

FROM python:3.8.3-alpine3.12

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/swarmstack/errbot-docker.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

ENV slack_token=xoxb-1114622558355-1448100712417-6xkhnA0yb6o7JL8xzAK95Sdt
ENV bot_admin=@doai.tran

ENV app_env=local


COPY config.py requirements.txt /err/
COPY base.sh /base.sh
COPY app.sh /app.sh
COPY entrypoint.sh /entrypoint.sh
COPY local_plugins /err/local_plugins/

RUN chmod +x /app.sh /base.sh /entrypoint.sh

RUN apk upgrade --no-cache

RUN apk add --no-cache --virtual .build-deps \
     gcc \
     build-base \
     libffi-dev \
     openssl-dev \
     tzdata \
     python3-dev \
     py3-pip
RUN pip3 install --upgrade pip
RUN pip3 install errbot
RUN pip3 install errbot[slack]
RUN pip3 install -r /err/requirements.txt
RUN rm -f /err/requirements.txt
RUN cp /usr/share/zoneinfo/America/Chicago /etc/localtime
RUN /base.sh
RUN rm -f /base.sh
RUN /app.sh
RUN rm -f /app.sh
RUN apk del .build-deps

EXPOSE 3141 3142
VOLUME ["/err/data/"]

#Add HEALTHCHECK after enabling errbot webserver
#HEALTHCHECK --interval=25s --timeout=2s --start-period=30s CMD /usr/bin/curl -s -I -X GET http://localhost:3141
RUN chmod +x /err
WORKDIR /err
ENTRYPOINT ["/entrypoint.sh"]
