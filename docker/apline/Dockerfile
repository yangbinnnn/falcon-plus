####################
# Build base image
####################
FROM golang:1.9.4-alpine3.7 as build-base
LABEL maintainer yangbinnnn@gmail.com
ENV FALCON_DIR=/root/monitor CONFIG_DIR=/config
ENV PROJ_PATH=${GOPATH}/src/github.com/open-falcon/falcon-plus

RUN apk add --no-cache ca-certificates bash git g++ perl make
COPY . ${PROJ_PATH}
WORKDIR ${PROJ_PATH}
RUN \
    make all \
    && make pack \
    && mkdir ${FALCON_DIR} \
    && tar zxvf open-falcon-v*.tar.gz -C ${FALCON_DIR}

####################
# Build final image
####################
FROM python:2.7.14-alpine3.7
LABEL maintainer yangbinnnn@gmail.com
ENV FALCON_DIR=/root/monitor DOCKER_DIR=docker MYSQL_DATA_DIR=/root/mysql MYSQL_USER=root
ENV MYSQL_DB_SCHEMA_DIR=/root/monitor/schema

COPY --from=build-base ${FALCON_DIR} ${FALCON_DIR}
COPY scripts/mysql/db_schema/ ${MYSQL_DB_SCHEMA_DIR}
COPY ${DOCKER_DIR}/apline/run.sh ${FALCON_DIR}/entrypoint.sh

RUN \
  apk add --no-cache tzdata ca-certificates bash curl git iproute2 jq vim gcc \
  python-dev mysql-dev libc-dev openldap-dev py-virtualenv mysql mysql-client redis\
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && mysql_install_db --user=${MYSQL_USER} --datadir=${MYSQL_DATA_DIR} \
  && cd ${FALCON_DIR} && git clone https://github.com/open-falcon/dashboard.git \
  && cd ${FALCON_DIR}/dashboard && virtualenv ./env && ./env/bin/pip install -r pip_requirements.txt \
  && rm -rf /root/.cache/ \
  && cd ${MYSQL_DB_SCHEMA_DIR} \
  && /usr/bin/mysqld_safe --datadir=${MYSQL_DATA_DIR} --user=${MYSQL_USER} --nowatch \
  && mysql -h 127.0.0.1 -u root < 1_uic-db-schema.sql \
  && mysql -h 127.0.0.1 -u root < 2_portal-db-schema.sql \
  && mysql -h 127.0.0.1 -u root < 3_dashboard-db-schema.sql \
  && mysql -h 127.0.0.1 -u root < 4_graph-db-schema.sql \
  && mysql -h 127.0.0.1 -u root < 5_alarms-db-schema.sql


# Port
# Hbs: 6036
# transfer: 8433
# dashboard: 8081
EXPOSE 6036 8433 8081
WORKDIR ${FALCON_DIR}
ENTRYPOINT ["entrypoint.sh"]
