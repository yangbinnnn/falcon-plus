####################
# Build base image
####################
FROM golang:1.9.4-alpine3.7 as build-base
LABEL maintainer yangbinnnn@gmail.com
ENV FALCON_DIR=/root/monitor CONFIG_DIR=/config
ENV PROJ_PATH=${GOPATH}/src/github.com/open-falcon/falcon-plus

RUN echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/v3.7/community/" >> /etc/apk/repositories \
    && apk add --no-cache ca-certificates bash git g++ perl make
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
ENV MYSQL_SCHEMA_DIR=/root/monitor/schema

COPY --from=build-base ${FALCON_DIR} ${FALCON_DIR}
COPY scripts/mysql/db_schema/ ${MYSQL_SCHEMA_DIR}
COPY ${DOCKER_DIR}/apline/entrypoint.sh ${FALCON_DIR}/entrypoint.sh

RUN \
  echo "http://mirrors.aliyun.com/alpine/v3.7/main/" > /etc/apk/repositories \
  && echo "http://mirrors.aliyun.com/alpine/v3.7/community/" >> /etc/apk/repositories \
  && apk add --no-cache tzdata ca-certificates bash curl git gcc \
  python-dev mysql-dev libc-dev openldap-dev py-virtualenv mysql mysql-client redis\
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && cd ${FALCON_DIR}/dashboard && virtualenv ./env && ./env/bin/pip install -r pip_requirements.txt \
  && rm -rf /root/.cache


# Port
# Hbs: 6036
# transfer: 8433
# dashboard: 8081
EXPOSE 6036 8433 8081
WORKDIR ${FALCON_DIR}
ENTRYPOINT ["bash", "entrypoint.sh"]
