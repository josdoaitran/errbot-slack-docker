COPY config.py requirements.txt /err/
COPY base.sh /base.sh
COPY app.sh /app.sh
COPY entrypoint.sh /entrypoint.sh
COPY local_plugins /err/local_plugins/

RUN chmod +x /app.sh /base.sh /entrypoint.sh

RUN apk add --update mysql mysql-client
RUN apk upgrade --no-cache
RUN apk --no-cache --update add libffi libssl1.0
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
RUN pip3 install mysql-connector

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

RUN chmod +x /err
WORKDIR /err
ENTRYPOINT ["/entrypoint.sh"]
